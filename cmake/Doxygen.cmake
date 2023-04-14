function (enable_doxygen)
    if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_DOXYGEN)
        set (DOXYGEN_CALLER_GRAPH ON)
        set (DOXYGEN_CALL_GRAPH ON)
        set (DOXYGEN_EXTRACT_ALL ON)
        find_package (Doxygen REQUIRED dot)
        doxygen_add_docs (doxygen-docs ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
endfunction()
