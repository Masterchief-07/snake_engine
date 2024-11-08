cmake_minimum_required(VERSION 3.28)
project(snake_engine 
    VERSION 0.0.1
    DESCRIPTION "snake game engine"
    LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

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
    src/snake.cpp
    src/playground.cpp
    include/snake_engine/engine.hpp
    include/snake_engine/snake.hpp
    include/snake_engine/playground.hpp
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
setup_dependencies()
install_dependencies("fmt" "raylib" "catch2" "glfw3")
#include(${CMAKE_TOOLCHAIN_FILE})

find_package(raylib CONFIG REQUIRED)
find_package(glfw3 CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)

target_include_directories(${PROJECT_NAME} PUBLIC ${RAYLIB_INCLUDE_DIR})

target_link_libraries(
    ${PROJECT_NAME}
    PRIVATE
    fmt::fmt
    glfw
    raylib
)

if(NOT PROJECT_IS_TOP_LEVEL)
    return()
endif()

include(CTest)

if(BUILD_TESTING)
    add_subdirectory(test)
endif()



