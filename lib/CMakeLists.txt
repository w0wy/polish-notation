include (GNUInstallDirs)

set (${PROJECT_ID}_LIBRARY_NAME ${PROJECT_ID}_lib)

add_library (${${PROJECT_ID}_LIBRARY_NAME})
add_library (${PROJECT_ID}::Library ALIAS ${${PROJECT_ID}_LIBRARY_NAME})

set_property (TARGET ${${PROJECT_ID}_LIBRARY_NAME} PROPERTY VERSION ${${PROJECT_CMAKE_NAMESPACE}_VERSION})
set_property (TARGET ${${PROJECT_ID}_LIBRARY_NAME} PROPERTY SOVERSION ${${PROJECT_CMAKE_NAMESPACE}_VERSION})
set_property (TARGET ${${PROJECT_ID}_LIBRARY_NAME} PROPERTY CXX_STANDARD ${${PROJECT_CMAKE_NAMESPACE}_CXX_STANDARD})
set_property (TARGET ${${PROJECT_ID}_LIBRARY_NAME} PROPERTY CXX_STANDARD_REQUIRED ON)

string (
    TOUPPER
    "${PROJECT_CMAKE_NAMESPACE}_PLATFORM_${${PROJECT_CMAKE_NAMESPACE}_ARCH}"
    ${PROJECT_CMAKE_NAMESPACE}_PLATFORM_ARCH
)

target_sources(
    ${${PROJECT_ID}_LIBRARY_NAME} PRIVATE
    stack_machine.cpp
)

set (CONFIG_HH_PATH "${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_ID}/config.h")

generate_config (
    TARGET ${${PROJECT_ID}_LIBRARY_NAME}
    OUTPUT_FILE ${CONFIG_HH_PATH}
    DEFINITIONS
        ${PROJECT_CMAKE_NAMESPACE}_VERSION \"${${PROJECT_CMAKE_NAMESPACE}_VERSION}\"
        ${PROJECT_CMAKE_NAMESPACE}_VERSION_MAJOR ${${PROJECT_CMAKE_NAMESPACE}_VERSION_MAJOR}
        ${PROJECT_CMAKE_NAMESPACE}_VERSION_MINOR ${${PROJECT_CMAKE_NAMESPACE}_VERSION_MINOR}
        ${PROJECT_CMAKE_NAMESPACE}_VERSION_PATCH ${${PROJECT_CMAKE_NAMESPACE}_VERSION_PATCH}
        ${PROJECT_CMAKE_NAMESPACE}_APPLICATION_ID \"${${PROJECT_CMAKE_NAMESPACE}_APPLICATION_ID}\"
        ${${PROJECT_CMAKE_NAMESPACE}_PLATFORM_ARCH} 1
        ${PROJECT_CMAKE_NAMESPACE}_NAMESPACE ${PROJECT_ID}
        ${PROJECT_CMAKE_NAMESPACE}_PRIVATE_NAMESPACE ${PROJECT_ID}_private
        ${PROJECT_CMAKE_NAMESPACE}_BEGIN_NAMESPACE namespace\ ${PROJECT_ID}{
        ${PROJECT_CMAKE_NAMESPACE}_BEGIN_PRIVATE_NAMESPACE namespace\ ${PROJECT_ID}_private{
        ${PROJECT_CMAKE_NAMESPACE}_END_NAMESPACE }
)

target_compile_definitions (
    ${${PROJECT_ID}_LIBRARY_NAME} PRIVATE
    -D$<UPPER_CASE:${${PROJECT_ID}_LIBRARY_NAME}>
    -DSOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
    -DBINARY_DIR="${CMAKE_CURRENT_BINARY_DIR}"
)

if (NOT BUILD_SHARED_LIBS)
    target_compile_definitions (
        ${${PROJECT_ID}_LIBRARY_NAME} PRIVATE
        -D$<UPPER_CASE:${${PROJECT_ID}_LIBRARY_NAME}>_NO_IMPORT_EXPORT_SEMANTICS
    )
endif ()

target_link_libraries (
    ${${PROJECT_ID}_LIBRARY_NAME}
    PUBLIC
        ${PROJECT_ID}::PublicHeaders
    PUBLIC
        ${PROJECT_ID}::Expected
    PRIVATE
        $<BUILD_INTERFACE:${PROJECT_ID}::Options>
        $<BUILD_INTERFACE:${PROJECT_ID}::Warnings>
)

generate_pkg_config (
    TARGET ${${PROJECT_ID}_LIBRARY_NAME}
    PC_FILE_IN config/pkg-config.in
)

generate_cmake_config (
    TARGET ${${PROJECT_ID}_LIBRARY_NAME}
    CONFIG_FILE_IN config/config.cmake.in
    VERSION_COMPATIBILITY SameMajorVersion
)

generate_documentation (
    TARGET ${${PROJECT_ID}_LIBRARY_NAME}
    TITLE ${PROJECT_NAME}
    BRIEF ${CMAKE_PROJECT_DESCRIPTION}
    DOXYFILE_IN ../doc/Doxyfile.in
    DOC_SOURCE_PATHS
        ${CONFIG_HH_PATH}
        ${CMAKE_CURRENT_SOURCE_DIR}/../include/@PROJECT_ID@
    DOC_INCLUDE_PATHS
        ${CMAKE_CURRENT_SOURCE_DIR}/../include/
        ${CMAKE_CURRENT_BINARY_DIR}/
    EXTRA_DOC_INPUT
        ${CMAKE_CURRENT_SOURCE_DIR}/../doc/mainpage.md
    STYLE_SHEETS
        ${CMAKE_CURRENT_SOURCE_DIR}/../doc/doxygen-awesome-css/doxygen-awesome.css
        ${CMAKE_CURRENT_SOURCE_DIR}/../doc/doxygen-awesome-css/doxygen-awesome-sidebar-only.css
)

install (
    TARGETS ${${PROJECT_ID}_LIBRARY_NAME}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

unset (${PROJECT_ID}_LIBRARY_NAME)

