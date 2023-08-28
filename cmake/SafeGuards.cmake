# Prevent building in the source directory:
file(TO_CMAKE_PATH "${PROJECT_BINARY_DIR}/CMakeLists.txt" LOC_PATH)

if(EXISTS "${LOC_PATH}")
    message(FATAL_ERROR "You cannot build in a source directory (or any directory with a CMakeLists.txt file). Please make a build subdirectory. Feel free to remove CMakeCache.txt and CMakeFiles.")
endif()

# Default build type if none is set.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(DEFAULT_BUILD_TYPE "RelWithDebInfo")

    message(STATUS "Setting build type to '${DEFAULT_BUILD_TYPE}' as none was specified.")

    set(CMAKE_BUILD_TYPE
        "${DEFAULT_BUILD_TYPE}"
        CACHE STRING "Choose the type of build." FORCE
    )

    # Check if version could be extracted:
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
else() # Guard against an incorrect build type.
    string(TOLOWER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_TOLOWER)

    if(NOT CMAKE_BUILD_TYPE_TOLOWER STREQUAL "debug"
       AND NOT CMAKE_BUILD_TYPE_TOLOWER STREQUAL "release"
       AND NOT CMAKE_BUILD_TYPE_TOLOWER STREQUAL "minsizerel"
       AND NOT CMAKE_BUILD_TYPE_TOLOWER STREQUAL "relwithdebinfo"
    )
        message(FATAL_ERROR "Unknown build type \"${CMAKE_BUILD_TYPE}\". Allowed values are Debug, Release (case-insensitive).")
    endif()
endif()

# Watcher for a variable which emulates readonly property.
macro(readonly_guard VAR ACCESS VALUE CURRENT_LIST_FILE STACK)
    if("${ACCESS}" STREQUAL "MODIFIED_ACCESS")
        message(WARNING "Attempt to change readonly variable '${VAR}' at ${CURRENT_LIST_FILE}!")
    endif()
endmacro()
