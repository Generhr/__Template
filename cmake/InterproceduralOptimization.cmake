include(CheckIPOSupported)

check_ipo_supported(RESULT IS_SUPPORTED OUTPUT ERROR_DETAILS)

if(IS_SUPPORTED)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)

    message(STATUS "Interprocedural optimization enabled")
else()
    message(SEND_ERROR "Interprocedural optimization is not supported: ${ERROR_DETAILS}.")
endif()
