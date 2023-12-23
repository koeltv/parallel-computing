# Parallel Computing Project

This is my repository for the [TUNI](https://www.tuni.fi/en) [Parallel Computing Course](https://moodle.tuni.fi/course/view.php?id=34634) project.
The purpose of this program is to do edge detection using the [canny edge detection algorithm](https://en.wikipedia.org/wiki/Canny_edge_detector).

## Branches

The project is split on multiple branch, each adding further optimizations:
- [master](https://github.com/koeltv/parallel-computing/tree/master) original, no modifications
- [generic_optimizations](https://github.com/koeltv/parallel-computing/tree/generic_optimizations) some optimizations, no threads
- [openmp](https://github.com/koeltv/parallel-computing/tree/openmp) parallelization with OpenMP
- [opencl](https://github.com/koeltv/parallel-computing/tree/opencl) usage of specialized hardware with OpenCL
- [opencl-with-optimizations](https://github.com/koeltv/parallel-computing/tree/opencl-with-optimizations) OpenCL usage with further optimizations
- [final-windows-video-support](https://github.com/koeltv/parallel-computing/tree/final-windows-video-support) final version with main method modified to be able to run video mode on Windows

## To compile

no optimizations:
```bash
gcc -o canny util.c canny.c -lm
```
most optimizations, no vectorization
```bash
gcc -o canny util.c canny.c -lm -O2
```
Also vectorize and show what loops get vectorized
```bash
gcc -o canny util.c canny.c -lm -O2 -ftree-vectorize -mavx2 -fopt-info-vec
```
Also allow math relaxations
```bash
gcc -o canny util.c canny.c -lm -O2 -ftree-vectorize -mavx2 -fopt-info-vec -ffast-math
```
Also support OpenMP
```bash
gcc -o canny util.c canny.c -lm -O2 -ftree-vectorize -mavx2 -fopt-info-vec -ffast-math -fopenmp
```
Also support OpenCL:
```bash
gcc -o canny util.c opencl util.c canny.c -lm -O2 -ftree-vectorize -mavx2 -fopt-info-vec -ffast-math -fopenmp -lOpenCL
```

## To run the binary:

Runs the application once with the x.pgm image (output written to
x output.pgm). PGM images can be viewed with many common image viewers. For example:
```bash
./canny && eog x output.pgm
```
To run benchmarking with the large hameenkatu.pgm image
```bash
./canny -B <NUM_OF_ITERATIONS>
```
To run benchmarking with the small x.pgm image
```bash
./canny -b <NUM_OF_ITERATIONS>
```
You can also run the video people.mp4. You need ffmpeg installed for this
```bash
./canny -v
```