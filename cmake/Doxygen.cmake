find_package(Doxygen REQUIRED dot) # Note: the dot module is provided by graphviz.

if(DOXYGEN_FOUND)
    add_custom_target(
        doxygen
        ${DOXYGEN_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/docs/Doxyfile"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" # Note: The values you define for INPUT and OUTPUT_DIRECTORY in docs/Doxyfile are relative to this working directory.
        COMMENT "Generating API documentation with Doxygen"
        VERBATIM
    )
endif()
