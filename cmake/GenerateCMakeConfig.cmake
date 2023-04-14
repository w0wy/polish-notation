function (generate_cmake_config)
    set (
        one_value_args
        TARGET
        CONFIG_FILE_IN
        VERSION_COMPATIBILITY
    )

    cmake_parse_arguments (
        GCC "" "${one_value_args}" "" ${ARGN}
    )

    include(CMakePackageConfigHelpers)
    write_basic_package_version_file(
        "${GCC_TARGET}-config-version.cmake"
        COMPATIBILITY ${GCC_VERSION_COMPATIBILITY}
    )

    get_target_property (IDEPS ${GCC_TARGET} INTERFACE_LINK_LIBRARIES)
    get_target_property (DEPS  ${GCC_TARGET} LINK_LIBRARIES)

    list (APPEND DEPS IDEPS})
    list (REMOVE_DUPLICATES DEPS)
    foreach (dep IN LISTS DEPS)
        if (TARGET ${dep})
            get_target_property (${dep}_FIND_PKG_STRING ${dep} CMAKE_CONFIG_FIND_PKG_STRING)
            if (NOT (${${dep}_FIND_PKG_STRING} MATCHES ".+-NOTFOUND"))
                set (CMAKE_CONFIG_FIND_PACKAGES "${CMAKE_CONFIG_FIND_PACKAGES}${${dep}_FIND_PKG_STRING}\n")
            endif ()

            get_target_property (${dep}_FIND_PKG_TARGET ${dep} CMAKE_CONFIG_FIND_PKG_TARGET)
            if (NOT (${${dep}_FIND_PKG_TARGET} MATCHES ".+-NOTFOUND"))
                set (CMAKE_CONFIG_DEP_TARGETS "${CMAKE_CONFIG_DEP_TARGETS}${${dep}_FIND_PKG_TARGET}\n")
            endif ()

            get_target_property (${dep}_CFLAGS ${dep} CMAKE_CONFIG_CFLAGS)
            if (NOT (${${dep}_CFLAGS} MATCHES ".+-NOTFOUND"))
                list (APPEND CMAKE_CONFIG_CFLAGS ${${dep}_CFLAGS})
            endif ()

            get_target_property (${dep}_LIBS ${dep} CMAKE_CONFIG_LIBS)
            if (NOT (${${dep}_LIBS} MATCHES ".+-NOTFOUND"))
                list (APPEND CMAKE_CONFIG_LIBS ${${dep}_LIBS})
            endif ()
        endif ()
    endforeach ()

    string (STRIP "${CMAKE_CONFIG_FIND_PACKAGES}" CMAKE_CONFIG_FIND_PACKAGES)
    string (STRIP "${CMAKE_CONFIG_DEP_TARGETS}" CMAKE_CONFIG_DEP_TARGETS)

    set (CMAKE_CONFIG_LIBDIR ${CMAKE_INSTALL_LIBDIR})
    if (WIN32 AND BUILD_SHARED_LIBS)
        set (CMAKE_CONFIG_LIBDIR ${CMAKE_INSTALL_BINDIR})
    endif ()
    set (CMAKE_CONFIG_INCLUDEDIR ${CMAKE_INSTALL_INCLUDEDIR})
    set (CMAKE_CONFIG_LIBRARY_NAME ${GCC_TARGET})

    if (CMAKE_CONFIG_CFLAGS)
        list (REMOVE_DUPLICATES CMAKE_CONFIG_CFLAGS)
    endif ()

    if (CMAKE_CONFIG_LIBS)
        list (REMOVE_DUPLICATES CMAKE_CONFIG_LIBS)
    endif ()

    configure_file (${GCC_CONFIG_FILE_IN} ${GCC_TARGET}-config.cmake @ONLY)
    install (
        FILES
            ${CMAKE_CURRENT_BINARY_DIR}/${GCC_TARGET}-config.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/${GCC_TARGET}-config-version.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake
    )
endfunction ()
