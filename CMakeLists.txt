cmake_minimum_required(VERSION 3.28)
project(snake_engine 
    VERSION 0.0.1
    DESCRIPTION "snake game engine"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

#Options
option(BUILD_SHARED_LIBS "BUILD SHARE LIBRARIES" OFF)
option(SNAKE_ENGINE_BUILD_TESTS "BUILD TESTS" OFF)
option(SNAKE_ENGINE_BUILD_DOCS "BUILD DOCS" OFF)

#compile options
if(MSVC)
    add_compile_options(/W4 /WX)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

#library sources
set(LIBRARY_SOURCES
    src/engine.cpp
    include/snake_engine/engine.hpp
)


add_library(${PROJECT_NAME} ${LIBRARY_SOURCES})

target_include_directories(${PROJECT_NAME} 
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)

#setting external dependencies
include(Dependencies.cmake)
setup_depencies()
include(${CMAKE_TOOLCHAIN_FILE})

find_package(Raylib CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)

target_link_libraries(
    ${PROJECT_NAME}
    PUBLIC
    fmt::fmt
    raylib
)

#installation
include(GNUInstallDirs)
install(
    TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
    DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(
    EXPORT ${PROJECT_NAME}Targets
    FILE ${PROJECT_NAME}Targets.cmake
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

#generate package configure
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "${PROJECT_NAME}ConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/${PROJECT_NAME}config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)
install(
    FILES
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_DIR}/cmake/${PROJECT_NAME}
)

#testing
if(SNAKE_ENGINE_BUILD_TESTS)
    enable_testing()
    add_subdirectory(test)
endif()

#documentation
if(SNAKE_ENGINE_BUILD_DOCS)
    find_package(Doxygen REQUIRED)
    add_subdirectory(docs)
endif()


