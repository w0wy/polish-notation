if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_CPPCHECK)
    find_program (CPPCHECK cppcheck)
    if (CPPCHECK)
        set (
            CMAKE_CXX_CPPCHECK ${CPPCHECK}
            --suppress=missingInclude
            --enable=all
            --inline-suppr
            --inconclusive
            -i ${CMAKE_CURRENT_SOURCE_DIR}/src
         )
    else ()
        message (SEND_ERROR "[${PROJECT_ID}] Cppcheck requested but executable not found")
    endif ()
endif ()

if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_CLANG_TIDY)
    find_program (CLANGTIDY clang-tidy)
    if (CLANGTIDY)
        set (CMAKE_CXX_CLANG_TIDY ${CLANGTIDY} -extra-arg=-Wno-unknown-warning-option)
    else ()
        message (SEND_ERROR "[${PROJECT_ID}] clang-tidy requested but executable not found")
    endif ()
endif ()

if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_INCLUDE_WHAT_YOU_USE)
    find_program (INCLUDE_WHAT_YOU_USE include-what-you-use)
    if (INCLUDE_WHAT_YOU_USE)
        set (CMAKE_CXX_INCLUDE_WHAT_YOU_USE ${INCLUDE_WHAT_YOU_USE})
    else ()
        message (SEND_ERROR "[${PROJECT_ID}] include-what-you-use requested but executable not found")
    endif ()
endif ()
