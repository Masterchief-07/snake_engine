CMAKE_MINIMUM_REQUIRED(VERSION 3.28)

PROJECT(SNAKE_TESTS LANGUAGES CXX)

if (PROJECT_IS_TOP_LEVEL OR TEST_INSTALLED_VERSION)
    enable_testing()
    find_package(snake_engine CONFIG REQUIRED)

    if (NOT TARGET snake_engine_options)
        message(FATAL_ERROR "snake_engine package not found")
        return()
    endif()
endif()

find_package(Catch2 CONFIG REQUIRED)
find_package(raylib CONFIG REQUIRED)
message(STATUS "CATCH2_DIR: ${Catch2_DIR}")
include(${Catch2_DIR}/Catch.cmake)

add_test(NAME cli.has_help COMMAND intro --help)

add_executable(
    tests
    test.cpp
)

target_link_libraries(
    tests
    PRIVATE
    snake_engine
    Catch2::Catch2WithMain
)

catch_discover_tests(
    tests
    TEST_PREFIX
    "unittests."
    REPORTER
    XML
    OUTPUT_DIR
    .
    OUTPUT_PREFIX
    "unittests."
    OUTPUT_SUFFIX
    .xml
)

add_executable(
    test_gui
    snake_run.cpp
)

target_include_directories(
    test_gui
    PUBLIC
    ${SNAKE_ENGINE_INCLUDE_DIR}
)

target_link_libraries(
    test_gui
    PRIVATE
    snake_engine
    raylib
    glfw
)
