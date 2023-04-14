function (enable_sanitizers project_name)
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        set (SANITIZERS "")

        if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_SANITIZER_ADDRESS)
            list (APPEND SANITIZERS "address")
        endif ()

        if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_SANITIZER_UNDEFINED_BEHAVIOR)
            list (APPEND SANITIZERS "undefined")
        endif ()

        if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_SANITIZER_THREAD)
            list (APPEND SANITIZERS "thread")
        endif ()

        if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_SANITIZER_LEAK)
            list (APPEND SANITIZERS "leak")
        endif ()


        if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_SANITIZER_MEMORY AND CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
            if ("address" IN_LIST SANITIZERS OR
                "thread" IN_LIST SANITIZERS OR
                "leak" IN_LIST SANITIZERS)
                message (WARNING "[${PROJECT_ID}] Memory sanitizer does not work with Address, Thread and Leak sanitizer enabled")  
            else ()
                list (APPEND SANITIZERS "memory")
            endif ()
        endif ()

        list (JOIN SANITIZERS "," LIST_OF_SANITIZERS)
    endif ()

    if (LIST_OF_SANITIZERS)
        if (NOT "${LIST_OF_SANITIZERS}" STREQUAL "")
            target_compile_options (
                ${project_name} INTERFACE
                -fsanitize=${LIST_OF_SANITIZERS}
            )
            target_link_libraries (
                ${project_name} INTERFACE
                -fsanitize=${LIST_OF_SANITIZERS}
            )
        endif ()
    endif ()
endfunction ()
