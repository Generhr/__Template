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

    gtest_discover_tests(
        ${TEST_NAME}
        PROPERTIES
        TIMEOUT 10
    ) #? CMake 3.10+

    list(APPEND TEST_NAMES "${TEST_NAME}")
endforeach()

add_custom_target(unit_tests DEPENDS ${TEST_NAMES})

message(STATUS "Created `unit_tests` build target that will build all tests found in ${CMAKE_CURRENT_SOURCE_DIR} (${TEST_NAMES})")
