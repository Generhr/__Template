# Check supported compiler (Clang)
get_property(LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)

foreach(LANGUAGE ${LANGUAGES})
    if(${LANGUAGE} STREQUAL "RC")
        continue() # Skip the Resource Compiler language
    endif()

    if("${CMAKE_${LANGUAGE}_COMPILER_ID}" MATCHES "[Cc]lang")
        if("${CMAKE_${LANGUAGE}_COMPILER_VERSION}" VERSION_LESS 3)
            message(FATAL_ERROR "Clang version must be 3.0.0 or greater!")
        endif()
    else()
        message(FATAL_ERROR "Only Clang compiler is supported for code coverage analysis.")
    endif()
endforeach()

set(COVERAGE_COMPILER_FLAGS
    # Compiler flags for code coverage analysis
    #? -fprofile-instr-generate: Generates instrumentation code for code coverage analysis
    #? -fcoverage-mapping: Generates coverage mapping information for code coverage reports
    "-fprofile-instr-generate -fcoverage-mapping"
    CACHE INTERNAL ""
)

if(CMAKE_CXX_COMPILER_ID MATCHES "[Cc]lang")
    include(CheckCXXCompilerFlag)

    check_cxx_compiler_flag(-fprofile-abs-path HAVE_FPROFILE_ABS_PATH)

    if(HAVE_FPROFILE_ABS_PATH)
        #? -fprofile-abs-path: Stores absolute file paths in the coverage data
        set(COVERAGE_COMPILER_FLAGS "${COVERAGE_COMPILER_FLAGS} -fprofile-abs-path")
    endif()
endif()

# Set compiler flags for coverage builds
set(CMAKE_C_FLAGS_COVERAGE
    ${COVERAGE_COMPILER_FLAGS}
    CACHE STRING "Flags used by the C compiler during coverage builds." FORCE
)
set(CMAKE_CXX_FLAGS_COVERAGE
    ${COVERAGE_COMPILER_FLAGS}
    CACHE STRING "Flags used by the C++ compiler during coverage builds." FORCE
)

set(CMAKE_EXE_LINKER_FLAGS_COVERAGE
    # Linker flags for coverage builds
    #? -fprofile-instr-generate: Ensures proper linking with code coverage instrumentation
    "-fprofile-instr-generate"
    CACHE STRING "Flags used for linking binaries during coverage builds." FORCE
)
set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE
    ""
    CACHE STRING "Flags used by the shared libraries linker during coverage builds." FORCE
)

# Warn if coverage analysis is done with optimized build
get_property(GENERATOR_IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

if(NOT
   (CMAKE_BUILD_TYPE STREQUAL "Debug"
    OR NOT CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo"
    OR GENERATOR_IS_MULTI_CONFIG)
)
    message(WARNING "Code coverage results with an optimized (non-Debug) build may be misleading")
endif()

# Mark certain variables as advanced
mark_as_advanced(CMAKE_C_FLAGS_COVERAGE CMAKE_CXX_FLAGS_COVERAGE CMAKE_EXE_LINKER_FLAGS_COVERAGE CMAKE_SHARED_LINKER_FLAGS_COVERAGE GENERATOR_IS_MULTI_CONFIG)

# Function to append coverage compiler flags to all targets
function(append_coverage_compiler_flags)
    set(CMAKE_C_FLAGS
        "${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_COVERAGE}"
        PARENT_SCOPE
    )
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_COVERAGE}"
        PARENT_SCOPE
    )

    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS_COVERAGE}")

    message(STATUS "Appending code coverage compiler flags: ${COVERAGE_COMPILER_FLAGS}")
endfunction()

# Function to set coverage flags for a specific library target
function(append_coverage_compiler_flags_to_target TARGET)
    get_target_property(TARGET_TYPE ${TARGET} TYPE)

    if(${TARGET_TYPE} STREQUAL "EXECUTABLE")
        get_target_property(TARGET_SOURCES ${TARGET} SOURCES)

        # Determine the language based on the sources
        foreach(SOURCE ${TARGET_SOURCES})
            get_source_file_property(SOURCE_LANG ${SOURCE} LANGUAGE)

            if(SOURCE_LANG STREQUAL "CXX")
                set(TARGET_LANG "CXX")

                break()
            elseif(SOURCE_LANG STREQUAL "C")
                set(BACKUP_TARGET_LANG "C")
            endif()
        endforeach()

        if(NOT TARGET_LANG AND BACKUP_TARGET_LANG)
            set(TARGET_LANG BACKUP_TARGET_LANG)
        endif()

        if(NOT TARGET_LANG)
            message(WARNING "Coverage flags may not be applied properly to target (${TARGET}). Unsupported language.")
        else()
            separate_arguments(COMPILER_FLAG_LIST NATIVE_COMMAND "${CMAKE_${TARGET_LANG}_FLAGS_COVERAGE}")
            target_compile_options(${TARGET} PRIVATE ${COMPILER_FLAG_LIST})

            target_link_options(${TARGET} PRIVATE ${CMAKE_EXE_LINKER_FLAGS_COVERAGE})
        endif()
    else()
        separate_arguments(COMPILER_FLAG_LIST NATIVE_COMMAND "${COVERAGE_COMPILER_FLAGS}")

        if(${TARGET_TYPE} STREQUAL "INTERFACE_LIBRARY")
            target_compile_options(${TARGET} INTERFACE ${COMPILER_FLAG_LIST})

            target_link_options(${TARGET} INTERFACE ${CMAKE_EXE_LINKER_FLAGS_COVERAGE})
        else()
            target_compile_options(${TARGET} PUBLIC ${COMPILER_FLAG_LIST})

            target_link_options(${TARGET} PUBLIC ${CMAKE_EXE_LINKER_FLAGS_COVERAGE})
        endif()
    endif()
endfunction()
