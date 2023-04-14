set (GOOGLE_TEST_VERSION 97a467571a0f615a4d96e79e4399c43221ca1232)

find_project_dependency (
    NAME GoogleTest
    NAMES GTest gtest googletest
    FIND_PKG_IMPORTED_TARGET GTest::gtest
)

if (NOT TARGET GTest::gmock)
    find_project_dependency (
        NAME GoogleMock
        NAMES gmock googlemock
    )
else ()
    # If we found Google Test using find_package() it also exports GTest::gmock
    set (GoogleMock_FOUND TRUE)
    add_library (${PROJECT_ID}_googlemock INTERFACE)
    add_library (${PROJECT_ID}::GoogleMock ALIAS ${PROJECT_ID}_googlemock)
    target_link_libraries (${PROJECT_ID}_googlemock INTERFACE GTest::gmock)
endif ()

if ((NOT GoogleTest_FOUND) OR (NOT GoogleMock_FOUND))
    include (FetchContent)
    
    string (SUBSTRING ${GOOGLE_TEST_VERSION} 0 8 GOOGLE_TEST_COMMIT)
    FetchContent_Declare (
        GOOGLE_TEST-${GOOGLE_TEST_COMMIT}
        URL https://github.com/google/googletest/archive/${GOOGLE_TEST_VERSION}.tar.gz
        URL_HASH SHA256=0e188182e88d0f8230b6af85c9ec87e5c7d904d0e1856fcf5e8bffc5c5933915
    )

    if (NOT GOOGLE_TEST-${GOOGLE_TEST_COMMIT}_POPULATED)
        FetchContent_Populate (GOOGLE_TEST-${GOOGLE_TEST_COMMIT})
    endif ()

    set (GOOGLE_TEST_LIBRARY googletest)
    set (GOOGLE_MOCK_LIBRARY googlemock)
    set (GOOGLE_TEST_BASE_DIR "${FETCHCONTENT_BASE_DIR}/google_test-${GOOGLE_TEST_COMMIT}-src")

    if (NOT GoogleTest_FOUND)
        add_library (
            ${GOOGLE_TEST_LIBRARY}
            ${GOOGLE_TEST_BASE_DIR}/googletest/src/gtest-all.cc
        )

        target_include_directories (
            ${GOOGLE_TEST_LIBRARY}
            SYSTEM PUBLIC
                ${GOOGLE_TEST_BASE_DIR}/googletest/include
            PRIVATE
                ${GOOGLE_TEST_BASE_DIR}/googletest
        )

        add_library (${PROJECT_ID}::GoogleTest ALIAS ${GOOGLE_TEST_LIBRARY})
    endif ()

    if (NOT GoogleMock_FOUND)
        add_library (
            ${GOOGLE_MOCK_LIBRARY}
            ${GOOGLE_TEST_BASE_DIR}/googlemock/src/gmock-all.cc
        )

        target_include_directories (
            ${GOOGLE_MOCK_LIBRARY}
            SYSTEM PUBLIC
                ${GOOGLE_TEST_BASE_DIR}/googlemock/include
            PRIVATE
                ${GOOGLE_TEST_BASE_DIR}/googlemock
        )

        target_link_libraries (
            ${GOOGLE_MOCK_LIBRARY} PUBLIC
            ${GOOGLE_TEST_LIBRARY}
        )

        add_library (${PROJECT_ID}::GoogleMock ALIAS ${GOOGLE_MOCK_LIBRARY})
    endif ()
endif ()
