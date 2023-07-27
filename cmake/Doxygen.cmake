# Enable doxygen doc builds of source:
function(enable_doxygen)
    find_package(
        Doxygen
        COMPONENTS dot
        OPTIONAL_COMPONENTS mscgen dia
        QUIET
    ) # Note: the dot module is provided by graphviz.

    if(DOXYGEN_FOUND)
        set(DOXYGEN_PROJECT_NAME "${PROJECT_NAME}")
        set(DOXYGEN_PROJECT_NUMBER "${PROJECT_VERSION}")
        set(DOXYGEN_PROJECT_BRIEF "${PROJECT_DESCRIPTION}")

        # If not specified, use the top readme file as the first page.
        if((NOT DOXYGEN_USE_MDFILE_AS_MAINPAGE) AND EXISTS "${PROJECT_SOURCE_DIR}/README.md")
            set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${PROJECT_SOURCE_DIR}/README.md")
        endif()

        if(NOT VERBOSE_OUTPUT)
            set(DOXYGEN_QUIET YES)
        endif()

        set(DOXYGEN_CALLER_GRAPH YES)
        set(DOXYGEN_CALL_GRAPH YES)
        set(DOXYGEN_EXTRACT_ALL YES)
        set(DOXYGEN_GENERATE_TREEVIEW YES)
        # svg files are much smaller than jpeg and png, and yet they have higher quality.
        set(DOXYGEN_DOT_IMAGE_FORMAT svg)
        set(DOXYGEN_DOT_TRANSPARENT YES)

        # If not specified, exclude the vcpkg files and the files CMake downloads under _deps (like project_options).
        if(NOT DOXYGEN_EXCLUDE_PATTERNS)
            set(DOXYGEN_EXCLUDE_PATTERNS "${CMAKE_CURRENT_SOURCE_DIR}/external/*" "${CMAKE_CURRENT_BINARY_DIR}/vcpkg_installed/*" "${CMAKE_CURRENT_BINARY_DIR}/_deps/*")
        endif()

        if("${DOXYGEN_THEME}" STREQUAL "")
            set(DOXYGEN_THEME "awesome-sidebar")
        endif()

        if("${DOXYGEN_THEME}" STREQUAL "awesome" OR "${DOXYGEN_THEME}" STREQUAL "awesome-sidebar")
            include(FetchContent)

            # Use a modern doxygen theme
            # https://github.com/jothepro/doxygen-awesome-css v1.6.1
            FetchContent_Declare(_doxygen_theme URL https://github.com/jothepro/doxygen-awesome-css/archive/refs/tags/v1.6.1.zip)
            FetchContent_MakeAvailable(_doxygen_theme)

            if("${DOXYGEN_THEME}" STREQUAL "awesome" OR "${DOXYGEN_THEME}" STREQUAL "awesome-sidebar")
                set(DOXYGEN_HTML_EXTRA_STYLESHEET "${_doxygen_theme_SOURCE_DIR}/doxygen-awesome.css")
            endif()

            if("${DOXYGEN_THEME}" STREQUAL "awesome-sidebar")
                set(DOXYGEN_HTML_EXTRA_STYLESHEET ${DOXYGEN_HTML_EXTRA_STYLESHEET} "${_doxygen_theme_SOURCE_DIR}/doxygen-awesome-sidebar-only.css")
            endif()
        endif()

        set(DOXYGEN_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/docs")

        set(DOT_GRAPH_MAX_NODES 100)

        # Create doxygen target:
        doxygen_add_docs(
            #: https://cmake.org/cmake/help/latest/module/FindDoxygen.html
            doxygen ALL "${CMAKE_CURRENT_SOURCE_DIR}"
            WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
            COMMENT "Generating API documentation with Doxygen"
        )

        message(STATUS "Created `doxygen` build target that will build documentation")
    else()
        message(WARNING "Doxygen is enabled but it or dot were not found. Make sure Doxygen and graphviz are installed")
    endif()
endfunction()
