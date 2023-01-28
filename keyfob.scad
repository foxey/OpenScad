// Case for after market car alarm keyfob
//
// Copyright (C) 2022 Michiel Fokke <michiel@fokke.org>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

$fn = 72;
TOL = .1;

PCB_X = 32;
PCB_Y = 39;
PCB_Z = 1;

Z_BATTERY = 3.5;
SLIT_X = 2;
Z_LED = 3;
BUTTON_X = 6; 
BUTTON_Y = 4; 
BUTTON_Z = 4;
BUTTON_Y_POSITION = 28;

BUTTON_CUTOUT_X = 10;
BUTTON_CUTOUT_Y = 18;
BUTTON_CUTOUT_Z = 5 - 5*TOL;
BUTTON_CORNER_R = 3;
LED_Y_POSITON = 3;
BATTERY_Y = 23.5;

CASE_KEYHOLE_Y = 10;
KEYHOLE_D = 4;

WALL_THICKNESS = 1;
CASE_X = PCB_X + 2*(WALL_THICKNESS + TOL);
CASE_Y = PCB_Y + CASE_KEYHOLE_Y + WALL_THICKNESS + TOL;
CASE_Z = Z_BATTERY + 2*(WALL_THICKNESS + TOL);
CASE_CORNER_R = 2;

module rounded_cube(x, r) {
    translate([r, r, 0])
        hull() {
            translate([0, 0, 0])
                cylinder(r=r, h=x[2]);
            translate([x[0] - 2*r, 0, 0])
                        cylinder(r=r, h=x[2]);
            translate([0, x[1] - 2*r, 0])
                        cylinder(r=r, h=x[2]);
            translate([x[0] - 2*r, x[1] - 2*r, 0])
                        cylinder(r=r, h=x[2]);
        }
}

module outer_case_hull() {
    rounded_cube([CASE_X, CASE_Y, CASE_Z], CASE_CORNER_R);
}

module pcb() {
    rounded_cube([PCB_X + 2*TOL, PCB_Y + CASE_KEYHOLE_Y + CASE_CORNER_R + 2*TOL, PCB_Z + 2*TOL], CASE_CORNER_R);
}

module component_cutout() {
    translate([SLIT_X, 0, 0])
    cube([PCB_X - 2*SLIT_X, PCB_Y + CASE_KEYHOLE_Y + CASE_CORNER_R + 2*TOL, Z_LED + 2*TOL]);
}

module battery_cutout() {
    translate([0, -TOL, 0])
    cube([PCB_X + 2*TOL, CASE_CORNER_R + BATTERY_Y, Z_BATTERY]);
}

module button_cutout(){
        rounded_cube([BUTTON_CUTOUT_X, BUTTON_CUTOUT_Y, BUTTON_CUTOUT_Z ], BUTTON_CORNER_R);
}

module button_cutout_2() {
    cube([BUTTON_X, BUTTON_Y_POSITION + BUTTON_Y - CASE_KEYHOLE_Y/2, BUTTON_Z]);
}

module cutout() {
            translate([0, 0, WALL_THICKNESS])
        union() {
            translate([WALL_THICKNESS + TOL, -CASE_CORNER_R, 0]) {
                pcb();
                component_cutout();
                battery_cutout();
            }
            translate([(CASE_X - BUTTON_CUTOUT_X)/2, CASE_Y - BUTTON_CUTOUT_Y - WALL_THICKNESS, 0])
                button_cutout();
            translate([(CASE_X - BUTTON_X)/2, CASE_KEYHOLE_Y/2, 0])
                button_cutout_2();
        }
}

module keyring_hole() {
        translate([CASE_X/2, CASE_KEYHOLE_Y/2, -TOL])
            cylinder(d=KEYHOLE_D, h=CASE_Z + 2*TOL);
}

module view_slicer() {
    translate([-10 + CASE_CORNER_R, -10, -10])
        cube([10, 100, 100]);
}

module keyfob_case() {
    difference() {
        outer_case_hull();
        keyring_hole();
        cutout();
        *view_slicer();
    }
}

translate([0, 0, CASE_Y])
    rotate([270, 0, 0])
        keyfob_case();