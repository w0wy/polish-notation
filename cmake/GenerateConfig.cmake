function (generate_config)
    set (
        one_value_args
        TARGET
        OUTPUT_FILE
    )

    set (
        multi_value_args
        DEFINITIONS
    )

    cmake_parse_arguments (
        GC "" "${one_value_args}" "${multi_value_args}" ${ARGN}
    )

    if (NOT GC_OUTPUT_FILE)
        message (FATAL_ERROR "[${PROJECT_ID}] OUTPUT_FILE is a mandatory paramenter")
    endif ()

    if (NOT GC_DEFINITIONS)
        message (FATAL_ERROR "[${PROJECT_ID}] DEFINITIONS is a mandatory paramenter")
    endif ()

    cmake_path (HAS_PARENT_PATH GC_OUTPUT_FILE HAS_PARENT)
    cmake_path (HAS_FILENAME GC_OUTPUT_FILE HAS_FILENAME)
    cmake_path (IS_ABSOLUTE GC_OUTPUT_FILE IS_ABSOLUTE)
    if ((NOT HAS_PARENT) OR (NOT HAS_FILENAME) OR (NOT IS_ABSOLUTE))
        message (FATAL_ERROR "[${PROJECT_ID}] OUTPUT_FILE does not appear to be a valid path")
    endif ()

    set (FILE_CONTENT "/* Auto generated file. DO NOT EDIT! */\n\n")
    set (FILE_CONTENT "${FILE_CONTENT}#pragma once\n")

    list (LENGTH GC_DEFINITIONS DEFINITIONS_COUNT)
    set (counter 0)

    foreach (definition IN LISTS GC_DEFINITIONS)
        list (GET GC_DEFINITIONS ${counter} NAME)
        math (EXPR counter "${counter}+1")

        list (GET GC_DEFINITIONS ${counter} VALUE)
        math (EXPR counter "${counter}+1")

        set (FILE_CONTENT "${FILE_CONTENT}\n#define ${NAME} ${VALUE}")

        if (NOT (counter LESS DEFINITIONS_COUNT))
            break ()
        endif ()
    endforeach ()

    file (WRITE "${GC_OUTPUT_FILE}" "${FILE_CONTENT}")

    cmake_path (GET GC_OUTPUT_FILE PARENT_PATH GC_OUTPUT_PATH)
    target_include_directories (${GC_TARGET} PUBLIC ${GC_OUTPUT_PATH})
    if (${GC_OUTPUT_PATH} MATCHES ".+/${PROJECT_ID}$")
        target_include_directories (${GC_TARGET} PUBLIC ${GC_OUTPUT_PATH}/..)
    endif ()

    install (
        FILES ${GC_OUTPUT_FILE}
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_ID}
    )
endfunction ()
