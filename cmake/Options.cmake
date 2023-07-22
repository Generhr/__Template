include(CMakeDependentOption)

option(USE_CONAN "Enable the Conan package manager for this project." OFF)
option(USE_VCPKG "Enable the vcpkg package manager for this project." ON)

option(ENABLE_DOXYGEN "Enable to create a doxygen build target (doxygen)." OFF)

option(ENABLE_CODE_ANALYSIS "Enable to create a static analysis build target (cppcheck)." ON)

option(ENABLE_SANITIZE_ADDR "Enable address sanitize." OFF)
option(ENABLE_SANITIZE_UNDEF "Enable undefined sanitize." OFF)
option(ENABLE_SANITIZE_LEAK "Enable leak sanitize (Gcc/Clang only)." OFF)
option(ENABLE_SANITIZE_THREAD "Enable thread sanitize (Gcc/Clang only)." OFF)

cmake_dependent_option(ENABLE_IPO "Enable Interprocedural Optimization, aka Link Time Optimization." ON "PROJECT_IS_TOP_LEVEL" OFF)

option(ENABLE_WARNINGS "Enable to add compiler warnings." ON)
option(ENABLE_WARNINGS_AS_ERRORS "Enable to treat compiler warnings as errors." OFF)

option(VERBOSE_OUTPUT "Enable verbose output, allowing for a better understanding of each step taken." ON)

option(BUILD_HEADERS_ONLY "Build the project as a header-only library." OFF)
option(BUILD_EXECUTABLE "Build the project as an executable, rather than a library." ON)
option(BUILD_SHARED_LIBS "Build libraries as shared as opposed to static." OFF)

cmake_dependent_option(ENABLE_TESTING "Enable to create a unit test build target (unit_tests)." ON "NOT BUILD_TESTING" OFF)
option(USE_GOOGLE_MOCK "Use the GoogleMock project for extending the unit tests." OFF)
option(ENABLE_CODE_COVERAGE "Enable to create a Code Coverage build target (coverage)." OFF)

if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
        USE_CONAN
        USE_VCPKG
        ENABLE_DOXYGEN
        ENABLE_CODE_ANALYSIS
        ENABLE_SANITIZE_ADDR
        ENABLE_SANITIZE_UNDEF
        ENABLE_SANITIZE_LEAK
        ENABLE_SANITIZE_THREAD
        ENABLE_IPO
        ENABLE_WARNINGS
        ENABLE_WARNINGS_AS_ERRORS
        VERBOSE_OUTPUT
        BUILD_HEADERS_ONLY
        BUILD_EXECUTABLE
        BUILD_SHARED_LIBS
        ENABLE_TESTING
        USE_GOOGLE_MOCK
        ENABLE_CODE_COVERAGE
    )
endif()
