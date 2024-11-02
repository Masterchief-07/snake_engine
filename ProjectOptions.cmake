include(cmake/SystemLink.cmake)
include(cmake/LibFuzzer.cmake)
include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(snake_engine_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(snake_engine_setup_options)
  option(snake_engine_ENABLE_HARDENING "Enable hardening" ON)
  option(snake_engine_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    snake_engine_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    snake_engine_ENABLE_HARDENING
    OFF)

  snake_engine_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR snake_engine_PACKAGING_MAINTAINER_MODE)
    option(snake_engine_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(snake_engine_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(snake_engine_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(snake_engine_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(snake_engine_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(snake_engine_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(snake_engine_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(snake_engine_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(snake_engine_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(snake_engine_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(snake_engine_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(snake_engine_ENABLE_PCH "Enable precompiled headers" OFF)
    option(snake_engine_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(snake_engine_ENABLE_IPO "Enable IPO/LTO" ON)
    option(snake_engine_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(snake_engine_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(snake_engine_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(snake_engine_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(snake_engine_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(snake_engine_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(snake_engine_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(snake_engine_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(snake_engine_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(snake_engine_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(snake_engine_ENABLE_PCH "Enable precompiled headers" OFF)
    option(snake_engine_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      snake_engine_ENABLE_IPO
      snake_engine_WARNINGS_AS_ERRORS
      snake_engine_ENABLE_USER_LINKER
      snake_engine_ENABLE_SANITIZER_ADDRESS
      snake_engine_ENABLE_SANITIZER_LEAK
      snake_engine_ENABLE_SANITIZER_UNDEFINED
      snake_engine_ENABLE_SANITIZER_THREAD
      snake_engine_ENABLE_SANITIZER_MEMORY
      snake_engine_ENABLE_UNITY_BUILD
      snake_engine_ENABLE_CLANG_TIDY
      snake_engine_ENABLE_CPPCHECK
      snake_engine_ENABLE_COVERAGE
      snake_engine_ENABLE_PCH
      snake_engine_ENABLE_CACHE)
  endif()

  snake_engine_check_libfuzzer_support(LIBFUZZER_SUPPORTED)
  if(LIBFUZZER_SUPPORTED AND (snake_engine_ENABLE_SANITIZER_ADDRESS OR snake_engine_ENABLE_SANITIZER_THREAD OR snake_engine_ENABLE_SANITIZER_UNDEFINED))
    set(DEFAULT_FUZZER ON)
  else()
    set(DEFAULT_FUZZER OFF)
  endif()

  option(snake_engine_BUILD_FUZZ_TESTS "Enable fuzz testing executable" ${DEFAULT_FUZZER})

endmacro()

macro(snake_engine_global_options)
  if(snake_engine_ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    snake_engine_enable_ipo()
  endif()

  snake_engine_supports_sanitizers()

  if(snake_engine_ENABLE_HARDENING AND snake_engine_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR snake_engine_ENABLE_SANITIZER_UNDEFINED
       OR snake_engine_ENABLE_SANITIZER_ADDRESS
       OR snake_engine_ENABLE_SANITIZER_THREAD
       OR snake_engine_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${snake_engine_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${snake_engine_ENABLE_SANITIZER_UNDEFINED}")
    snake_engine_enable_hardening(snake_engine_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(snake_engine_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(snake_engine_warnings INTERFACE)
  add_library(snake_engine_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  snake_engine_set_project_warnings(
    snake_engine_warnings
    ${snake_engine_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(snake_engine_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    snake_engine_configure_linker(snake_engine_options)
  endif()

  include(cmake/Sanitizers.cmake)
  snake_engine_enable_sanitizers(
    snake_engine_options
    ${snake_engine_ENABLE_SANITIZER_ADDRESS}
    ${snake_engine_ENABLE_SANITIZER_LEAK}
    ${snake_engine_ENABLE_SANITIZER_UNDEFINED}
    ${snake_engine_ENABLE_SANITIZER_THREAD}
    ${snake_engine_ENABLE_SANITIZER_MEMORY})

  set_target_properties(snake_engine_options PROPERTIES UNITY_BUILD ${snake_engine_ENABLE_UNITY_BUILD})

  if(snake_engine_ENABLE_PCH)
    target_precompile_headers(
      snake_engine_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(snake_engine_ENABLE_CACHE)
    include(cmake/Cache.cmake)
    snake_engine_enable_cache()
  endif()

  include(cmake/StaticAnalyzers.cmake)
  if(snake_engine_ENABLE_CLANG_TIDY)
    snake_engine_enable_clang_tidy(snake_engine_options ${snake_engine_WARNINGS_AS_ERRORS})
  endif()

  if(snake_engine_ENABLE_CPPCHECK)
    snake_engine_enable_cppcheck(${snake_engine_WARNINGS_AS_ERRORS} "" # override cppcheck options
    )
  endif()

  if(snake_engine_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    snake_engine_enable_coverage(snake_engine_options)
  endif()

  if(snake_engine_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(snake_engine_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(snake_engine_ENABLE_HARDENING AND NOT snake_engine_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR snake_engine_ENABLE_SANITIZER_UNDEFINED
       OR snake_engine_ENABLE_SANITIZER_ADDRESS
       OR snake_engine_ENABLE_SANITIZER_THREAD
       OR snake_engine_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    snake_engine_enable_hardening(snake_engine_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()
