macro(enable_cppcheck)
    find_program(CPPCHECK cppcheck)

    if(CPPCHECK)
        message(STATUS "'${CPPCHECK}' found and enabled")

        # Set export commands on
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

        if(CMAKE_GENERATOR MATCHES ".*Visual Studio.*")
            set(CPPCHECK_TEMPLATE "vs")
        else()
            set(CPPCHECK_TEMPLATE "gcc")
        endif()

        # Get amount of processors to speed up linting
        include(ProcessorCount)
        ProcessorCount(CPU_CORES) # Get number of CPU cores

        if(CPU_CORES EQUAL 0)
            set(CPU_CORES 1)
        endif()

        if("${CPPCHECK_OPTIONS}" STREQUAL "")
            # Enable all warnings that are actionable by the user of this toolset
            # style should enable the other 3, but we'll be explicit just in case
            set(CMAKE_CXX_CPPCHECK
                ${CPPCHECK}
                "--template=${CPPCHECK_TEMPLATE}"
                "--enable=style,performance,warning,portability" # Desired warning level in CppCheck
                "--quiet" # Only show found errors
                "--inline-suppr" # (Optional) Use inline suppressions
                "--suppress=cppcheckError" # We cannot act on a bug/missing feature of cppcheck
                "--suppress=internalAstError"
                "--suppress=unmatchedSuppression" # If a file does not have an internalAstError, we get an unmatchedSuppression error
                "--suppress=passedByValue" # Noisy and incorrect sometimes
                "--suppress=syntaxError" # Ignores code that cppcheck thinks is invalid C++
                "--suppress=preprocessorErrorDirective"
                "--suppressions-list=${CMAKE_CURRENT_SOURCE_DIR}/cppcheck-suppressions.txt" # (Optional) Suppression file stored in same directory as the top level CMake script
                "--inconclusive"
                "-j ${CPU_CORES}" # Use all the available CPU cores
            )
        else()
            # if the user provides a CPPCHECK_OPTIONS with a template specified, it will override this template
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
    find_program(CLANG_TIDY clang-tidy)

    if(CLANG_TIDY)
        message(STATUS "'${CLANG_TIDY}' found and enabled")

        # Set export commands on
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

        #: https://clang.llvm.org/extra/clang-tidy/
        set(CLANG_TIDY_OPTIONS "${CLANG_TIDY}" "--extra-arg=-Wno-unknown-warning-option" "--extra-arg=-Wno-ignored-optimization-argument" "--extra-arg=-Wno-unused-command-line-argument")

        if(${ENABLE_WARNINGS_AS_ERRORS})
            set(CLANG_TIDY_OPTIONS "${CLANG_TIDY_OPTIONS}" "--warnings-as-errors=*")
        endif()

        set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_OPTIONS}")
    else()
        message(WARNING "clang-tidy is enabled but the executable was not found")
    endif()
endmacro()

macro(enable_include_what_you_use)
    find_program(INCLUDE_WHAT_YOU_USE include-what-you-use)

    if(INCLUDE_WHAT_YOU_USE)
        message(STATUS "'${INCLUDE_WHAT_YOU_USE}' found and enabled")

        set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${INCLUDE_WHAT_YOU_USE}")
    else()
        message(WARNING "include-what-you-use is enabled but the executable was not found")
    endif()
endmacro()
