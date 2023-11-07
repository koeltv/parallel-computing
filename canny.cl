size_t idx(size_t x, size_t y, size_t width, size_t height, int xoff, int yoff) {
    size_t resx = ((xoff > 0 && x < width - xoff) || (xoff < 0 && x >= -xoff)) ? x + xoff : x;
    size_t resy = ((yoff > 0 && y < height - yoff) || (yoff < 0 && y >= -yoff)) ? y + yoff : y;
    return resy * width + resx;
}

__kernel
void sobel3x3(
    __global uchar* in,
    __global short* output_x,
    __global short* output_y,
    unsigned long width,
    unsigned long height) {
   // Get the work-item’s IDs
   int y = get_global_id(0);
   int x = get_global_id(1);

   size_t gid = y * width + x;

    /* 3x3 sobel filter, first in x direction */
    output_x[gid] = (-1) * in[idx(x, y, width, height, -1, -1)] +
                    1 * in[idx(x, y, width, height, 1, -1)] +
                    (-2) * in[idx(x, y, width, height, -1, 0)] +
                    2 * in[idx(x, y, width, height, 1, 0)] +
                    (-1) * in[idx(x, y, width, height, -1, 1)] +
                    1 * in[idx(x, y, width, height, 1, 1)];

    /* 3x3 sobel filter, in y direction */
    output_y[gid] = (-1) * in[idx(x, y, width, height, -1, -1)] +
                    1 * in[idx(x, y, width, height, -1, 1)] +
                    (-2) * in[idx(x, y, width, height, 0, -1)] +
                    2 * in[idx(x, y, width, height, 0, 1)] +
                    (-1) * in[idx(x, y, width, height, 1, -1)] +
                    1 * in[idx(x, y, width, height, 1, 1)];
}

__kernel
void phaseAndMagnitude(
    __global const short *in_x,
    __global const short *in_y,
    __global uchar *phase_out,
    __global ushort *magnitude_out,
    unsigned long width,
    unsigned long height) {
   // Get the work-item’s IDs
   int y = get_global_id(0);
   int x = get_global_id(1);

   size_t gid = y * width + x;

    // Output in range -PI:PI
    float angle = atan2((float) in_y[gid], (float) in_x[gid]);

    // Shift range -1:1
    angle /= M_PI;

    // Shift range -127.5:127.5
    angle *= 127.5;

    // Shift range 0.5:255.5
    angle += (127.5 + 0.5);

    // Downcasting truncates angle to range 0:255
    phase_out[gid] = (uchar) angle;

    magnitude_out[gid] = abs(in_x[gid]) + abs(in_y[gid]);
}

__kernel
void nonMaxSuppression(
    __global ushort *magnitude,
    __global uchar *phase,
    unsigned long width,
    unsigned long height,
    ushort threshold_lower,
    ushort threshold_upper,
    __global uchar *out) {
    // Get the work-item’s IDs
    int y = get_global_id(0);
    int x = get_global_id(1);

    size_t gid = y * width + x;

    uchar sobel_angle = phase[gid] % 128;

    uchar sobel_orientation =
        (sobel_angle < 16 || sobel_angle >= 112) * 2
        + (sobel_angle >= 16 && sobel_angle < 48) * 1
        + (sobel_angle > 80 && sobel_angle < 112) * 3;

    /* Non-maximum suppression
     * Pick out the two neighbours that are perpendicular to the
     * current edge pixel */
    ushort neighbour_max;
    ushort neighbour_max2;
    switch (sobel_orientation) {
        case 0:
            neighbour_max = magnitude[idx(x, y, width, height, 0, -1)];
            neighbour_max2 = magnitude[idx(x, y, width, height, 0, 1)];
            break;
        case 1:
            neighbour_max = magnitude[idx(x, y, width, height, -1, -1)];
            neighbour_max2 = magnitude[idx(x, y, width, height, 1, 1)];
            break;
        case 2:
            neighbour_max = magnitude[idx(x, y, width, height, -1, 0)];
            neighbour_max2 = magnitude[idx(x, y, width, height, 1, 0)];
            break;
        case 3:
        default:
            neighbour_max = magnitude[idx(x, y, width, height, 1, -1)];
            neighbour_max2 = magnitude[idx(x, y, width, height, -1, 1)];
            break;
    }

    ushort sobel_magnitude = magnitude[gid];

    // Suppress the pixel here
    sobel_magnitude *= !(sobel_magnitude < neighbour_max || sobel_magnitude < neighbour_max2);

    /* Double thresholding */
    // Marks YES pixels with 255, NO pixels with 0 and MAYBE pixels with 127
    ushort t = (sobel_magnitude > threshold_upper) * 255
                + (sobel_magnitude <= threshold_lower) * 0
                + (sobel_magnitude > threshold_lower && sobel_magnitude <= threshold_upper) * 127;

    out[gid] = t;
}