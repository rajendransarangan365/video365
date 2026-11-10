cmake_minimum_required(VERSION 3.22.1)

project("video365_core")

add_library(
        video365_core
        SHARED
        video365_core.cpp
        video365_renderer.cpp
        render_graph.cpp
        expression_engine.cpp
)

target_include_directories(
        video365_core
        PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
)

find_library(
        log-lib
        log
)

target_link_libraries(
        video365_core
        android
        log
        GLESv3
        EGL
)
