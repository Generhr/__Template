macro(enable_cppcheck)
    find_program(CPPCHECK cppcheck)

    if(CPPCHECK)
        message(STATUS "'${CPPCHECK}' found and enabled")

        if(CMAKE_GENERATOR MATCHES ".*Visual Studio.*")
            set(CPPCHECK_TEMPLATE "vs")
        else()
            set(CPPCHECK_TEMPLATE "gcc")
        endif()

        if(NOT CPPCHECK_OPTIONS)
            # Set export commands on for use with `--project`
            set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

            foreach(FILE_PATH ${SKIP_LINTING_LIST})
                get_filename_component(FILE_NAME ${FILE_PATH} NAME)

                list(APPEND SUPPRESS_FILES "--suppress=*:*${FILE_NAME}")
            endforeach()

            set(CMAKE_CXX_CPPCHECK
                ${CPPCHECK}
                "--enable=warning,style,performance,portability" # Enable additional checks.
                "--std=c++${CMAKE_CXX_STANDARD}" # Set standard.
                "--project=compile_commands.json" # (Optional) Specifices the json file created by MAKE_EXPORT_COMPILE_COMMANDS which outlines the code structure (see: https://github.com/danmar/cppcheck/blob/main/man/manual.md#cmake).
                "--inconclusive" # Allow that Cppcheck reports even though the analysis is inconclusive. There are false positives with this option. Each result must be carefully investigated before you know if it is good or bad.
                "--suppressions-list=${CMAKE_CURRENT_SOURCE_DIR}/cppcheck-suppressions.txt" # (Optional) Suppress warnings listed in the file. The format of is: `[error id]:[filename]:[line]`. The `[filename]` and `[line]` are optional. `[error id]` may be `*` to suppress all warnings (for a specified file or files). `[filename]` may contain the wildcard characters `*` or `?`.
                ${SUPPRESS_FILES}
                "--inline-suppr" # (Optional) Enable inline suppressions. Use them by placing comments in the form: `// cppcheck-suppress memleak` before the line to suppress.
                "--template=${CPPCHECK_TEMPLATE}" # Format the error messages (Pre-defined templates: gcc, vs).
                "--cppcheck-build-dir=build" # (Optional) Using a Cppcheck build folder is not mandatory but it is recommended (see: https://github.com/danmar/cppcheck/blob/main/man/manual.md#cppcheck-build-dir).
                #"--check-level=exhaustive" # Exhaustive checking level should be useful for scenarios where you can wait for results.
                #"--performance-valueflow-max-if-count=60" # (Optional) Adjusts the max count for number of if in a function.
                "--quiet" # (Optional) Only print something when there is an error.
                #"--verbose"  # (Optional) More detailed error reports.
                "-j ${PROCESSOR_COUNT}" # (Optional) Start x amount of threads to do the checking work.
            )
        else()
            # If the user provides a CPPCHECK_OPTIONS with a template specified, it will override this template
            set(CMAKE_CXX_CPPCHECK ${CPPCHECK} --template=${CPPCHECK_TEMPLATE} ${CPPCHECK_OPTIONS})
        endif()

        if(NOT "${CMAKE_CXX_STANDARD}" STREQUAL "")
            set(CMAKE_CXX_CPPCHECK ${CMAKE_CXX_CPPCHECK} --std=c++${CMAKE_CXX_STANDARD})
        endif()

        if(${ENABLE_WARNINGS_AS_ERRORS})
            list(APPEND CMAKE_CXX_CPPCHECK --error-exitcode=2)
        endif()
    else()
        message(WARNING "cppcheck is enabled but the executable was not found")
    endif()
endmacro()

