// Round Electric Box
// (c) 2022 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

// Number of facets in a circle
// $fn = 16;
$fn = 64;

// Tolerance to prevent non manifold objects (0 height)
TOL = .1;

D = 126.5; // Outer diameter
Z = 16; // Outer depth
Z_bottom = 1; // Back wall depth
D_edge = 10; // Outer wall thickness

D_screw = 2;
D_screw_outer = 5;

D_screw_hole = 2;
D_screw_hole_hull = 4;
D_screw_hole_outer = 5;
X_screw_holes = (D - D_edge)/2;
Y_screw_holes = 4*D_edge/2;
Z_screw_hole_edge = 2;

D_cable_hole = 10;

D_screw_mount = 2;
D_screw_mount_outer = 11;
Z_screw_mount = Z;
X_screw_mount = D - 2*19;
Y_screw_mount = 4;

D_water_hole = 2;

module screw_hole() {
    translate([-D_screw_hole_hull/2, 0, -TOL])
        hull() {
            cylinder(d=D_screw_hole, h=Z);
            translate([D_screw_hole_hull, 0, 0])
                cylinder(d=D_screw_hole, h=Z);
        }
}

module screw_holes(x, y) {
    translate([-x/2, y, 0])
        screw_hole();
    translate([x/2, y, 0])
        rotate([0, 0, 90])
            screw_hole();
}

module cable_hole() {
    translate([0, 0, -TOL])
        cylinder(d=D_cable_hole, h=Z);
}

module water_hole() {
    translate([0, -(D - D_edge/2)/2, Z_bottom + D_water_hole/2])
        rotate([90, 0, 0])
            cylinder(d=D_water_hole, h=2*D_edge, center=true);
}

module round_box() {
    difference() {
        {
            $fn = 365;
            cylinder(d=D, h=Z);
        }
        translate([0,0, Z_bottom])
            cylinder(d=D-D_edge, h=Z);
        screw_holes(X_screw_holes, Y_screw_holes);
        cable_hole();
        water_hole();
    }
}

module screw_hole_edge() {
    difference() {
        translate([-D_screw_hole_hull/2, 0, 0])

            hull() {
                cylinder(d=D_screw_hole_outer, h=Z_screw_hole_edge);
                translate([D_screw_hole_hull, 0, 0])
                    cylinder(d=D_screw_hole_outer, h=Z_screw_hole_edge);
            }
            screw_hole();
    }
}

module screw_hole_edges(x, y) {
    translate([-x/2, y, 0])
        screw_hole_edge();
    translate([x/2, y, 0])
        rotate([0, 0, 90])
            screw_hole_edge();
}

module screw_mount() {
    difference() {
        union() {
            cylinder(d=D_screw_mount_outer, h=Z_screw_mount);
            cylinder(d=2*D_screw_mount_outer, h=Z_screw_hole_edge);
        }
        translate([0, 0, -TOL])
            cylinder(d=D_screw_mount, h=Z_screw_mount + 2*TOL);
    }
}

module screw_mounts(x, y) {
    translate([-x/2, y, 0])
        screw_mount();
    translate([x/2, y, 0])
        screw_mount();
}

union() {
    round_box();
    screw_hole_edges(X_screw_holes, Y_screw_holes);
    screw_mounts(X_screw_mount, Y_screw_mount);
}