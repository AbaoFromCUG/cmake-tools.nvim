cmake_minimum_required(VERSION 3.16)
project(app)

add_library(lib SHARED lib.cpp)



add_executable(app main.cpp)
target_link_libraries(app PRIVATE lib)