macro(enable_clang_tidy)
    get_filename_component(CLANG_TIDY_EXE_HINT "${CMAKE_CXX_COMPILER}" PATH)

    find_program(
        CLANG_TIDY_EXE
        NAMES "clang-tidy"
        HINTS ${CLANG_TIDY_EXE_HINT}
    )

    if(CLANG_TIDY_EXE)
        message(STATUS "'${CLANG_TIDY_EXE}' found and enabled")

        set(OPTIONS)
        set(SINGLE_VALUE_ARGS)
        set(MULTI_VALUE_ARGS EXTRA_ARGS CLANG_ARGS)

        cmake_parse_arguments(PARSE "${OPTIONS}" "${SINGLE_VALUE_ARGS}" "${MULTI_VALUE_ARGS}" ${ARGN})

        function(find_clang_tidy_version VAR)
            execute_process(COMMAND ${CLANG_TIDY_EXE} -version OUTPUT_VARIABLE VERSION_OUTPUT)
            separate_arguments(VERSION_OUTPUT_LIST UNIX_COMMAND "${VERSION_OUTPUT}")
            list(FIND VERSION_OUTPUT_LIST "version" VERSION_INDEX)

            if(VERSION_INDEX GREATER 0)
                math(EXPR VERSION_INDEX "${VERSION_INDEX} + 1")
                list(GET VERSION_OUTPUT_LIST ${VERSION_INDEX} VERSION)
                set(${VAR}
                    ${VERSION}
                    PARENT_SCOPE
                )
            else()
                set(${VAR}
                    "0.0"
                    PARENT_SCOPE
                )
            endif()
        endfunction()

        find_clang_tidy_version(CLANG_TIDY_VERSION)

        # Export compile commands on for use with `-p`
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # NOTE: This command only works with Ninja or Makefile generators.

        if(MSVC)
            list(APPEND CLANG_TIDY_EXTRA_ARGS --extra-arg=/std:c++${CMAKE_CXX_STANDARD} --extra-arg=/EHsc # Specify the exception handling model to allow for `try, catch, throw, ...`
            )
        else()
            set(CLANG_TIDY_EXTRA_ARGS --extra-arg=-std=c++${CMAKE_CXX_STANDARD})
        endif()

        foreach(ARG ${PARSE_EXTRA_ARGS})
            list(APPEND CLANG_TIDY_EXTRA_ARGS --extra-arg=${ARG})
        endforeach()

        foreach(ARG ${PARSE_CLANG_ARGS})
            list(APPEND CLANG_TIDY_EXTRA_ARGS --extra-arg=-Xclang --extra-arg=${ARG})
        endforeach()

        if(WIN32 # This stipulation is only here because I'm using a .bat file to pass the args on to ctcache, this can easily be implemented on other OS
           AND EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/external/ctcache/clang-tidy-cache"
        )
            set(CLANG_TIDY_COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/tools/clang-tidy-cache-wrapper.bat" "-p=${CMAKE_BINARY_DIR}" "${CLANG_TIDY_EXTRA_ARGS}")

            function(find_all_directories_with_clang_tidy VARIABLE)
                file(GLOB CLANG_TIDY_FILES "${CMAKE_CURRENT_SOURCE_DIR}/.clang-tidy")

                if(CLANG_TIDY_FILES)
                    list(APPEND DIRECTORIES_WITH_CLANG_TIDY ${CMAKE_CURRENT_SOURCE_DIR})
                endif()

                file(GLOB ALL_PROJECT_FILES
                     LIST_DIRECTORIES true
                     "${CMAKE_CURRENT_SOURCE_DIR}/*"
                )

                foreach(DIRECTORY ${ALL_PROJECT_FILES})
                    if(IS_DIRECTORY ${DIRECTORY})
                        get_filename_component(DIR_NAME ${DIRECTORY} NAME)

                        if(NOT DIR_NAME STREQUAL "build")
                            # Check if the directory contains a .clang-tidy file
                            file(GLOB CLANG_TIDY_FILES "${DIRECTORY}/.clang-tidy")

                            # If so, add the directory to `DIRECTORIES_WITH_CLANG_TIDY`
                            if(CLANG_TIDY_FILES)
                                list(APPEND DIRECTORIES_WITH_CLANG_TIDY ${DIRECTORY})
                            endif()
                        endif()
                    endif()
                endforeach()

                # CMake splits args up with ";" so use "*" to keep all the directories together, folders can't contain "*" in their name so this should be safe
                string(REPLACE ";" "*" DIRECTORIES_WITH_CLANG_TIDY "${DIRECTORIES_WITH_CLANG_TIDY}")

                set(${VARIABLE}
                    ${DIRECTORIES_WITH_CLANG_TIDY}
                    PARENT_SCOPE
                )
            endfunction()

            find_all_directories_with_clang_tidy(DIRECTORIES_WITH_CLANG_TIDY)

            if(DIRECTORIES_WITH_CLANG_TIDY)
                list(APPEND CLANG_TIDY_COMMAND --directories_with_clang_tidy=${DIRECTORIES_WITH_CLANG_TIDY})
            endif()
        else()
            #~ https://clang.llvm.org/extra/clang-tidy/
            set(CLANG_TIDY_COMMAND "${CLANG_TIDY_EXE}" "-p=${CMAKE_BINARY_DIR}" "${CLANG_TIDY_EXTRA_ARGS}")
        endif()

        if(NOT WIN32 AND ${CLANG_TIDY_VERSION} VERSION_GREATER_EQUAL "4.0.0")
            list(APPEND CLANG_TIDY_COMMAND -quiet)
        endif()

        if(${ENABLE_WARNINGS_AS_ERRORS} AND ${CLANG_TIDY_VERSION} VERSION_GREATER_EQUAL "3.9.0")
            list(APPEND CLANG_TIDY_COMMAND -warnings-as-errors=*)
        endif()

        set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY_COMMAND})
    else()
        message(WARNING "clang-tidy is enabled but the executable was not found")
    endif()
endmacro()

macro(enable_include_what_you_use)
    find_program(INCLUDE_WHAT_YOU_USE NAMES "include-what-you-use")

    if(INCLUDE_WHAT_YOU_USE)
        message(STATUS "'${INCLUDE_WHAT_YOU_USE}' found and enabled")

        set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${INCLUDE_WHAT_YOU_USE}")
    else()
        message(WARNING "Include What You Use is enabled but the executable was not found")
    endif()
endmacro()
