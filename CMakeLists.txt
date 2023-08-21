cmake_minimum_required(VERSION 3.21...3.27 FATAL_ERROR) #? 3.21 - PROJECT_IS_TOP_LEVEL

#==========  Project Details  ==================================================#

# NOTE: update this with your new project's details.

project("__Name"
        VERSION "0.1.0" # NOTE: Listing the version is nice here since it sets lots of useful variables.
        DESCRIPTION "__Description"
        HOMEPAGE_URL "__Url"
        LANGUAGES CXX C # NOTE: To support external libraries, it's good practice to list both CXX and C.
)

#============  Safe Guards  ====================================================#

include(cmake/SafeGuards.cmake)
variable_watch(CMAKE_BUILD_TYPE readonly_guard)

#==========  CMake Variables  ==================================================#

message(STATUS "\n-- Configuring CMake for ${PROJECT_NAME} v${PROJECT_VERSION}...\n--")

# Only do these if this is the main project, and not if it is included through add_subdirectory:
if(PROJECT_IS_TOP_LEVEL)
    if(NOT DEFINED CMAKE_CXX_STANDARD)
        set(CMAKE_CXX_STANDARD # NOTE: GoogleTest requires at least C++14.
            20
            CACHE STRING "The C++ standard to use."
        )
    endif()

    # Require C++17 features like if constexpr:
    set(CMAKE_CXX_STANDARD_REQUIRED 17)

    set(CMAKE_CXX_EXTENSIONS OFF) # NOTE: While this is generally a good practice, you should ensure that this setting doesn't cause any issues with third-party libraries or the project's requirements.
    set(CMAKE_C_EXTENSIONS OFF)
endif()

# Suppress generation of the ZERO_CHECK build target:
set(CMAKE_SUPPRESS_REGENERATION true)

set(CMAKE_COLOR_DIAGNOSTICS ON)

# Find number of processors
include(ProcessorCount)
ProcessorCount(PROCESSOR_COUNT)

if(PROCESSOR_COUNT EQUAL 0)
    set(PROCESSOR_COUNT 1)
endif()

set(GIT_SHA
    "Unknown"
    CACHE STRING "SHA this build was generated from"
)
string(SUBSTRING "${GIT_SHA}" 0 8 GIT_SHORT_SHA)

#=======  Manual File Additions  ===============================================#

set(CPP_SUPPRESS_LIST # List of files to exclude from cppcheck static analysis
)

set(CLANG_TIDY_SUPPRESS_LIST # List of files to exclude from clang-tidy static analysis
    "${CMAKE_CURRENT_SOURCE_DIR}/src/ClangTidyWarnings.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/include/ClangTidyWarnings.h"
)

set(PRECOMPILED_HEADER_LIST # List of files to exclude from cppcheck and clang-tidy static analysis
    "${CMAKE_CURRENT_SOURCE_DIR}/include/pch.h"
)

set(MANUAL_HEADER_LIST # List of files to be added manually (not in include/*)
)

set(MANUAL_SOURCE_LIST # List of files to be added manually (not in src/*.cpp)
)

#====  Define CMake Module Imports  ============================================#

include(CMakeParseArguments)

include(cmake/Options.cmake)

include(cmake/Utilities.cmake)

include(cmake/UpdateSubmodules.cmake)

include(cmake/Cache.cmake)
enable_cache()

if(ENABLE_STATIC_ANALYZERS)
    include(cmake/StaticAnalyzers.cmake)

    if(ENABLE_CPPCHECK)
        enable_cppcheck()
    endif()

    if(ENABLE_CLANG_TIDY)
        enable_clang_tidy()
    endif()

    if(ENABLE_INCLUDE_WHAT_YOU_USE)
        enable_include_what_you_use()
    endif()
endif()

if(ENABLE_SANITIZE_ADDR OR ENABLE_SANITIZE_UNDEF)
    include(cmake/Sanitize.cmake)
    add_sanitizer_flags()
endif()

