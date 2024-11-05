include(CMakePrintHelpers)

# Define vcpkg version to use
set(VCPKG_VERSION "2024.02.14" CACHE STRING "Version of vcpkg to use")
option(USE_SYSTEM_VCPKG "Use system-installed vcpkg instead of downloading" OFF)
option(VCPKG_VERBOSE "Enable verbose output for vcpkg operations" OFF)

function(setup_dependencies)
    # Early return if toolchain is already configured
    if(DEFINED CMAKE_TOOLCHAIN_FILE AND EXISTS "${CMAKE_TOOLCHAIN_FILE}")
        message(STATUS "Using existing toolchain file: ${CMAKE_TOOLCHAIN_FILE}")
        return()
    endif()

    # Check for system vcpkg first if enabled
    if(USE_SYSTEM_VCPKG)
        find_program(VCPKG_EXECUTABLE vcpkg)
        if(VCPKG_EXECUTABLE)
            get_filename_component(VCPKG_ROOT "${VCPKG_EXECUTABLE}" DIRECTORY)
            set(VCPKG_ROOT "${VCPKG_ROOT}" CACHE PATH "Path to vcpkg installation")
            message(STATUS "Using system vcpkg at: ${VCPKG_ROOT}")
        else()
            message(WARNING "System vcpkg not found, falling back to downloaded version")
        endif()
    endif()

    # Proceed with vcpkg download if needed
    if(NOT DEFINED VCPKG_ROOT OR NOT EXISTS "${VCPKG_ROOT}")
        set(VCPKG_BOOTSTRAP_SCRIPT "bootstrap-vcpkg" CACHE STRING "")
        if(WIN32)
            set(VCPKG_BOOTSTRAP_SCRIPT "${VCPKG_BOOTSTRAP_SCRIPT}.bat")
        else()
            set(VCPKG_BOOTSTRAP_SCRIPT "${VCPKG_BOOTSTRAP_SCRIPT}.sh")
        endif()

        # Configure vcpkg download
        include(FetchContent)
        FetchContent_Declare(
            vcpkg
            GIT_REPOSITORY https://github.com/Microsoft/vcpkg.git
            GIT_TAG "${VCPKG_VERSION}"
            GIT_SHALLOW 1
            CONFIGURE_COMMAND ""
            BUILD_COMMAND ""
        )

        # Download vcpkg
        message(STATUS "Downloading vcpkg...")
        FetchContent_GetProperties(vcpkg)
        if(NOT vcpkg_POPULATED)
            FetchContent_Populate(vcpkg)
        endif()

        # Set VCPKG_ROOT to the downloaded location
        set(VCPKG_ROOT "${vcpkg_SOURCE_DIR}" CACHE PATH "Path to vcpkg installation")
    endif()

    # Ensure the bootstrap script is executable on Unix-like systems
    if(UNIX)
        execute_process(
            COMMAND chmod +x "${VCPKG_ROOT}/${VCPKG_BOOTSTRAP_SCRIPT}"
            RESULT_VARIABLE CHMOD_RESULT
        )
        if(NOT CHMOD_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to make bootstrap script executable")
        endif()
    endif()

    # Bootstrap vcpkg with error handling and logging
    if(NOT EXISTS "${VCPKG_ROOT}/vcpkg${CMAKE_EXECUTABLE_SUFFIX}")
        message(STATUS "Bootstrapping vcpkg...")
        
        # Prepare bootstrap command
        set(BOOTSTRAP_COMMAND "${CMAKE_COMMAND}" -E chdir "${VCPKG_ROOT}" "./${VCPKG_BOOTSTRAP_SCRIPT}")
        if(VCPKG_VERBOSE)
            list(APPEND BOOTSTRAP_COMMAND --verbose)
        endif()

        # Execute bootstrap
        execute_process(
            COMMAND ${BOOTSTRAP_COMMAND}
            RESULT_VARIABLE VCPKG_BOOTSTRAP_RESULT
            OUTPUT_VARIABLE VCPKG_BOOTSTRAP_OUTPUT
            ERROR_VARIABLE VCPKG_BOOTSTRAP_ERROR
            OUTPUT_STRIP_TRAILING_WHITESPACE
            ERROR_STRIP_TRAILING_WHITESPACE
        )

        # Handle bootstrap results
        if(VCPKG_BOOTSTRAP_RESULT EQUAL 0)
            if(VCPKG_VERBOSE)
                message(STATUS "vcpkg bootstrap output: ${VCPKG_BOOTSTRAP_OUTPUT}")
            endif()
        else()
            message(FATAL_ERROR "Failed to bootstrap vcpkg:\n${VCPKG_BOOTSTRAP_ERROR}")
        endif()
    endif()

    # Set up vcpkg toolchain file
    set(VCPKG_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")
    if(NOT EXISTS "${VCPKG_TOOLCHAIN_FILE}")
        message(FATAL_ERROR "vcpkg toolchain file not found at: ${VCPKG_TOOLCHAIN_FILE}")
    endif()

    # Configure global vcpkg settings
    set(CMAKE_TOOLCHAIN_FILE "${VCPKG_TOOLCHAIN_FILE}"
        CACHE STRING "Vcpkg toolchain file" FORCE)
    
    # Set additional vcpkg configuration options
    set(VCPKG_FEATURE_FLAGS "versions" CACHE STRING "vcpkg feature flags")
    set(VCPKG_INSTALL_OPTIONS "--no-print-usage" CACHE STRING "vcpkg install options")
    
    if(VCPKG_VERBOSE)
        cmake_print_variables(
            VCPKG_ROOT
            CMAKE_TOOLCHAIN_FILE
            VCPKG_FEATURE_FLAGS
            VCPKG_INSTALL_OPTIONS
        )
    endif()

    message(STATUS "vcpkg setup completed successfully")
endfunction()

# Optional helper function to install dependencies
function(install_dependencies)
    foreach(PACKAGE IN LISTS ARGN)
        message(STATUS "Installing dependency: ${PACKAGE}")
        execute_process(
            COMMAND "${VCPKG_ROOT}/vcpkg" install "${PACKAGE}"
            RESULT_VARIABLE INSTALL_RESULT
        )
        if(NOT INSTALL_RESULT EQUAL 0)
            message(FATAL_ERROR "Failed to install ${PACKAGE}")
        endif()
    endforeach()
endfunction()
