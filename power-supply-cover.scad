$fn = 64;
TOL = .01;

DEPTH = 1;
5V_WIDTH = 29;
5V_HEIGHT = 17;
5V_WIDTH_CUTOUT = 5;
5V_HEIGHT_CUTOUT = 3;

230V_WIDTH1 = 32;
230V_HEIGHT1 = 18;
230V_DEPTH1 = 2;
230V_WIDTH2 = 35;
230V_HEIGHT2 = 21;
230V_DEPTH2 = 3;
230V_WIDTH_CUTOUT = 10;
230V_HEIGHT_CUTOUT = 7;

OUTER_COVER_RADIUS = 3;
OUTER_COVER_CUTOUT = .5;

module 5v_cover() {
    difference() {
        cube([5V_WIDTH, 5V_HEIGHT, DEPTH]);
        translate([(5V_WIDTH - 5V_WIDTH_CUTOUT)/2, (5V_HEIGHT - 5V_HEIGHT_CUTOUT)/2, -TOL])
            cube([5V_WIDTH_CUTOUT, 5V_HEIGHT_CUTOUT, DEPTH+2*TOL]);
    }
}

module outer_cover() {
    // cube([230V_WIDTH2, 230V_HEIGHT2, 230V_DEPTH2]);
    translate([OUTER_COVER_RADIUS, OUTER_COVER_RADIUS, 0])
        hull() {
            for (x = [0, 230V_WIDTH2 - 2*OUTER_COVER_RADIUS])
                for (y = [0, 230V_HEIGHT2 - 2*OUTER_COVER_RADIUS])
                    translate([x, y, 0])
                        cylinder(r = OUTER_COVER_RADIUS, h = 230V_DEPTH2);
        }
}

module 230v_cover() {
    difference() {
        union() {
            translate([(230V_WIDTH2 - 230V_WIDTH1)/2, (230V_HEIGHT2 - 230V_HEIGHT1)/2, 230V_DEPTH2])
                cube([230V_WIDTH1, 230V_HEIGHT1, 230V_DEPTH1]);
            outer_cover();
        }
        translate([(230V_WIDTH2 - 230V_WIDTH1)/2 + DEPTH, (230V_HEIGHT2 - 230V_HEIGHT1)/2 + DEPTH, DEPTH])
            cube([230V_WIDTH1 - 2*DEPTH, 230V_HEIGHT1 - 2*DEPTH, 230V_DEPTH1 + 230V_DEPTH2 + TOL]);
        translate([4, 5.5, -TOL])
            cube([230V_WIDTH_CUTOUT, 230V_HEIGHT_CUTOUT, DEPTH + 2*TOL]);
        translate([21.5, 5.5, -TOL])
            cube([230V_WIDTH_CUTOUT, 230V_HEIGHT_CUTOUT, DEPTH + 2*TOL]);
        translate([4, 230V_HEIGHT1 - TOL, 230V_DEPTH2 - OUTER_COVER_CUTOUT])
            cube([230V_WIDTH_CUTOUT, 230V_HEIGHT_CUTOUT, 230V_DEPTH1 + OUTER_COVER_CUTOUT + TOL]);
        translate([21.5, 230V_HEIGHT1 - TOL, 230V_DEPTH2 - OUTER_COVER_CUTOUT])
            cube([230V_WIDTH_CUTOUT, 230V_HEIGHT_CUTOUT, 230V_DEPTH1 + OUTER_COVER_CUTOUT + TOL]);

    }
}

// translate([40, 0, 0]) 5v_cover();
230v_cover();