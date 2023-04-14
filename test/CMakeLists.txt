set (${PROJECT_ID}_TEST_EXECUTABLE "${PROJECT_ID}_test")

message (STATUS "[${PROJECT_ID}] Building Tests")

include (CTest)
enable_testing ()

add_subdirectory (3rdparty)

add_executable (
    ${${PROJECT_ID}_TEST_EXECUTABLE}
)

set_property (TARGET ${${PROJECT_ID}_TEST_EXECUTABLE} PROPERTY CXX_STANDARD ${${PROJECT_CMAKE_NAMESPACE}_CXX_STANDARD})
set_property (TARGET ${${PROJECT_ID}_TEST_EXECUTABLE} PROPERTY CXX_STANDARD_REQUIRED ON)

target_sources (
    ${${PROJECT_ID}_TEST_EXECUTABLE} PUBLIC
    main.cc
)

target_compile_definitions (
    ${${PROJECT_ID}_TEST_EXECUTABLE} PRIVATE
    -D${PROJECT_CMAKE_NAMESPACE}_TESTING
)

target_link_libraries (
    ${${PROJECT_ID}_TEST_EXECUTABLE}
    PUBLIC
        ${PROJECT_ID}::Library
    PRIVATE
        ${PROJECT_ID}::PrivateHeaders
)

target_link_libraries (
    ${${PROJECT_ID}_TEST_EXECUTABLE}
    PUBLIC
        ${PROJECT_ID}::GoogleTest
        ${PROJECT_ID}::GoogleMock
    PRIVATE
        $<BUILD_INTERFACE:${PROJECT_ID}::Options>
        $<BUILD_INTERFACE:${PROJECT_ID}::Warnings>
)

if (NOT CMAKE_CROSSCOMPILING)
    include (GoogleTest)
    gtest_discover_tests (
        ${${PROJECT_ID}_TEST_EXECUTABLE}
        XML_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}
    )
endif ()

