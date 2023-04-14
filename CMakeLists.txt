cmake_minimum_required (VERSION 3.20)

# Include platform-specific setup as early as possible
include (cmake/PlatformSetup.cmake)

project (
    "Polish Notation Calculator"
    VERSION 1.0.0
    DESCRIPTION "Polish Notation Calculator"
    HOMEPAGE_URL "https://project-home-page.com"
)

set (PROJECT_AUTHOR "w0wy")
set (PROJECT_AUTHOR_EMAIL "w0wy4u@gmail.com")
set (PROJECT_LICENSE "MIT")

string (MAKE_C_IDENTIFIER "${PROJECT_NAME}" PROJECT_ID)
string (TOLOWER ${PROJECT_ID} PROJECT_ID)
string (TOUPPER ${PROJECT_ID} PROJECT_CMAKE_NAMESPACE)

set (${PROJECT_CMAKE_NAMESPACE}_VERSION "${CMAKE_PROJECT_VERSION}")
set (${PROJECT_CMAKE_NAMESPACE}_CXX_STANDARD 20)

string (REPLACE "." ";" ${PROJECT_CMAKE_NAMESPACE}_VERSION_SPLIT "${CMAKE_PROJECT_VERSION}")
list (GET ${PROJECT_CMAKE_NAMESPACE}_VERSION_SPLIT 0 ${PROJECT_CMAKE_NAMESPACE}_VERSION_MAJOR)
list (GET ${PROJECT_CMAKE_NAMESPACE}_VERSION_SPLIT 1 ${PROJECT_CMAKE_NAMESPACE}_VERSION_MINOR)
list (GET ${PROJECT_CMAKE_NAMESPACE}_VERSION_SPLIT 2 ${PROJECT_CMAKE_NAMESPACE}_VERSION_PATCH)

set (${PROJECT_CMAKE_NAMESPACE}_PROJECT_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set (${PROJECT_CMAKE_NAMESPACE}_OUTPUT_DIR  ${CMAKE_CURRENT_BINARY_DIR})

include (Options.cmake)

if (NOT ${PROJECT_CMAKE_NAMESPACE}_APPLICATION_ID)
    set (${PROJECT_CMAKE_NAMESPACE}_APPLICATION_ID "${PROJECT_ID}")
endif ()

if (NOT BUILD_SHARED_LIBS)
    set (BUILD_SHARED_LIBS OFF)
endif ()

include (cmake/Cache.cmake)
include (cmake/CompilerWarnings.cmake)
include (cmake/Coverage.cmake)
include (cmake/EmbedResources.cmake)
include (cmake/GenerateCMakeConfig.cmake)
include (cmake/GenerateConfig.cmake)
include (cmake/GenerateDocumentation.cmake)
include (cmake/GeneratePkgConfig.cmake)
include (cmake/IPO.cmake)
include (cmake/PreventInSourceBuilds.cmake)
include (cmake/ProjectDependency.cmake)
include (cmake/Sanitizers.cmake)
include (cmake/StandardProjectSettings.cmake)
include (cmake/StaticAnalyzers.cmake)
include (cmake/TargetArch.cmake)

target_architecture (${PROJECT_CMAKE_NAMESPACE}_ARCH)

add_library (${PROJECT_ID}_options INTERFACE)
add_library (${PROJECT_ID}::Options ALIAS ${PROJECT_ID}_options)

enable_sanitizers (${PROJECT_ID}_options)
enable_coverage (${PROJECT_ID}_options)
enable_ipo (${PROJECT_ID}_options)

add_library (${PROJECT_ID}_warnings INTERFACE)
add_library (${PROJECT_ID}::Warnings ALIAS ${PROJECT_ID}_warnings)

set_project_warnings (${PROJECT_ID}_warnings)

add_subdirectory (include)
add_subdirectory (lib)
add_subdirectory (src)

if (${PROJECT_CMAKE_NAMESPACE}_ENABLE_TESTING)
    add_subdirectory (test)
endif ()

unset (PROJECT_LICENSE)
unset (PROJECT_AUTHOR_EMAIL)
unset (PROJECT_AUTHOR)

unset (PROJECT_CMAKE_NAMESPACE)
unset (PROJECT_ID)

