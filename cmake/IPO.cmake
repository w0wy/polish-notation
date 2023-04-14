if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_IPO)
    include (CheckIPOSupported)
    check_ipo_supported (RESULT ${PROJECT_CMAKE_NAMESPACE}_IPO_SUPPORTED OUTPUT output)
endif ()

function (enable_ipo project_name)
    if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_IPO)
        if (${PROJECT_CMAKE_NAMESPACE}_IPO_SUPPORTED)
            message (STATUS "[${PROJECT_ID}] Enabling IPO for ${project_name}")
            set_property (
                TARGET ${project_name}
                PROPERTY INTERPROCEDURAL_OPTIMIZATION ON
            )
        else ()
            message (SEND_ERROR "[${PROJECT_ID}] IPO is not supported: ${output}")
        endif ()
    endif ()
endfunction ()
