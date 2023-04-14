function (generate_documentation)
    set (
        one_value_args
        TARGET
        TITLE
        BRIEF
        DOXYFILE_IN
    )

    set (
        multi_value_args
        DOC_SOURCE_PATHS
        DOC_INCLUDE_PATHS
        EXTRA_DOC_INPUT
        STYLE_SHEETS
    )

    cmake_parse_arguments (
        GD "" "${one_value_args}" "${multi_value_args}" ${ARGN}
    )

    if (NOT GD_TARGET)
        message (FATAL_ERROR "[${PROJECT_ID}] TARGET is a mandatory parameter")
    endif ()

    if (NOT GD_DOXYFILE_IN)
        message (FATAL_ERROR "[${PROJECT_ID}] DOXYFILE_IN is a mandatory parameter")
    endif ()

    if (NOT GD_DOC_SOURCE_PATHS)
        message (FATAL_ERROR "[${PROJECT_ID}] DOC_SOURCE_PATHS is a mandatory parameter")
    endif ()

    if (NOT ${PROJECT_CMAKE_NAMESPACE}_GENERATE_DOCUMENTATION)
        return ()
    endif ()

    find_program (DOXYGEN doxygen NAMES doxygen.exe DOC "Doxygen executable"      REQUIRED)
    find_program (DOT     dot     NAMES dot.exe     DOC "Graphviz dot executable" REQUIRED)

    if (NOT GD_TITLE)
        set (GD_TITLE ${GD_TARGET})
    endif ()

    foreach (path IN LISTS GD_DOC_SOURCE_PATHS)
        file (REAL_PATH ${path} path)
        if (DOC_SOURCE_PATHS)
            set (DOC_SOURCE_PATHS "${DOC_SOURCE_PATHS} ")
        endif ()
        set (DOC_SOURCE_PATHS "${DOC_SOURCE_PATHS}\"${path}\"")
    endforeach ()

    foreach (inc_dir IN LISTS GD_DOC_INCLUDE_PATHS)
        file (REAL_PATH ${inc_dir} inc_dir)
        if (DOC_INCLUDE_PATHS)
            set (DOC_INCLUDE_PATHS "${DOC_INCLUDE_PATHS} ")
        endif ()
        set (DOC_INCLUDE_PATHS "${DOC_INCLUDE_PATHS}\"${inc_dir}\"")
    endforeach ()

    foreach (doc IN LISTS GD_EXTRA_DOC_INPUT)
        file (REAL_PATH ${doc} doc)
        if (DOC_EXTRA_INPUT)
            set (DOC_EXTRA_INPUT "${DOC_EXTRA_INPUT} ")
        endif ()
        set (DOC_EXTRA_INPUT "${DOC_EXTRA_INPUT}\"${doc}\"")
    endforeach ()

    foreach (style_sheet IN LISTS GD_STYLE_SHEETS)
        file (REAL_PATH ${style_sheet} style_sheet)
        if (DOC_STYLE_SHEETS)
            set (DOC_STYLE_SHEETS "${DOC_STYLE_SHEETS} ")
        endif ()
        set (DOC_STYLE_SHEETS "${DOC_STYLE_SHEETS}\"${style_sheet}\"")
    endforeach ()

    file (REAL_PATH ${GD_DOXYFILE_IN} GD_DOXYFILE_IN)

    file (RELATIVE_PATH GD_DOXYFILE_OUT ${${PROJECT_CMAKE_NAMESPACE}_PROJECT_DIR} ${GD_DOXYFILE_IN})
    set (GD_DOXYFILE_OUT "${${PROJECT_CMAKE_NAMESPACE}_OUTPUT_DIR}/${GD_DOXYFILE_OUT}")

    cmake_path (GET GD_DOXYFILE_OUT PARENT_PATH GD_DOC_OUT_PATH)

    set (GD_DOXYFILE_OUT "${GD_DOC_OUT_PATH}/Doxyfile")

    configure_file (${GD_DOXYFILE_IN} ${GD_DOXYFILE_OUT}.temp @ONLY)
    configure_file (${GD_DOXYFILE_OUT}.temp ${GD_DOXYFILE_OUT} @ONLY)

    add_custom_target (
        ${GD_TARGET}_docs
        ${DOXYGEN} ${GD_DOXYFILE_OUT}
        WORKING_DIRECTORY ${GD_DOC_OUT_PATH}
        VERBATIM
    )
    add_dependencies (${GD_TARGET} ${GD_TARGET}_docs)
endfunction ()
