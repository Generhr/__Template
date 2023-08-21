function(find_program_version PROGRAM)
    set(OPTIONS QUIET REQUIRED)
    set(SINGLE_VALUE_ARGS GREATER GREATER_EQUAL LESS LESS_EQUAL EQUAL OUTPUT_VARIABLE)
    set(MULTI_VALUE_ARGS)

    cmake_parse_arguments(PARSE "${OPTIONS}" "${SINGLE_VALUE_ARGS}" "${MULTI_VALUE_ARGS}" ${ARGN})

    if(NOT DEFINED PARSE_OUTPUT_VARIABLE)
        set(PARSE_OUTPUT_VARIABLE "${PROGRAM}_VERSION")
    endif()

    execute_process(
        COMMAND ${PROGRAM} --version
        RESULT_VARIABLE PROC_RESULT
        OUTPUT_VARIABLE EVAL_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

    if(NOT PROC_RESULT EQUAL "0")
        set(${PARSE_OUTPUT_VARIABLE}
            "0.0.0"
            PARENT_SCOPE
        )
        set(${PARSE_OUTPUT_VARIABLE}_OK
            FALSE
            PARENT_SCOPE
        )

        if(PARSE_REQUIRED)
            message(FATAL_ERROR "Could not determine the version of required program ${PROGRAM}.")
        elseif(NOT PARSE_QUIET)
            message(WARNING "Could not determine the version of program ${PROGRAM}.")
        endif()
    else()
        string(REGEX MATCH "[0-9]+(\\.[^ \t\r\n]+)*" PROGRAM_VERSION "${EVAL_RESULT}")
        set(${PARSE_OUTPUT_VARIABLE}
            "${PROGRAM_VERSION}"
            PARENT_SCOPE
        )
        set(${PARSE_OUTPUT_VARIABLE}_OK
            TRUE
            PARENT_SCOPE
        )

        foreach(COMP GREATER GREATER_EQUAL LESS LESS_EQUAL EQUAL)
            if(DEFINED PARSE_${COMP} AND NOT PROGRAM_VERSION VERSION_${COMP} PARSE_${COMP})
                set(${PARSE_OUTPUT_VARIABLE}_OK
                    FALSE
                    PARENT_SCOPE
                )
            endif()
        endforeach()
    endif()
endfunction()
