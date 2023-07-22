# Add Analyze with CppCheck target if CppCheck is installed
if(WIN32) #~ https://gist.github.com/bjornblissing/60c2d425532e6dd534841a8d1d2ffe76
    # Find the cppcheck executable
    find_program(
        CMAKE_CXX_CPPCHECK cppcheck
        NAMES cppcheck
        HINTS $ENV{PROGRAMFILES}/cppcheck
    )

    if(CMAKE_CXX_CPPCHECK) # If CppCheck executable found
        set(CPP_CHECK_CMD ${CMAKE_CXX_CPPCHECK} --version) # Check CppCheck version

        execute_process(
            COMMAND ${CPP_CHECK_CMD}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            RESULT_VARIABLE CPP_CHECK_RESULT
            OUTPUT_VARIABLE CPP_CHECK_VERSION
            ERROR_VARIABLE CPP_CHECK_ERROR
        )

        if(CPP_CHECK_RESULT EQUAL 0) # Check if version could be extracted
            include(ProcessorCount)

            ProcessorCount(CPU_CORES) # Get number of CPU cores

            add_custom_target(
                cppcheck
                COMMAND ${CMAKE_CXX_CPPCHECK}
                        "--template \"${CMAKE_SOURCE_DIR}/{file}({line}): {severity} ({id}): {message}\"" # Using the this template will allow jumping to any found error from inside Visual Studio output window by double clicking
                        "--quiet" # Only show found errors
                        "--enable=style,performance,warning,portability" # Desired warning level in CppCheck
                        "--std=c++${CMAKE_CXX_STANDARD}" # Optional: Specified C++ version
                        "--platform=win64" # Optional: Specified platform
                        "--suppress=cppcheckError" "--suppress=internalAstError" "--suppressions-list=${CMAKE_SOURCE_DIR}/cppcheck-suppressions.txt" # Optional: suppression file stored in same directory as the top level CMake script
                        "--inline-suppr" # Optional: Use inline suppressions
                        "-j ${CPU_CORES}" # Use all the available CPU cores
                        "-ibuild" "-iexternal" "." # Run CppCheck from the working directory, as specified in the add_custom_target command below
                WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
                COMMENT "Static code analysis using ${CPP_CHECK_VERSION}"
            )

            set_target_properties(cppcheck PROPERTIES EXCLUDE_FROM_ALL TRUE EXCLUDE_FROM_DEFAULT_BUILD TRUE)
        endif()
    endif()
endif()
