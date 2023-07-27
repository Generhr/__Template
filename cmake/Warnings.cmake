function(target_set_warnings TARGET) #: https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Avai
    set(MSVC_WARNINGS
        /permissive- # Enforces standards conformance.
        /W4 # All reasonable warnings
        /w14640 # Enable warning on thread un-safe static member initialization
        /w14242 # 'identfier': conversion from 'type1' to 'type1', possible loss of data
        /w14254 # 'operator': conversion from 'type1:field_bits' to 'type2:field_bits', possible loss of data
        /w14263 # 'function': member function does not override any base class virtual member function
        /w14265 # 'classname': class has virtual functions, but destructor is not virtual instances of this class may not be destructed correctly
        /w14287 # 'operator': unsigned/negative constant mismatch
        /we4289 # nonstandard extension used: 'variable': loop control variable declared in the for-loop is used outside the for-loop scope
        /w14296 # 'operator': expression is always 'boolean_value'
        /w14311 # 'variable': pointer truncation from 'type1' to 'type2'
        /w14545 # expression before comma evaluates to a function which is missing an argument list
        /w14546 # function call before comma missing argument list
        /w14547 # 'operator': operator before comma has no effect; expected operator with side-effect
        /w14549 # 'operator': operator before comma has no effect; did you intend 'operator'?
        /w14555 # expression has no effect; expected expression with side- effect
        /w14619 # pragma warning: there is no warning number 'number'
        /w14826 # Conversion from 'type1' to 'type_2' is sign-extended. This may cause unexpected runtime behavior.
        /w14905 # wide string literal cast to 'LPSTR'
        /w14906 # string literal cast to 'LPWSTR'
        /w14928 # illegal copy-initialization; more than one user-defined conversion has been implicitly applied
    )

    set(CLANG_WARNINGS
        -Wall # reasonable and standard
        -Wextra # reasonable and standard
        -Wshadow # warn the user if a variable declaration shadows one from a parent context
        -Wnon-virtual-dtor # warn the user if a class with virtual functions has a non-virtual destructor. This helps catch hard to track down memory errors
        -Wold-style-cast # warn for c-style casts
        -Wcast-align # warn for potential performance problem casts
        -Wunused # warn on anything being unused
        -Woverloaded-virtual # warn if you overload (not override) a virtual function
        -Wpedantic # (all versions of GCC, Clang >= 3.2) warn if non-standard C++ is used
        -Wconversion # warn on type conversions that may lose data
        -Wsign-conversion # (Clang all versions, GCC >= 4.3) warn on sign conversions
        -Wdouble-promotion # (GCC >= 4.6, Clang >= 3.8) warn if float is implicit promoted to double
        -Wformat=2 # warn on security issues around functions that format output (i.e. printf)
    )

    set(GCC_WARNINGS
        ${CLANG_WARNINGS}
        -Wmisleading-indentation # (only in GCC >= 6.0) warn if indentation implies blocks where blocks do not exist
        -Wduplicated-cond # (only in GCC >= 6.0) warn if if / else chain has duplicated conditions
        -Wduplicated-branches # (only in GCC >= 7.0) warn if if / else branches have duplicated code
        -Wlogical-op # (only in GCC) warn about logical operations being used where bitwise were probably wanted
        -Wnull-dereference # (only in GCC >= 6.0) warn if a null dereference is detected
        -Wuseless-cast # (only in GCC >= 4.8) warn if you perform a cast to the same type
    )

    if(ENABLE_WARNINGS_AS_ERRORS)
        list(APPEND MSVC_WARNINGS /WX)
        list(APPEND CLANG_WARNINGS -Werror)
        list(APPEND GCC_WARNINGS -Werror)
    endif()

    if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        set(PROJECT_WARNINGS_CXX ${MSVC_WARNINGS})
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(PROJECT_WARNINGS_CXX ${CLANG_WARNINGS})
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        set(PROJECT_WARNINGS_CXX ${GCC_WARNINGS})
    else()
        message(WARNING "No compiler warnings set for '${CMAKE_CXX_COMPILER_ID}' compiler.")
    endif()

    # use the same warning flags for C.
    set(PROJECT_WARNINGS_C "${PROJECT_WARNINGS_CXX}")

    if(NOT TARGET ${TARGET})
        message(WARNING "${TARGET} is not a target, thus no compiler warnings were added.")
    else()
        message(STATUS "* warnings enabled with warnings treated as errors ${ENABLE_WARNINGS_AS_ERRORS}")

        target_compile_options(${TARGET} INTERFACE $<$<COMPILE_LANGUAGE:CXX>:${PROJECT_WARNINGS_CXX}> $<$<COMPILE_LANGUAGE:C>:${PROJECT_WARNINGS_C}>)
    endif()
endfunction(target_set_warnings)
