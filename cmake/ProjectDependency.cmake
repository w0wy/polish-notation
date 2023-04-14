function (find_project_dependency)
    set (
        option_args
        SET_PKG_CONFIG_TARGET_PROPERTIES
        SET_CMAKE_CONFIG_TARGET_PROPERTIES
    )
    
    set (
        one_value_args
        NAME
        FIND_PKG_IMPORTED_TARGET
    )

    set (
        multi_value_args
        NAMES
        COMPONENTS
    )

    cmake_parse_arguments (
        DEP "${option_args}" "${one_value_args}" "${multi_value_args}" ${ARGN}
    )

    if (DEP_${DEP_NAME}_USE_BUILTIN)
        message (STATUS "[${PROJECT_ID}] Using builtin version for ${DEP_NAME}...")
        return ()
    endif ()
    
    function (lib_path_to_link_flag LIB OUT)
        cmake_path (HAS_PARENT_PATH LIB HAS_PARENT)
    
        cmake_path (GET LIB EXTENSION lib_extension)
        if (BUILD_SHARED_LIBS AND (${lib_extension} MATCHES "\\.a"))
            continue ()
        endif ()

        cmake_path (GET LIB STEM lib_name)

        set (LINK_FLAGS "")

        if (HAS_PARENT)
            cmake_path (GET LIB PARENT_PATH lib_dir)
            if (MSVC)
                list (APPEND LINK_FLAGS "/LIBPATH:")
            else ()
                list (APPEND LINK_FLAGS "-L")
            endif ()
            set (LINK_FLAGS "${LINK_FLAGS}${lib_dir}")
        endif ()

        if (MSVC)
            list (APPEND LINK_FLAGS ${lib_name}${lib_extension})
        else ()
            string (REGEX REPLACE "^lib" "" lib_name ${lib_name})
            list (APPEND LINK_FLAGS "-l${lib_name}")
        endif ()
        
        set (${OUT} ${LINK_FLAGS} PARENT_SCOPE)
    endfunction ()
    
    function (get_target_flags)
        set (
            option_args
            DONT_PARSE_TARGET
        )

        set (
            one_value_args
            TARGET
            LINK_FLAGS
            COMPILE_FLAGS
        )

        cmake_parse_arguments (
            GLL "${option_args}" "${one_value_args}" "" ${ARGN}
        )
        
        if (NOT DEFINED GLL_TARGET)
            message (FATAL_ERROR "[${PROJECT_ID}] TARGET not provided when searching for libraries")
        endif ()
        
        if (NOT DEFINED GLL_LINK_FLAGS)
            message (FATAL_ERROR "[${PROJECT_ID}] LINK_FLAGS not provided when searching for libraries")
        endif ()
        
        if (NOT DEFINED GLL_COMPILE_FLAGS)
            message (FATAL_ERROR "[${PROJECT_ID}] COMPILE_FLAGS not provided when searching for libraries")
        endif ()

        if (NOT GLL_DONT_PARSE_TARGET)
            list (APPEND LIBS ${GLL_TARGET})
        else ()
            list (APPEND VISITED_TARGETS ${GLL_TARGET})
        endif ()

        get_target_property (INTERFACE_LIBS ${GLL_TARGET} INTERFACE_LINK_LIBRARIES)
        list (APPEND LIBS ${INTERFACE_LIBS})

        get_target_property (REGULAR_LIBS ${GLL_TARGET} LINK_LIBRARIES)
        list (APPEND LIBS ${REGULAR_LIBS})

        foreach (LIB IN LISTS LIBS)
            if (${LIB} MATCHES ".+-NOTFOUND")
                continue ()
            endif ()

            if (TARGET ${LIB})
                list (FIND VISITED_TARGETS ${LIB} VISITED)
                if (${VISITED} EQUAL -1)
                    get_target_property (LIB_LOCATION ${LIB} LOCATION)
                    if (NOT ("${LIB_LOCATION}" MATCHES ".+-NOTFOUND"))
                        lib_path_to_link_flag ("${LIB_LOCATION}" LIB_LINK_FLAGS)
                        list (APPEND LINK_FLAGS ${LIB_LINK_FLAGS})
                    endif ()
                    
                    get_target_property (INTERFACE_INCLUDE_DIRS ${LIB} INTERFACE_INCLUDE_DIRECTORIES)
                    if (NOT ("${INTERFACE_INCLUDE_DIRS}" MATCHES ".+-NOTFOUND"))
                        foreach (inc_dir IN LISTS INTERFACE_INCLUDE_DIRS)
                            if (MSVC)
                                list (APPEND COMPILE_FLAGS "/I")
                            else ()
                                list (APPEND COMPILE_FLAGS "-I")
                            endif ()
                            set (COMPILE_FLAGS "${COMPILE_FLAGS}${inc_dir}")
                        endforeach ()
                    endif ()

                    get_target_property (REGULAR_INCLUDE_DIRS ${LIB} INCLUDE_DIRECTORIES)
                    if (NOT ("${REGULAR_INCLUDE_DIRS}" MATCHES ".+-NOTFOUND"))
                        foreach (inc_dir IN LISTS REGULAR_INCLUDE_DIRS)
                            if (MSVC)
                                list (APPEND COMPILE_FLAGS "/I")
                            else ()
                                list (APPEND COMPILE_FLAGS "-I")
                            endif ()
                            set (COMPILE_FLAGS "${COMPILE_FLAGS}${inc_dir}")
                        endforeach ()
                    endif ()

                    if (NOT ("${LIB}" MATCHES "${TARGET}"))
                        get_target_flags (
                            TARGET ${LIB}
                            LINK_FLAGS LIB_LINK_FLAGS
                            COMPILE_FLAGS LIB_COMPILE_FLAGS
                            DONT_PARSE_TARGET
                        )

                        list (APPEND LINK_FLAGS ${LIB_LINK_FLAGS})
                        list (APPEND COMPILE_FLAGS ${LIB_COMPILE_FLAGS})
                    endif ()
                endif ()
            else ()
                string (REGEX REPLACE "\\$<LINK.+\\:(.+)>" "\\1" LIB "${LIB}")
                string (STRIP "${LIB}" LIB) 

                if ("${LIB}" MATCHES "^-Wl.+")
                    continue ()
                endif ()
                
                if (NOT LIB)
                    continue ()
                endif ()

                lib_path_to_link_flag ("${LIB}" LIB_LINK_FLAGS)
                list (APPEND LINK_FLAGS ${LIB_LINK_FLAGS})
            endif()
        endforeach()

        set (VISITED_TARGETS ${VISITED_TARGETS} PARENT_SCOPE)
        set (${GLL_LINK_FLAGS} ${LINK_FLAGS} PARENT_SCOPE)
        set (${GLL_COMPILE_FLAGS} ${COMPILE_FLAGS} PARENT_SCOPE)
    endfunction()

    set (LIB_NAME_INTERNAL __LIB_${DEP_NAME})

    set (${DEP_NAME}_FOUND FALSE)
    
    set (${DEP_NAME}_PKG_CONFIG_CFLAGS "")
    set (${DEP_NAME}_PKG_CONFIG_LIBS "")
    set (${DEP_NAME}_PKG_CONFIG_REQUIRES "")
    set (${DEP_NAME}_CMAKE_CONFIG_CFLAGS "")
    set (${DEP_NAME}_CMAKE_CONFIG_LIBS "")
    set (${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_STRING "")
    set (${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_TARGET "")

    find_package (
        ${DEP_NAME}
        NAMES ${DEP_NAMES}
        COMPONENTS ${DEP_COMPONENTS}
        CONFIG
        QUIET
        NO_CMAKE_PACKAGE_REGISTRY
    )
    if (NOT TARGET ${DEP_FIND_PKG_IMPORTED_TARGET})
        if (${DEP_NAME}_FOUND)
            message (WARNING "[${PROJECT_ID}] Dependency ${DEP_NAME} found but ${DEP_FIND_PKG_IMPORTED_TARGET} is not a valid target, moving on...")
        endif ()
        set (${DEP_NAME}_FOUND FALSE)
    endif ()

    if (NOT ${DEP_NAME}_FOUND)
        find_package (PkgConfig QUIET)
        if (PkgConfig_FOUND)
            pkg_search_module (PKG_${DEP_NAME} QUIET IMPORTED_TARGET ${DEP_NAME})
            if (NOT PKG_${DEP_NAME}_FOUND)
                foreach (name IN LISTS DEP_NAMES)
                    string (TOLOWER ${name} name_lower)
                    
                    pkg_search_module (PKG_${DEP_NAME} QUIET IMPORTED_TARGET ${name})
                    if (NOT PKG_${DEP_NAME}_FOUND)
                        pkg_search_module (PKG_${DEP_NAME} QUIET IMPORTED_TARGET "lib${name}")
                    else ()
                        list (APPEND ${DEP_NAME}_PKG_CONFIG_REQUIRES ${name_lower})
                        break ()
                    endif ()

                    if (PKG_${DEP_NAME}_FOUND)
                        list (APPEND ${DEP_NAME}_PKG_CONFIG_REQUIRES "lib${name_lower}")
                        break ()
                    endif ()
                endforeach ()
            else ()
                string (TOLOWER ${DEP_NAME} name_lower)
                list (APPEND ${DEP_NAME}_PKG_CONFIG_REQUIRES ${name_lower})
            endif ()

            if (NOT PKG_${DEP_NAME}_FOUND)
                add_library (__PKG_${DEP_NAME} INTERFACE)
                add_library (PkgConfig::PKG_${DEP_NAME} ALIAS __PKG_${DEP_NAME})

                foreach (name IN LISTS DEP_COMPONENTS)
                    set (PKG_${DEP_NAME}_FOUND TRUE)
                    string (TOLOWER ${name} name_lower)

                    pkg_search_module (PKG_${DEP_NAME}_${name} QUIET IMPORTED_TARGET ${name})
                    if (NOT PKG_${DEP_NAME}_${name}_FOUND)
                        pkg_search_module (PKG_${DEP_NAME}_${name} QUIET IMPORTED_TARGET "lib${name}")
                        if (NOT PKG_${DEP_NAME}_${name}_FOUND)
                            set (PKG_${DEP_NAME}_FOUND FALSE)
                            break ()
                        else ()
                            list (APPEND ${DEP_NAME}_PKG_CONFIG_REQUIRES "lib${name_lower}")
                        endif ()
                    else ()
                        list (APPEND ${DEP_NAME}_PKG_CONFIG_REQUIRES ${name_lower})
                    endif ()

                    if (PKG_${DEP_NAME}_${name}_FOUND)
                        target_link_libraries (__PKG_${DEP_NAME} INTERFACE PkgConfig::PKG_${DEP_NAME}_${name})

                        list (APPEND ${DEP_NAME}_CMAKE_CONFIG_CFLAGS "${PKG_${DEP_NAME}_${name}_CFLAGS}")
                        list (APPEND ${DEP_NAME}_CMAKE_CONFIG_LIBS "${PKG_${DEP_NAME}_${name}_LDFLAGS}")
                    endif ()
                endforeach ()
            else ()
                list (APPEND ${DEP_NAME}_CMAKE_CONFIG_CFLAGS "${PKG_${DEP_NAME}_CFLAGS}")
                list (APPEND ${DEP_NAME}_CMAKE_CONFIG_LIBS "${PKG_${DEP_NAME}_LDFLAGS}")
            endif ()
        endif ()

        if (NOT PKG_${DEP_NAME}_FOUND)
            if ((${DEP_NAME}_INCLUDE_DIRS) AND (${DEP_NAME}_LIBS))
                message (STATUS "[${PROJECT_ID}] Found dependency ${DEP_NAME} using ${DEP_NAME}_INCLUDE_DIRS and ${DEP_NAME}_LIBS")
                
                add_library (${LIB_NAME_INTERNAL} INTERFACE)
                add_library (${PROJECT_ID}::${DEP_NAME} ALIAS ${LIB_NAME_INTERNAL})
                
                foreach (inc_dir IN LISTS ${DEP_NAME}_INCLUDE_DIRS)
                    cmake_path (IS_ABSOLUTE inc_dir IS_ABSOLUTE_PATH)
                    if (IS_ABSOLUTE_PATH)
                        target_include_directories (${LIB_NAME_INTERNAL} INTERFACE ${inc_dir})
                        
                        if (MSVC)
                            list (APPEND ${DEP_NAME}_PKG_CONFIG_CFLAGS "/I")
                            list (APPEND ${DEP_NAME}_CMAKE_CONFIG_CFLAGS "/I")
                        else ()
                            list (APPEND ${DEP_NAME}_PKG_CONFIG_CFLAGS "-I")
                            list (APPEND ${DEP_NAME}_CMAKE_CONFIG_CFLAGS "-I")
                        endif ()
                        set (${DEP_NAME}_PKG_CONFIG_CFLAGS "${${DEP_NAME}_PKG_CONFIG_CFLAGS}${inc_dir}")
                        set (${DEP_NAME}_CMAKE_CONFIG_CFLAGS "${${DEP_NAME}_CMAKE_CONFIG_CFLAGS}${inc_dir}")
                    else ()
                        message (WARNING "[${PROJECT_ID}] ${inc_dir} is not an absolute path ignoring...")
                    endif ()
                endforeach ()
                
                foreach (lib IN LISTS ${DEP_NAME}_LIBS)
                    cmake_path (HAS_PARENT_PATH lib HAS_PARENT)
                    cmake_path (HAS_FILENAME lib HAS_FILENAME)
                    cmake_path (IS_ABSOLUTE lib IS_ABSOLUTE)
                    if (HAS_PARENT AND HAS_FILENAME AND IS_ABSOLUTE)
                        target_link_libraries (${LIB_NAME_INTERNAL} INTERFACE ${lib})
                        
                        cmake_path (GET lib EXTENSION lib_extension)
                        if (BUILD_SHARED_LIBS AND (${lib_extension} MATCHES "\\.a"))
                            continue ()
                        endif ()

                        cmake_path (GET lib STEM lib_name)
                        cmake_path (GET lib PARENT_PATH lib_dir)
                        
                        if (MSVC)
                            list (APPEND ${DEP_NAME}_PKG_CONFIG_LIBS "/LIBPATH:")
                            list (APPEND ${DEP_NAME}_CMAKE_CONFIG_LIBS "/LIBPATH:")
                        else ()
                            list (APPEND ${DEP_NAME}_PKG_CONFIG_LIBS "-L")
                            list (APPEND ${DEP_NAME}_CMAKE_CONFIG_LIBS "-L")
                        endif ()
                        set (${DEP_NAME}_PKG_CONFIG_LIBS "${${DEP_NAME}_PKG_CONFIG_LIBS}${lib_dir}")
                        set (${DEP_NAME}_CMAKE_CONFIG_LIBS "${${DEP_NAME}_CMAKE_CONFIG_LIBS}${lib_dir}")

                        if (MSVC)
                            list (APPEND ${DEP_NAME}_PKG_CONFIG_LIBS ${lib_name}${lib_extension})
                            list (APPEND ${DEP_NAME}_CMAKE_CONFIG_LIBS ${lib_name}${lib_extension})
                        else ()
                            string (REGEX REPLACE "^lib" "" lib_name ${lib_name})
                            list (APPEND ${DEP_NAME}_PKG_CONFIG_LIBS "-l${lib_name}")
                            list (APPEND ${DEP_NAME}_CMAKE_CONFIG_LIBS "-l${lib_name}")
                        endif ()
                    else ()
                        message (WARNING "[${PROJECT_ID}] ${lib} is not a valid path to a library; the path is not absolute or does not contain a library name, ignoring...")
                    endif ()
                endforeach ()

                set (${DEP_NAME}_FOUND TRUE)
            endif ()
        else ()
            message (STATUS "[${PROJECT_ID}] Found dependency ${DEP_NAME} using pkgconfig")

            add_library (${LIB_NAME_INTERNAL} INTERFACE)
            add_library (${PROJECT_ID}::${DEP_NAME} ALIAS ${LIB_NAME_INTERNAL})
            target_link_libraries (${LIB_NAME_INTERNAL} INTERFACE PkgConfig::PKG_${DEP_NAME})

            set (${DEP_NAME}_FOUND TRUE)
        endif ()
    else ()
        message (STATUS "[${PROJECT_ID}] Found dependency ${DEP_NAME} using find_package()")

        add_library (${LIB_NAME_INTERNAL} INTERFACE)
        add_library (${PROJECT_ID}::${DEP_NAME} ALIAS ${LIB_NAME_INTERNAL})
        target_link_libraries (${LIB_NAME_INTERNAL} INTERFACE ${DEP_FIND_PKG_IMPORTED_TARGET})

        get_target_flags (
            TARGET ${DEP_FIND_PKG_IMPORTED_TARGET}
            LINK_FLAGS DEP_PKG_CONFIG_LIBS
            COMPILE_FLAGS DEP_PKG_CONFIG_CFLAGS
        )
        set (${DEP_NAME}_PKG_CONFIG_CFLAGS ${DEP_PKG_CONFIG_CFLAGS})
        set (${DEP_NAME}_PKG_CONFIG_LIBS ${DEP_PKG_CONFIG_LIBS})

        if (NOT ("${DEP_PKG_CONFIG_LIBS}" STREQUAL ""))
            set (${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_STRING "find_package (${DEP_NAME} NAMES ${DEP_NAMES} COMPONENTS ${DEP_COMPONENTS} CONFIG QUIET)")
            set (${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_TARGET "${DEP_FIND_PKG_IMPORTED_TARGET}")
        endif ()
    endif ()

    if (${DEP_NAME}_FOUND AND DEP_SET_PKG_CONFIG_TARGET_PROPERTIES)
        string (REPLACE ";" " " ${DEP_NAME}_PKG_CONFIG_REQUIRES "${${DEP_NAME}_PKG_CONFIG_REQUIRES}")
        string (REPLACE ";" " " ${DEP_NAME}_PKG_CONFIG_CFLAGS   "${${DEP_NAME}_PKG_CONFIG_CFLAGS}")
        string (REPLACE ";" " " ${DEP_NAME}_PKG_CONFIG_LIBS     "${${DEP_NAME}_PKG_CONFIG_LIBS}")

        set_property (TARGET ${LIB_NAME_INTERNAL} PROPERTY PKG_CONFIG_REQUIRES "${${DEP_NAME}_PKG_CONFIG_REQUIRES}")
        set_property (TARGET ${LIB_NAME_INTERNAL} PROPERTY PKG_CONFIG_CFLAGS   "${${DEP_NAME}_PKG_CONFIG_CFLAGS}")
        set_property (TARGET ${LIB_NAME_INTERNAL} PROPERTY PKG_CONFIG_LIBS     "${${DEP_NAME}_PKG_CONFIG_LIBS}")
    endif ()

    if (${DEP_NAME}_FOUND AND DEP_SET_CMAKE_CONFIG_TARGET_PROPERTIES)
        string (REPLACE ";" " " ${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_STRING "${${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_STRING}")
        string (REPLACE ";" " " ${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_TARGET "${${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_TARGET}")
        string (REPLACE ";" " " ${DEP_NAME}_CMAKE_CONFIG_CFLAGS          "${${DEP_NAME}_CMAKE_CONFIG_CFLAGS}")
        string (REPLACE ";" " " ${DEP_NAME}_CMAKE_CONFIG_LIBS            "${${DEP_NAME}_CMAKE_CONFIG_LIBS}")

        set_property (TARGET ${LIB_NAME_INTERNAL} PROPERTY CMAKE_CONFIG_FIND_PKG_STRING "${${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_STRING}")
        set_property (TARGET ${LIB_NAME_INTERNAL} PROPERTY CMAKE_CONFIG_FIND_PKG_TARGET "${${DEP_NAME}_CMAKE_CONFIG_FIND_PKG_TARGET}")
        set_property (TARGET ${LIB_NAME_INTERNAL} PROPERTY CMAKE_CONFIG_CFLAGS          "${${DEP_NAME}_CMAKE_CONFIG_CFLAGS}")
        set_property (TARGET ${LIB_NAME_INTERNAL} PROPERTY CMAKE_CONFIG_LIBS            "${${DEP_NAME}_CMAKE_CONFIG_LIBS}")
    endif ()

    if (NOT ${DEP_NAME}_FOUND)
        message (STATUS "[${PROJECT_ID}] Could not find dependency ${DEP_NAME}")
    endif ()
    
    set (${DEP_NAME}_FOUND ${${DEP_NAME}_FOUND} PARENT_SCOPE)
endfunction ()
