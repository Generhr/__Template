function(target_set_warnings TARGET) #: https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Avai
    set(MSVC_WARNINGS
        /W4 # Baseline reasonable warnings
        /permissive- # standards conformance mode for MSVC compiler.
        /w14242 # 'identifier': conversion from 'type1' to 'type1', possible loss of data
        /w14254 # 'operator': conversion from 'type1:field_bits' to 'type2:field_bits', possible loss of data
        /w14263 # 'function': member function does not override any base class virtual member function
        /w14265 # 'classname': class has virtual functions, but destructor is not virtual instances of this class may not be destructed correctly
        /w14287 # 'operator': unsigned/negative constant mismatch
        /w14296 # 'operator': expression is always 'boolean_value'
        /w14311 # 'variable': pointer truncation from 'type1' to 'type2'
        /w14545 # expression before comma evaluates to a function which is missing an argument list
        /w14546 # function call before comma missing argument list
        /w14547 # 'operator': operator before comma has no effect; expected operator with side-effect
        /w14549 # 'operator': operator before comma has no effect; did you intend 'operator'?
        /w14555 # expression has no effect; expected expression with side- effect
        /w14619 # pragma warning: there is no warning number 'number'
        /w14640 # Enable warning on thread un-safe static member initialization
        /w14826 # Conversion from 'type1' to 'type_2' is sign-extended. This may cause unexpected runtime behavior.
        /w14905 # wide string literal cast to 'LPSTR'
        /w14906 # string literal cast to 'LPWSTR'
        /w14928 # illegal copy-initialization; more than one user-defined conversion has been implicitly applied
        /we4289 # nonstandard extension used: 'variable': loop control variable declared in the for-loop is used outside the for-loop scope
    )

    set(CLANG_WARNINGS
        -Wall
        -Wcast-align # warn for potential performance problem casts
        -Wconversion # warn on type conversions that may lose data
        -Wdouble-promotion # warn if float is implicit promoted to double
        -Wextra # reasonable and standard
        -Wformat=2 # warn on security issues around functions that format output (ie printf)
        -Wnon-virtual-dtor # warn the user if a class with virtual functions has a non-virtual destructor. This helps catch hard to track down memory errors
        -Wnull-dereference # warn if a null dereference is detected
        -Wold-style-cast # warn for c-style casts
        -Woverloaded-virtual # warn if you overload (not override) a virtual function
        -Wpedantic # warn if non-standard C++ is used
        -Wshadow # warn the user if a variable declaration shadows one from a parent context
        -Wsign-conversion # warn on sign conversions
        -Wunused # warn on anything being unused
    )

    set(GCC_WARNINGS
        ${CLANG_WARNINGS}
        -Wduplicated-branches # warn if if / else branches have duplicated code
        -Wduplicated-cond # warn if if / else chain has duplicated conditions
        -Wlogical-op # warn about logical operations being used where bitwise were probably wanted
        -Wmisleading-indentation # warn if indentation implies blocks where blocks do not exist
        -Wuseless-cast # warn if you perform a cast to the same type
    )

    if(ENABLE_WARNINGS_AS_ERRORS)
        set(MSVC_WARNINGS ${MSVC_WARNINGS} /WX)
        set(CLANG_WARNINGS ${CLANG_WARNINGS} -Werror)
        set(CLANG_WARNINGS ${CLANG_WARNINGS} -Werror)
    endif()

    if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        set(COMPILER_WARNINGS ${MSVC_WARNINGS})
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(COMPILER_WARNINGS ${CLANG_WARNINGS})
    elseif(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
        set(COMPILER_WARNINGS ${GCC_WARNINGS})
    else()
        message(AUTHOR_WARNING "No compiler warnings set for '${CMAKE_CXX_COMPILER_ID}' compiler.")
    endif()

    if(NOT TARGET ${TARGET})
        message(AUTHOR_WARNING "${TARGET} is not a target, thus no compiler warnings were added.")
    else()
        message(STATUS "Warnings enabled on ${TARGET} with warnings treated as errors ${ENABLE_WARNINGS_AS_ERRORS}")

        if(BUILD_HEADERS_ONLY)
            target_compile_options(${TARGET} INTERFACE ${COMPILER_WARNINGS})
        else()
            target_compile_options(${TARGET} PRIVATE ${COMPILER_WARNINGS})
        endif()
    endif()
endfunction(target_set_warnings)
