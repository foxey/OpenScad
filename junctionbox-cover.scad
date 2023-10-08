$fn = 64;
TOL = .01;

HEIGHT = 86;
WIDTH = 70;
DEPTH = 3;

CORNER_RADIUS = 5;

MOUNT_D1 = 3.2;
MOUNT_D2 = 5.5;
MOUNT_DEPTH = 1;
MOUNT_DISTANCE = 60;
HORIZONTAL_MOUNT_POS = WIDTH - 29;
VERTICAL_MOUNT_POS = (HEIGHT - MOUNT_DISTANCE)/2;


module corner_2dshape() {
    difference() {
        translate([CORNER_RADIUS - DEPTH, 0, 0])
            circle(r=DEPTH);
        translate([-2*CORNER_RADIUS,-CORNER_RADIUS])
            square([2*CORNER_RADIUS, 2*CORNER_RADIUS]);
    }
}

module corner() {
    rotate_extrude()
        corner_2dshape();
}

module cover_base()
    difference() {
        translate([CORNER_RADIUS, CORNER_RADIUS, 0])
            hull()
                for (x = [0, WIDTH - 2*CORNER_RADIUS])
                    for (y = [0, HEIGHT - 2*CORNER_RADIUS])
                        translate([x, y, 0])
                            corner();
        translate([0, 0, -DEPTH-TOL])
            cube([WIDTH+TOL, HEIGHT+TOL, DEPTH+TOL]);
    }

module mount_hole() {
    translate([0, 0, -TOL])
        union() {
            cylinder(d = MOUNT_D1, h = DEPTH + 2*TOL);
            translate([0, 0, MOUNT_DEPTH])
                cylinder(d = MOUNT_D2, h = DEPTH + 2*TOL);
        }
}

module cover() {
    difference() {
        cover_base();
        translate([HORIZONTAL_MOUNT_POS, VERTICAL_MOUNT_POS])
            mount_hole();
                translate([HORIZONTAL_MOUNT_POS, HEIGHT - VERTICAL_MOUNT_POS])
            mount_hole();

    }
}

translate([0, HEIGHT, DEPTH])
    rotate([180, 0, 0])
        cover();