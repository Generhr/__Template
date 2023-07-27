function(enable_ipo)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT IS_SUPPORTED OUTPUT ERROR_DETAILS)

    if(IS_SUPPORTED)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)

        message(STATUS "IPO enabled")
    else()
        message(SEND_ERROR "IPO is not supported: ${ERROR_DETAILS}.")
    endif()
endfunction()
