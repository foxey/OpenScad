// Wall clip for Home Assistant Yellow
//
// Copyright (C) 2023 Michiel Fokke <michiel@fokke.org>
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

BASE_X = 28;
BASE_Z = 2;
BASE_D = 14;

CASE_SCREW_Z = 3;

WALL_SCREW_INNER_D = 3;
WALL_SCREW_OUTER_D = 7;
WALL_SCREW_CONE_Z = 6;

NOTCH_X = 5;
NOTCH_D = 2;
NOTCH_R_SCREW = 5;
SCREW_D = 5.5;

module base(x, d, h) {
    hull() {
        cylinder(d=d, h=h);
        translate([x - d, 0, 0])
        cylinder(d=d, h=h);        
    }
}

module wall_clip_base() {
    base(BASE_X, BASE_D, BASE_Z);
}

module screw_hole() {
    translate([BASE_X - BASE_D, 0, 0])
        cylinder(d=SCREW_D, h=BASE_Z + 2*TOL);
}

module wall_screw_hole() {
    cylinder(d=WALL_SCREW_INNER_D, h= BASE_Z + CASE_SCREW_Z + 2*TOL);
            cylinder(d2=0, d1=WALL_SCREW_OUTER_D, h=WALL_SCREW_CONE_Z);
}

module wall_screw_hole_cutout(angle=0) {
    rotate(angle)
        translate([0, 0, -TOL])
            base(BASE_X, WALL_SCREW_INNER_D, BASE_Z + CASE_SCREW_Z + 2*TOL);
}

module screw_base() {
    cylinder(d=BASE_D, h=BASE_Z + CASE_SCREW_Z);
}

module notch_hole() {
    base(NOTCH_X, NOTCH_D, BASE_Z + 2*TOL);
}

module wall_clip(angle) {
    difference() {
        union() {
            screw_base();
            wall_clip_base();
        }
        translate([0, 0, -TOL]) {
            screw_hole();
            wall_screw_hole();
            translate([BASE_X - (BASE_D - NOTCH_D)/2 - (BASE_D/2 - NOTCH_R_SCREW), 0, 0])
                notch_hole();
        }
        wall_screw_hole_cutout(angle);
    }
}


wall_clip(45);
translate([0, 1.25*BASE_D, 0])
    wall_clip(-45);
translate([1.25*BASE_X, 0, 0])
    wall_clip(135);
translate([1.25*BASE_X, 1.25*BASE_D, 0])
    wall_clip(-135);