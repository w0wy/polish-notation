set (EXPECTED_VERSION 96d547c03d2feab8db64c53c3744a9b4a7c8f2c5)

include (FetchContent)

string (SUBSTRING ${EXPECTED_VERSION} 0 8 EXPECTED_COMMIT)
FetchContent_Declare (
    EXPECTED-${EXPECTED_COMMIT}
    URL https://github.com/TartanLlama/expected/archive/${EXPECTED_VERSION}.tar.gz
    URL_HASH SHA256=64901df1de9a5a3737b331d3e1de146fa6ffb997017368b322c08f45c51b90a7
)

set (EXPECTED_BUILD_TESTS OFF)
set (EXPECTED_BUILD_PACKAGE_DEB OFF)

FetchContent_MakeAvailable (EXPECTED-${EXPECTED_COMMIT})

add_library(
    ${PROJECT_ID}_expected INTERFACE
)
add_library (${PROJECT_ID}::Expected ALIAS ${PROJECT_ID}_expected)
target_link_libraries (${PROJECT_ID}_expected INTERFACE tl::expected)