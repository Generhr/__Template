include(CMakeDependentOption)

option(VERBOSE_OUTPUT "Enable verbose output, allowing for a better understanding of each step taken." OFF)

option(ENABLE_CPPCHECK "Enable static analysis with cppcheck." OFF)
option(ENABLE_CLANG_TIDY "Enable static analysis with clang-tidy." OFF)
option(ENABLE_INCLUDE_WHAT_YOU_USE "Enable static analysis with include what you use." OFF)

cmake_dependent_option(ENABLE_STATIC_ANALYZERS "" OFF "NOT (ENABLE_CPPCHECK OR ENABLE_CLANG_TIDY OR ENABLE_INCLUDE_WHAT_YOU_USE)" ON)
mark_as_advanced(ENABLE_STATIC_ANALYZERS)

option(ENABLE_SANITIZE_ADDR "Enable address sanitize." OFF)
option(ENABLE_SANITIZE_UNDEF "Enable undefined sanitize." OFF)
option(ENABLE_SANITIZE_LEAK "Enable leak sanitize (Gcc/Clang only)." OFF)
option(ENABLE_SANITIZE_THREAD "Enable thread sanitize (Gcc/Clang only)." OFF)

cmake_dependent_option(ENABLE_IPO "Enable Interprocedural Optimization, aka Link Time Optimization." ON "PROJECT_IS_TOP_LEVEL" OFF)

option(ENABLE_WARNINGS "Enable to add compiler warnings." ON)
option(ENABLE_WARNINGS_AS_ERRORS "Enable to treat compiler warnings as errors." OFF)

option(BUILD_HEADERS_ONLY "Build the project as a header-only library." OFF)
option(BUILD_EXECUTABLE "Build the project as an executable, rather than a library." ON)
option(BUILD_SHARED_LIBS "Build libraries as shared as opposed to static." OFF)

option(ENABLE_TESTING "Enable to create a unit test build target (unit_tests)." OFF)
option(ENABLE_CODE_COVERAGE "Enable to create a Code Coverage build target (coverage)." OFF)

option(ENABLE_DOXYGEN "Enable to create a doxygen build target (doxygen)." OFF)

if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
        VERBOSE_OUTPUT
        ENABLE_CPPCHECK
        ENABLE_CLANG_TIDY
        ENABLE_INCLUDE_WHAT_YOU_USE
        ENABLE_SANITIZE_ADDR
        ENABLE_SANITIZE_UNDEF
        ENABLE_SANITIZE_LEAK
        ENABLE_SANITIZE_THREAD
        ENABLE_IPO
        ENABLE_WARNINGS
        ENABLE_WARNINGS_AS_ERRORS
        BUILD_HEADERS_ONLY
        BUILD_EXECUTABLE
        BUILD_SHARED_LIBS
        ENABLE_TESTING
        ENABLE_CODE_COVERAGE
        ENABLE_DOXYGEN
    )
endif()
