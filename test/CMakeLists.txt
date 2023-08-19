cmake_minimum_required(VERSION 3.16...3.27 FATAL_ERROR)

#==========  Project Details  ==================================================#

project(${CMAKE_PROJECT_NAME}Tests LANGUAGES CXX C)

#========== Add Unit Test(s) ==================================================#

file(GLOB_RECURSE TEST_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)

if(USE_GOOGLE_MOCK)
    set(GOOGLE_MOCK_LIBRARIES GTest::gmock_main)
endif()

set(TEST_LIBRARIES GTest::gtest_main # `gtest_main` forgoes the need for a unit test with a `main()` function and to then include each test file within that unit test.
                   ${GOOGLE_MOCK_LIBRARIES} TESTING_LIBRARY
)

foreach(TEST_FILE ${TEST_FILES})
    string(REGEX REPLACE "(.*/)([a-zA-Z0-9_ ]+)(\.cpp)" "\\2" TEST_NAME ${TEST_FILE})

    add_executable(${TEST_NAME} ${TEST_FILE})

    message(STATUS "Created ${TEST_NAME} binary")

    set_target_properties(
        ${TEST_NAME}
        PROPERTIES CXX_STANDARD ${CMAKE_CXX_STANDARD}
                   CXX_STANDARD_REQUIRED 17
                   CXX_EXTENSIONS NO
                   RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}
                   EXCLUDE_FROM_ALL TRUE
                   EXCLUDE_FROM_DEFAULT_BUILD TRUE
    )

    message(STATUS "* using standard C++${CMAKE_CXX_STANDARD}")

    if(ENABLE_WARNINGS)
        target_set_warnings(${TEST_NAME})
    endif()

    target_link_libraries(${TEST_NAME} PRIVATE ${TEST_LIBRARIES})

    #~ gtest_discover_tests: https://cmake.org/cmake/help/latest/module/GoogleTest.html#command:gtest_discover_tests
    gtest_discover_tests(
        ${TEST_NAME}
        PROPERTIES
        TIMEOUT 10
    ) #? CMake 3.10+

    list(APPEND TEST_NAMES "${TEST_NAME}")
endforeach()

add_custom_target(unit_tests DEPENDS ${TEST_NAMES})

if(ENABLE_CODE_COVERAGE)
    foreach(TEST_NAME ${TEST_NAMES}) #~ codecov-bash: https://github.com/codecov/codecov-bash/blob/master/codecov
        append_coverage_compiler_flags_to_target(${TEST_NAME})

        add_custom_command(
            TARGET unit_tests
            POST_BUILD
            #~ CTest Command-Line Reference: https://manpages.ubuntu.com/manpages/xenial/en/man1/ctest.1.html
            COMMAND ctest -C $<CONFIGURATION> --quiet -j ${PROCESSOR_COUNT} # `ctest` must be run prior to
            #~ llvm-profdata: https://llvm.org/docs/CommandGuide/llvm-profdata.html
            COMMAND llvm-profdata merge
                    -sparse # The `-sparse` option is a trade-off between memory efficiency and profile data accuracy. Use it when you want to manage the size of the profile data file while still maintaining reasonable accuracy for your profiling or coverage analysis needs.
                    default.profraw -o coverage.profdata
            #~ llvm-cov: https://llvm.org/docs/CommandGuide/llvm-cov.html
            COMMAND llvm-cov show "${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${TEST_NAME}.exe" -instr-profile=coverage.profdata > ${CMAKE_BINARY_DIR}/coverage_${TEST_NAME}.txt -j ${PROCESSOR_COUNT}
            WORKING_DIRECTORY "${PROJECT_BINARY_DIR}"
            COMMENT "Generating code coverage report"
        )
    endforeach()
endif()

message(STATUS "Created `unit_tests` build target that will build all tests found in ${CMAKE_CURRENT_SOURCE_DIR} (${TEST_NAMES})")
