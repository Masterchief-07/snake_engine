set(RAYLIB_VERSION 5.0)
find_package(raylib 5.0 QUIET)
if(NOT raylib_FOUND)
    include(FetchContent)
    FetchContent_Declare(
        raylib
        DOWNLOAD_EXTRACT_TIMESTAMP OFF
        URL https://github.com/raysan5/raylib/archive/refs/tags/${RAYLIB_VERSION}.tar.gz
    )
    FetchContent_GetProperties(raylib)
    if (NOT raylib_POPULATED)
        set(FETCHCONTENT_QUIET NO)
        FetchContent_MakeAvailable(raylib)
        set(BUILD_EXAMPES OFF CACHE BOOL "" FORCE)
    endif()
endif()

find_package(catch2 QUIET)
if(NOT catch2_FOUND)
    include(FetchContent)
    FetchContent_Declare(
        Catch2
        GIT_SHALLOW TRUE
        GIT_REPOSITORY https://github.com/catchorg/Catch2.git
        GIT_TAG v3.7.1
    )
    FetchContent_GetProperties(Catch2)
    if (NOT catch2_POPULATED)
        set(FETCHCONTENT_QUIET NO)
        FetchContent_MakeAvailable(Catch2)
    endif()
endif()
