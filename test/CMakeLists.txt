cmake_minimum_required(VERSION 3.21...3.27 FATAL_ERROR)

#==========  Project Details  ==================================================#

project(${CMAKE_PROJECT_NAME}Tests LANGUAGES CXX C)

#==========  CMake Variables  ==================================================#

set(CURRENT_BINARY_DIR "${PROJECT_BINARY_DIR}/${CMAKE_BUILD_TYPE}")

#========== Add Unit Test(s) ==================================================#

file(GLOB_RECURSE TEST_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)

foreach(TEST_FILE ${TEST_FILES})
    string(REGEX REPLACE "(.*/)([a-zA-Z0-9_ ]+)(\.cpp)" "\\2" TEST_NAME ${TEST_FILE})

    add_executable(${TEST_NAME} ${TEST_FILE})

    message(STATUS "Created ${TEST_NAME} binary")

    set_target_properties(
        ${TEST_NAME}
        PROPERTIES CXX_STANDARD ${CMAKE_CXX_STANDARD}
                   CXX_STANDARD_REQUIRED 17
                   CXX_EXTENSIONS NO
                   RUNTIME_OUTPUT_DIRECTORY ${CURRENT_BINARY_DIR}
                   EXCLUDE_FROM_ALL TRUE
                   EXCLUDE_FROM_DEFAULT_BUILD TRUE
    )

    message(STATUS "* using standard C++${CMAKE_CXX_STANDARD}")

    if(ENABLE_WARNINGS)
        target_set_warnings(${TEST_NAME})
    endif()

    # Check if this test file requires gmock
    file(READ ${TEST_FILE} TEST_FILE_CONTENTS)

    if(TEST_FILE_CONTENTS MATCHES "#[ \t]*include[ \t]*[\"<]gmock/gmock\\.h[\">]")
        target_link_libraries(${TEST_NAME} PRIVATE TESTING_LIBRARY GTest::gmock_main)
    else()
        target_link_libraries(${TEST_NAME} PRIVATE TESTING_LIBRARY GTest::gtest_main # `gtest_main` forgoes the need for a unit test with a `main()` function and to then include each test file within that unit test.
        )
    endif()

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
    if(WIN32)
        set(OUTPUT_REDIRECT > NUL 2>&1)
    elseif(APPLE OR UNIX)
        set(OUTPUT_REDIRECT > /dev/null 2>&1)
    endif()

    foreach(TEST_NAME ${TEST_NAMES}) #~ codecov-bash: https://github.com/codecov/codecov-bash/blob/master/codecov
        add_custom_command(
            TARGET unit_tests
            POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E env LLVM_PROFILE_FILE=${TEST_NAME}.profraw $<TARGET_FILE:${TEST_NAME}> ${OUTPUT_REDIRECT}
            COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/Coverage"
            #~ llvm-profdata: https://llvm.org/docs/CommandGuide/llvm-profdata.html
            COMMAND llvm-profdata merge -sparse "${TEST_NAME}.profraw" -o "${TEST_NAME}.profdata"
            #~ llvm-cov: https://llvm.org/docs/CommandGuide/llvm-cov.html
            COMMAND llvm-cov show $<TARGET_FILE:${TEST_NAME}> -instr-profile="${TEST_NAME}.profdata" > "${CMAKE_BINARY_DIR}/Coverage/coverage_${TEST_NAME}.txt" -j ${PROCESSOR_COUNT}
            COMMAND llvm-cov report $<TARGET_FILE:${TEST_NAME}> -instr-profile="${TEST_NAME}.profdata" > "${CMAKE_BINARY_DIR}/Coverage/${TEST_NAME}.report" -j ${PROCESSOR_COUNT}
            WORKING_DIRECTORY "${CURRENT_BINARY_DIR}"
            COMMENT "Generating code coverage report for ${TEST_NAME}.exe"
        )
    endforeach()
endif()

message(STATUS "Created `unit_tests` build target that will build all tests found in ${CMAKE_CURRENT_SOURCE_DIR} (${TEST_NAMES})")