if(ENABLE_IPO)
    include(cmake/InterproceduralOptimization.cmake)
    enable_ipo()
endif()

include(cmake/Warnings.cmake)

set(VCPKG_BUILD_DOCS OFF)
set(VCPKG_BUILD_TESTS OFF)
set(VCPKG_BUILD_EXAMPLES OFF)

if(VERBOSE_OUTPUT)
    set(VCPKG_VERBOSE ON)
else()
    list(APPEND VCPKG_INSTALL_OPTIONS "--no-print-usage") #: https://learn.microsoft.com/en-us/vcpkg/commands/install
endif()

option(VCPKG_APPLOCAL_DEPS "Automatically copy dependencies into the output directory for executables." ON)

include(${CMAKE_SOURCE_DIR}/external/vcpkg/scripts/buildsystems/vcpkg.cmake)

#============== OS Fixes ======================================================#

# This will allow the use of the same _DEBUG macro available in both Linux and Windows environment. Easy to put Debug specific code:
if(UNIX)
    add_compile_options("$<$<CONFIG:DEBUG>:-D_DEBUG>")
endif()

#==========  Configure Files  ==================================================#

add_subdirectory(configure)

# Move any textures so that they are relative to the executable
file(GLOB_RECURSE COPY_FILES "res/*")
file(COPY ${COPY_FILES} DESTINATION "${CMAKE_BINARY_DIR}/bin/res")

#========== Add Source Files ==================================================#

add_subdirectory(external EXCLUDE_FROM_ALL)

set(WINDOWS_HEADERS_NEEDED_BY_CLANG_LIST)

if("${CMAKE_CXX_COMPILER_ID}" MATCHES "[Cc]lang")
    set(WINDOWS_HEADERS_NEEDED_BY_CLANG_LIST "$ENV{EXTERNAL_INCLUDE}")
endif()

# NOTE: globbing sources is considered bad practice as CMake's generators may not detect new files automatically. Keep that in mind when changing files, or explicitly mention them in the relevant `*_LIST` variables

