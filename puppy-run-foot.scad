// Puppy run foot
// (c) 2022 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

$fn = 36;
WIDTH = 50;
HEIGHT = 30;
SHIFT_WIDTH = 5;
SHIFT_HEIGHT = SHIFT_WIDTH;
DEPTH = 12;
RADIUS = 2;

GRATE_SHIFT = 2;
GRATE_SLIT_HEIGHT = 3;

// Physical parameters;

RUN_GRATE_RADIUS = 2.1;

// No configuration after this line

module foot_base() {
    hull() {
        for (x = [0, WIDTH]) {
            for (y = [0, HEIGHT]) {
                for (z = [0, DEPTH-RADIUS]) {
                    x_shift = (z==0) ? x : (x==0) ? SHIFT_WIDTH : x - SHIFT_WIDTH; 
                    y_shift = (z==0) ? y : (y==0) ? SHIFT_HEIGHT : y - SHIFT_HEIGHT; 
                    translate([x_shift, y_shift, z])
                        if (z==0) cylinder(r=RADIUS);
                        else sphere(r=RADIUS);
                }
            }
        }
    }
}

module grate_fit() {
    rotate([0, 90, 0])
    cylinder(r=RUN_GRATE_RADIUS, h=WIDTH);
}

module grate_slit() {
    slit_height = GRATE_SLIT_HEIGHT;
    height = 2*RUN_GRATE_RADIUS;
    union(){
        translate([0,-slit_height/2, 0])
        cube([WIDTH, slit_height, 2*RUN_GRATE_RADIUS]);
        translate([0, 0, height/4]) rotate([45, 0, 0])
            cube([WIDTH, height, height]);
    }
}

module puppy_run_foot() {
    difference(){
        foot_base();
        translate([0, HEIGHT/2, DEPTH-RADIUS-GRATE_SHIFT]) grate_fit();
        translate([0, HEIGHT/2, DEPTH-RADIUS-GRATE_SHIFT]) grate_slit();
    }
}

puppy_run_foot();