cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(timer C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(timer)

target_sources(timer PRIVATE timer.S)

target_link_libraries(timer PRIVATE pico_stdlib)
pico_add_extra_outputs(timer)
