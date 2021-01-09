// Espresso machine float

$fn=50;
RESERVOIR_DEPTH=100;
TOLERANCE=10;
FLOAT_DEPTH=RESERVOIR_DEPTH-TOLERANCE;
FLOAT_WIDTH=20;
FLOAT_HEIGHT=10;
SMOOTH_RADIUS=2;
FLOAT_CROSSBAR=50;

module edge_smoother_2d(radius) {
    translate([-radius/2,radius/2,0]) rotate([0,0,-90])
        difference() {
            square(radius);
            circle(r=radius);
        }
}

module t_bar() {
    translate([0,-(FLOAT_WIDTH-2*SMOOTH_RADIUS)/2])
        square([FLOAT_DEPTH-2*SMOOTH_RADIUS,FLOAT_WIDTH-2*SMOOTH_RADIUS]);
    translate([0,-(FLOAT_CROSSBAR-2*SMOOTH_RADIUS)/2])
        square([FLOAT_WIDTH-2*SMOOTH_RADIUS,FLOAT_CROSSBAR-2*SMOOTH_RADIUS]);
    translate([FLOAT_DEPTH-FLOAT_WIDTH,-(FLOAT_CROSSBAR-2*SMOOTH_RADIUS)/2])
        square([FLOAT_WIDTH-2*SMOOTH_RADIUS,FLOAT_CROSSBAR-2*SMOOTH_RADIUS]);
}

module 2d_float() {
    minkowski() {
        t_bar();
        circle(SMOOTH_RADIUS);
    }
}

module 3d_float() {
    linear_extrude(FLOAT_HEIGHT)
    2d_float();
}

//t_bar();
3d_float();