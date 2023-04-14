function (generate_pkg_config)
    set (
        one_value_args
        TARGET
        PC_FILE_IN
    )

    cmake_parse_arguments (
        GPC "" "${one_value_args}" "" ${ARGN}
    )

    get_target_property (IDEPS ${GPC_TARGET} INTERFACE_LINK_LIBRARIES)
    get_target_property (DEPS  ${GPC_TARGET} LINK_LIBRARIES)

    list (APPEND DEPS IDEPS})
    list (REMOVE_DUPLICATES DEPS)
    foreach (dep IN LISTS DEPS)
        if (TARGET ${dep})
            get_target_property (${dep}_REQUIRES ${dep} PKG_CONFIG_REQUIRES)
            if (NOT (${${dep}_REQUIRES} MATCHES ".+-NOTFOUND"))
                list (APPEND PKG_CONFIG_REQUIRES ${${dep}_REQUIRES})
            endif ()

            get_target_property (${dep}_CFLAGS ${dep} PKG_CONFIG_CFLAGS)
            if (NOT (${${dep}_CFLAGS} MATCHES ".+-NOTFOUND"))
                list (APPEND PKG_CONFIG_CFLAGS ${${dep}_CFLAGS})
            endif ()

            get_target_property (${dep}_LIBS ${dep} PKG_CONFIG_LIBS)
            if (NOT (${${dep}_LIBS} MATCHES ".+-NOTFOUND"))
                list (APPEND PKG_CONFIG_LIBS ${${dep}_LIBS})
            endif ()
        endif ()
    endforeach ()

    set (PKG_CONFIG_EXEC_PREFIX ${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR})
    set (PKG_CONFIG_LIBDIR ${CMAKE_INSTALL_LIBDIR})
    if ((NOT MSVC) AND WIN32 AND BUILD_SHARED_LIBS)
        set (PKG_CONFIG_LIBDIR ${CMAKE_INSTALL_BINDIR})
    endif ()
    set (PKG_CONFIG_INCLUDEDIR ${CMAKE_INSTALL_INCLUDEDIR})
    set (PKG_CONFIG_LIBRARY_NAME ${GPC_TARGET})

    if (MSVC)
        set (PKG_CONFIG_INCLUDE_PREFIX "/I")
        set (PKG_CONFIG_LIBPATH_PREFIX "/LIBPATH:")
        set (PKG_CONFIG_LIB_PREFIX "")
        set (PKG_CONFIG_LIB_SUFFIX ".lib")
    else ()
        set (PKG_CONFIG_INCLUDE_PREFIX "-I")
        set (PKG_CONFIG_LIBPATH_PREFIX "-L")
        set (PKG_CONFIG_LIB_PREFIX "-l")
        set (PKG_CONFIG_LIB_SUFFIX "")
    endif ()

    if (PKG_CONFIG_REQUIRES)
        list (REMOVE_DUPLICATES PKG_CONFIG_REQUIRES)
        string (REPLACE ";" " " PKG_CONFIG_REQUIRES " ${PKG_CONFIG_REQUIRES}")
    endif ()

    if (PKG_CONFIG_CFLAGS)
        list (REMOVE_DUPLICATES PKG_CONFIG_CFLAGS)
        string (REPLACE ";" " " PKG_CONFIG_CFLAGS " ${PKG_CONFIG_CFLAGS}")
    endif ()

    if (PKG_CONFIG_LIBS)
        list (REMOVE_DUPLICATES PKG_CONFIG_LIBS)
        string (REPLACE ";" " " PKG_CONFIG_LIBS " ${PKG_CONFIG_LIBS}")
    endif ()

    configure_file (${GPC_PC_FILE_IN} ${GPC_TARGET}.pc @ONLY)
    install (
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${PKG_CONFIG_LIBRARY_NAME}.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    )
endfunction ()
