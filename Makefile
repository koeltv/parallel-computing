CC = gcc
OPENCL_INCLUDE_PATH = C:\Users\valen\.vcpkg-clion\vcpkg\installed\x64-windows\include
OPENCL_LIB_PATH = C:\Users\valen\.vcpkg-clion\vcpkg\installed\x64-windows\lib

canny: canny.c
	$(CC) -o canny util.c opencl_util.c canny.c -lm -O3 -funroll-loops -malign-data=cacheline -falign-functions -faggressive-loop-optimizations -fexpensive-optimizations -floop-nest-optimize -fselective-scheduling -fsplit-loops -ftree-loop-distribution -ftree-loop-vectorize -ffast-math -fopenmp -I${OPENCL_INCLUDE_PATH} -L${OPENCL_LIB_PATH} -lOpenCL