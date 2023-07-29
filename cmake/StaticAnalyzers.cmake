macro(enable_cppcheck)
    find_program(CPPCHECK NAMES "cppcheck")

    if(CPPCHECK)
        message(STATUS "'${CPPCHECK}' found and enabled")

        # Set export commands on for use with `--project`
        #set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

        if(CMAKE_GENERATOR MATCHES ".*Visual Studio.*")
            set(CPPCHECK_TEMPLATE "vs")
        else()
            set(CPPCHECK_TEMPLATE "gcc")
        endif()

        # Get the number of processors to speed up linting
        include(ProcessorCount)
        ProcessorCount(PROCESSOR_COUNT)

        if(PROCESSOR_COUNT EQUAL 0)
            set(PROCESSOR_COUNT 1)
        endif()

        if("${CPPCHECK_OPTIONS}" STREQUAL "")
            set(CMAKE_CXX_CPPCHECK
                ${CPPCHECK}
                "--enable=warning,style,performance,portability" # Enable additional checks.
                "--std=c++${CMAKE_CXX_STANDARD}" # Set standard.
                #"--project=compile_commands.json" # (Optional) Specifices the json file created by MAKE_EXPORT_COMPILE_COMMANDS which outlines the code structure.
                "--force" # Force checking of files that have a lot of configurations. Error is printed if such a file is found so there is no reason to use this by default. If used together with `--max-configs=`, the last option is the one that is effective.
                "--inconclusive" # Allow that Cppcheck reports even though the analysis is inconclusive. There are false positives with this option. Each result must be carefully investigated before you know if it is good or bad.
                "--suppressions-list=${CMAKE_CURRENT_SOURCE_DIR}/cppcheck-suppressions.txt" # (Optional) Suppress warnings listed in the file. The format of is: `[error id]:[filename]:[line]`. The `[filename]` and `[line]` are optional. `[error id]` may be `*` to suppress all warnings (for a specified file or files). `[filename]` may contain the wildcard characters `*` or `?`.
                "--inline-suppr" # (Optional) Enable inline suppressions. Use them by placing comments in the form: `// cppcheck-suppress memleak` before the line to suppress.
                "--template=${CPPCHECK_TEMPLATE}" # Format the error messages (Pre-defined templates: gcc, vs).
                #"--quiet" # (Optional) Only print something when there is an error.
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
    find_program(CLANG_TIDY NAMES "clang-tidy")

    if(CLANG_TIDY)
        if(NOT CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
            message(WARNING "clang-tidy found but it will not play nice with GCC pre-compiled headers so it will not be enabled")

            return()
        endif()

        message(STATUS "'${CLANG_TIDY}' found and enabled")

        # Export compile commands on for use with `-p`
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON) # Note: This command only works with Ninja or Makefile generators.

        #: https://clang.llvm.org/extra/clang-tidy/
        set(CLANG_TIDY_OPTIONS "${CLANG_TIDY}" -p=${CMAKE_BINARY_DIR} --extra-arg=-Wno-unknown-warning-option --extra-arg=-Wno-ignored-optimization-argument --extra-arg=-Wno-unused-command-line-argument)

        #Set standard
        if(NOT "${CMAKE_CXX_STANDARD}" STREQUAL "")
            if("${CLANG_TIDY_OPTIONS_DRIVER_MODE}" STREQUAL "cl")
                set(CLANG_TIDY_OPTIONS ${CLANG_TIDY_OPTIONS} --extra-arg=/std:c++${CMAKE_CXX_STANDARD})
            else()
                set(CLANG_TIDY_OPTIONS ${CLANG_TIDY_OPTIONS} --extra-arg=-std=c++${CMAKE_CXX_STANDARD})
            endif()
        endif()

        if(${ENABLE_WARNINGS_AS_ERRORS})
            set(CLANG_TIDY_OPTIONS ${CLANG_TIDY_OPTIONS} --warnings-as-errors=*)
        endif()

        #set(CLANG_TIDY_COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/tools/clang-tidy-wrapper.bat;${CLANG_TIDY_OPTIONS}" CACHE STRING "A combined command to run clang-tidy with caching wrapper") #~ https://github.com/matus-chochlik/ctcache
        #set(CTCACHE_DIR "C:/Users/Onimuru/.local/bin/cache")

        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_OPTIONS}")
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
