// Iron table grip with safety lock
// (c) 2020 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

$fn = 64;
TOL = .01;

GRIP_HEIGHT = 58;
WALL = 2;
ROD_D = 7.75;
WIDTH_BOTTOM = 48 + ROD_D + WALL;
WIDTH_TOP = WIDTH_BOTTOM - 12;

module  top() {
    r = ROD_D + 2*WALL;
    translate([-r/2, -r/2, 0]) 
        intersection() {
            cylinder(h = TOL, r = 12);
            translate([0, 0, -TOL]) cube([r+TOL, r+TOL, 3*TOL]);
        }
}

module iron_table_grip_base() {
    hull() {
        d = ROD_D + 2*WALL;
        x = ROD_D + WALL;
        z = GRIP_HEIGHT - d - TOL;
        cylinder(d = d, h = TOL);
        translate([0, 0, z]) cylinder(d = d, h = TOL);
        translate([WIDTH_BOTTOM - x, 0, 0]) top();
        translate([WIDTH_TOP - x, 0, z]) top();
    }
}

module iron_table_grip(ARGS) {
  difference() {
    iron_table_grip_base();
    translate([0, 0, WALL]) cylinder(d = ROD_D, h = GRIP_HEIGHT); 
  }
}

iron_table_grip();