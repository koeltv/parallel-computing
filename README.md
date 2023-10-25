# Parallel Computing Project

This is my repository for the [TUNI](https://www.tuni.fi/en) [Parallel Computing Course](https://moodle.tuni.fi/course/view.php?id=34634) project.

## To compile

no optimizations:
```bash
gcc -o canny util.c canny.c -lm
```
most optimizations, no vectorization
```bash
gcc -o canny util.c canny.c -lm -O2
```
Also vectorize
```bash
gcc -o canny util.c canny.c -lm -O2 -ftree-vectorize -mavx2
```
Also vectorize and show what loops get vectorized
```bash
gcc -o canny util.c canny.c -lm -O2 -ftree-vectorize -mavx2 -fopt-info-vec
```
Also allow math relaxations
```bash
gcc -o canny util.c canny.c -lm -O2 -ftree-vectorize -mavx2 -fopt-info-vec -ffast-math
```
Fastest tested combination
```bash
gcc -o canny util.c canny.c -lm -O2 -faggressive-loop-optimizations -fexpensive-optimizations -floop-nest-optimize -fselective-scheduling -fsplit-loops -ftree-loop-distribution -ftree-loop-vectorize -ffast-math
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
eog image.pgm
```
(From eog preferences, untick Smooth images when zoomed in in order to
view small images accurately.)
```bash
./canny && eog x output.pgm
```
To run benchmarking with the large hameenkatu.pgm image
```bash
./canny -B 10
```
To run benchmarking with the small x.pgm image
```bash
./canny -b num of iterations
```
You can also run the video people.mp4. You need ffmpeg installed for this,
which is unfortunately not available on TC217 machines, but is easy to install
if you are using your own machine:
```bash
./canny -v
```