file(GLOB_RECURSE HEADER_LIST include/*)
list(REMOVE_ITEM HEADER_LIST ${PRECOMPILED_HEADER_LIST})
list(APPEND HEADER_LIST ${MANUAL_HEADER_LIST})
list(REMOVE_DUPLICATES HEADER_LIST)

if(ENABLE_CLANG_TIDY)
    list(REMOVE_ITEM HEADER_LIST ${CLANG_TIDY_SUPPRESS_LIST})
endif()

file(GLOB_RECURSE SOURCE_LIST src/*.cpp)
list(REMOVE_ITEM SOURCE_LIST "${CMAKE_CURRENT_SOURCE_DIR}/src/Main.cpp")
list(APPEND SOURCE_LIST ${MANUAL_SOURCE_LIST})
list(REMOVE_DUPLICATES SOURCE_LIST)

if(ENABLE_CLANG_TIDY)
    list(REMOVE_ITEM SOURCE_LIST ${CLANG_TIDY_SUPPRESS_LIST})
endif()

#===========  Create Target  ===================================================#

# Delete all cmake files from previous builds
add_custom_target(clean_build_folder COMMAND git clean -d -f -x)

if(ENABLE_CLANG_TIDY AND CLANG_TIDY_SUPPRESS_LIST)
    # Create an object library with source files from `CLANG_TIDY_SUPPRESS_LIST` and reset its `CMAKE_CXX_CLANG_TIDY` property to prevent clang-tidy analysis.
    add_library(CLANG_TIDY_SUPPRESS_LIBRARY OBJECT "${CLANG_TIDY_SUPPRESS_LIST}")
    set_target_properties(CLANG_TIDY_SUPPRESS_LIBRARY PROPERTIES CXX_CLANG_TIDY "")
    target_include_directories(CLANG_TIDY_SUPPRESS_LIBRARY PRIVATE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>")
endif()

# Main executable
if(BUILD_HEADERS_ONLY)
    add_library(${PROJECT_NAME} INTERFACE)

    if(TARGET CLANG_TIDY_SUPPRESS_LIBRARY)
        target_sources(${PROJECT_NAME} INTERFACE "$<TARGET_OBJECTS:CLANG_TIDY_SUPPRESS_LIBRARY>")
    endif()

    if(VERBOSE_OUTPUT)
        message(STATUS "Created ${PROJECT_NAME} interface library with the following headers:")

        foreach(HEADER IN LISTS HEADER_LIST)
            message(STATUS "* ${HEADER}")
        endforeach()
    else()
        message(STATUS "Created ${PROJECT_NAME} interface library")
    endif()
elseif(BUILD_EXECUTABLE)
    add_executable(${PROJECT_NAME} "${CMAKE_CURRENT_SOURCE_DIR}/src/Main.cpp" "${SOURCE_LIST}" "${HEADER_LIST}") # NOTE: Including header files here helps IDEs but is not required.

    if(TARGET CLANG_TIDY_SUPPRESS_LIBRARY)
        target_sources(${PROJECT_NAME} PRIVATE "$<TARGET_OBJECTS:CLANG_TIDY_SUPPRESS_LIBRARY>")
    endif()

    if(VERBOSE_OUTPUT)
        message(STATUS "Created ${PROJECT_NAME} binary with the following sources:")
        message(STATUS "* ${CMAKE_CURRENT_SOURCE_DIR}/src/Main.cpp")

        foreach(SOURCE IN LISTS SOURCE_LIST)
            message(STATUS "* ${SOURCE}")
        endforeach()
    else()
        message(STATUS "Created ${PROJECT_NAME} binary")
    endif()
else()
    add_library(${PROJECT_NAME} "${SOURCE_LIST}" "${HEADER_LIST}")

    if(TARGET CLANG_TIDY_SUPPRESS_LIBRARY)
        target_sources(${PROJECT_NAME} PUBLIC "$<TARGET_OBJECTS:CLANG_TIDY_SUPPRESS_LIBRARY>")
    endif()

    if(VERBOSE_OUTPUT)
        message(STATUS "Created ${PROJECT_NAME} static library with the following sources:")

        foreach(SOURCE IN LISTS SOURCE_LIST)
            message(STATUS "* ${SOURCE}")
        endforeach()

        message(STATUS "and the following headers:")

        foreach(HEADER IN LISTS HEADER_LIST)
            message(STATUS "* ${HEADER}")
        endforeach()
    else()
        message(STATUS "Created ${PROJECT_NAME} static library")
    endif()
endif()

if(BUILD_HEADERS_ONLY)
    target_include_directories(${PROJECT_NAME} INTERFACE "${WINDOWS_HEADERS_NEEDED_BY_CLANG_LIST}" $<INSTALL_INTERFACE:include> $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)
else()
    target_include_directories(
        ${PROJECT_NAME}
        PUBLIC "${WINDOWS_HEADERS_NEEDED_BY_CLANG_LIST}" "$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>"
        PRIVATE "${CMAKE_BINARY_DIR}/configured_files/include"
    )
endif()

#=====  Set Standard and Warnings  =============================================#

set_target_properties(
    ${PROJECT_NAME}
    PROPERTIES CXX_STANDARD ${CMAKE_CXX_STANDARD}
               CXX_STANDARD_REQUIRED 17
               CXX_EXTENSIONS NO
               RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
               LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
               ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

message(STATUS "* using standard C++${CMAKE_CXX_STANDARD}")

if(ENABLE_WARNINGS)
    target_set_warnings(${PROJECT_NAME})
endif()

#========  Compile Definitions  ================================================#

if(${CMAKE_CXX_COMPILER} MATCHES "cl.exe")
    if(BUILD_HEADERS_ONLY)
        target_compile_options(${PROJECT_NAME} INTERFACE /EHsc)
    else()
        target_compile_options(${PROJECT_NAME} PRIVATE /EHsc)
    endif()
endif()

string(TOUPPER "${PROJECT_NAME}_DEBUG" PROJECT_DEBUG_DEFINE)
target_compile_definitions(${PROJECT_NAME} PRIVATE ${PROJECT_DEBUG_DEFINE})

#=========  Link Dependencies  =================================================#

# Precompile headers
if(NOT ENABLE_CLANG_TIDY OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    target_precompile_headers(${PROJECT_NAME} PRIVATE "$<$<COMPILE_LANGUAGE:CXX>:${PRECOMPILED_HEADER_LIST}>")
endif()

find_package(cxxopts CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)
find_package(nlohmann_json CONFIG REQUIRED)
find_package(spdlog CONFIG REQUIRED)

target_link_libraries(${PROJECT_NAME} PRIVATE nlohmann_json::nlohmann_json fmt::fmt spdlog::spdlog cxxopts::cxxopts)

#===========  Alias Targets  ===================================================#

if(BUILD_EXECUTABLE)
    add_executable(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
else()
    add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
endif()

#========= Unit Testing Setup =================================================#

if(PROJECT_IS_TOP_LEVEL)
    if(ENABLE_TESTING)
        include(CTest)

        add_library(TESTING_LIBRARY INTERFACE)

        if(ENABLE_CODE_COVERAGE)
            include(cmake/CodeCoverage.cmake)
            append_coverage_compiler_flags_to_target(TESTING_LIBRARY)
        endif()

        if(TARGET CLANG_TIDY_SUPPRESS_LIBRARY)
            target_sources(TESTING_LIBRARY INTERFACE "${SOURCE_LIST}" "${HEADER_LIST}" "$<TARGET_OBJECTS:CLANG_TIDY_SUPPRESS_LIBRARY>")
        else()
            target_sources(TESTING_LIBRARY INTERFACE "${SOURCE_LIST}" "${HEADER_LIST}") # NOTE: Including header files here helps IDEs but is not required.
        endif()

        target_include_directories(TESTING_LIBRARY INTERFACE "${WINDOWS_HEADERS_NEEDED_BY_CLANG_LIST}" "${CMAKE_CURRENT_SOURCE_DIR}/include")

        set_target_properties(
            TESTING_LIBRARY
            PROPERTIES CXX_STANDARD ${CMAKE_CXX_STANDARD}
                       CXX_STANDARD_REQUIRED 17
                       CXX_EXTENSIONS NO
        )

        if(${CMAKE_CXX_COMPILER} MATCHES "cl.exe")
            target_compile_options(TESTING_LIBRARY INTERFACE /EHsc)
        endif()

        string(TOUPPER "${PROJECT_NAME}_TEST" PROJECT_TEST_DEFINE)
        target_compile_definitions(TESTING_LIBRARY INTERFACE ${PROJECT_TEST_DEFINE})

        if(NOT ENABLE_CLANG_TIDY OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
            target_precompile_headers(TESTING_LIBRARY INTERFACE "$<$<COMPILE_LANGUAGE:CXX>:${PRECOMPILED_HEADER_LIST}>")
        endif()

        find_package(GTest CONFIG REQUIRED)
        include(GoogleTest)

        mark_as_advanced(
            BUILD_GMOCK
            BUILD_GTEST
            BUILD_SHARED_LIBS
            gmock_build_tests
            gtest_build_samples
            gtest_build_tests
            gtest_disable_pthreads
            gtest_force_shared_crt
            gtest_hide_internal_symbols
        )

        add_subdirectory(test)
    endif()
endif()

#==============  Doxygen  ======================================================#

if(ENABLE_DOXYGEN)
    include(cmake/Doxygen.cmake)
    enable_doxygen()
endif()

#==============  Install  ======================================================#

include(GNUInstallDirs)

# Determine the installation directory for headers and libraries (the CMAKE_INSTALL_* variables are defined by the GNUInstallDirs module):
set(INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}-${PROJECT_VERSION}")
set(INSTALL_BIN_DIR "${CMAKE_INSTALL_BINDIR}")
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_LIBDIR}")
