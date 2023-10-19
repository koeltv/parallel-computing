cmake_minimum_required(VERSION 3.26)
project(CannyCodefiles C)

set(CMAKE_C_STANDARD 11)

include_directories(.)

add_executable(CannyCodefiles
        canny.c
        opencl_util.c
        opencl_util.h
        util.c
        util.h)
