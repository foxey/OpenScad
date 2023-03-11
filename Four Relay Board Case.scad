// Four Relay Board Case
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
TOL = .01;

Z_LAYER = .15;
TOLERANCE = .25;

WALL_THICKNESS = 2; // Wall thickness of the case

X_BOARD = 87; // Lenght of the PCB
Y_BOARD = 93;
Z_BOARD = 5; // Height of the board (PCB + spacing for through hole pins)
Z_PCB = 1.5; // Height of the PCB
X_RELAY = 19;
Y_RELAY = 63;
Z_RELAY = 15;
X_POS_RELAY = 12;
Y_POS_RELAY = 3;
D_BOARD_HOLE = 4;
X_BOARD_HOLES = 80;
Y_BOARD_HOLES = 85;

X_BOARD_MARGIN_TOP = 20;
X_BOARD_MARGIN_BOTTOM = 10;
X_BOARD_MARGIN = X_BOARD_MARGIN_TOP + X_BOARD_MARGIN_BOTTOM;
Y_BOARD_MARGIN_TOP = 20;
Y_BOARD_MARGIN_BOTTOM = 1;
Y_BOARD_MARGIN = Y_BOARD_MARGIN_TOP + Y_BOARD_MARGIN_BOTTOM;
X_CASE = X_BOARD + X_BOARD_MARGIN; // Inside length of the case
Y_CASE = Y_BOARD + Y_BOARD_MARGIN; // Inside width of the case
Z_CASE = 32; // Height of the case (minus the top and bottom parts)
Z_LID = -2*WALL_THICKNESS + Z_BOARD;

SHIFT_FACTOR = .5; // fraction of corner radius for recess for top and bottom
X_HOLE = X_CASE - 7; // Length between mount holes
Y_HOLE = Y_CASE - 8; // Width between mount holes

R_PORT = 3.25;
Z_PORT = Z_BOARD + 2*R_PORT;
X_MAIN_PORT = 45;
Y_OUTLET_PORT = 75;

R_CORNER = (X_CASE-X_HOLE)/2 + TOLERANCE; // Radius of the corners of the board

M3NUT_Z = 3; // exact: 2.3
M3BOLT_Z = 11.5; // exact: 11
M3BOLTHEAD_Z = 3.5; // exact 3
M3BOLT_D = 3;
M3BOLTHEAD_D= 5.5;

D_STRAIN_RELIEF_CABLE = 6.5;
X_MAINS_STRAIN_RELIEF = 40;
Y_MAINS_STRAIN_RELIEF = 10;
Z_MAINS_STRAIN_RELIEF = WALL_THICKNESS + D_STRAIN_RELIEF_CABLE/2;
Z_TOP_STRAIN_RELIEF = 5;
D_STRAIN_RELIEF_SCREW = 1.5;
D_TOP_STRAIN_RELIEF_SCREW = 2.5;
D_STRAIN_RELIEF_SCREW_CAP = 5;

X_POS_PUSH_BUTTON_1 = -R_CORNER + X_BOARD_MARGIN_TOP + X_POS_RELAY + X_RELAY + 6;
Y_POS_PUSH_BUTTON_1 = (Y_CASE - R_CORNER)*3/4;
X_POS_PUSH_BUTTON_2 = X_POS_PUSH_BUTTON_1;
Y_POS_PUSH_BUTTON_2 = (Y_CASE - 2*R_CORNER)/2;
X_POS_LED = X_POS_PUSH_BUTTON_1;
Y_POS_LED = (Y_CASE - R_CORNER)/4;
D_PUSH_BUTTON = 12;
D_LED = 8;

// Module: BCP_stands - 4 cylinders centered at the holes in the PCB
module PCB_stands(d, h) {
        translate([(X_BOARD - X_BOARD_HOLES)/2, (Y_BOARD - Y_BOARD_HOLES)/2, -TOL])
            cylinder(d=d, h=h);
        translate([(X_BOARD - X_BOARD_HOLES)/2, (Y_BOARD + Y_BOARD_HOLES)/2, -TOL])
            cylinder(d=d, h=h);
        translate([(X_BOARD + X_BOARD_HOLES)/2, (Y_BOARD - Y_BOARD_HOLES)/2, -TOL])
            cylinder(d=d, h=h);
        translate([(X_BOARD + X_BOARD_HOLES)/2, (Y_BOARD + Y_BOARD_HOLES)/2, -TOL])
            cylinder(d=d, h=h);
}


// Module: BCP - Mock of the PCB with connectors
module PCB() {
    difference() {
        union() {
            cube([X_BOARD, Y_BOARD, Z_BOARD]);
            translate([X_POS_RELAY, Y_BOARD - Y_POS_RELAY - Y_RELAY, -Z_RELAY])
                cube([X_RELAY, Y_RELAY, Z_RELAY]);
            translate([X_BOARD - 40, Y_BOARD - 37, -14])
                cylinder(d=8, h=14);
            translate([X_BOARD - 35, Y_BOARD - 60, -14])
                cylinder(d=8, h=14);
            
        }
        PCB_stands(D_BOARD_HOLE, Z_BOARD + 2*TOL);
    }
}


// Module: push_button - Mock of the push button
module push_button() {
    color("darkgreen")
        cylinder(d=12, h=4);
    color("black") {
    translate([0, 0, 4])
        cylinder(d1=14, d2=18, h=6);
    translate([0, 0, 10])
        cylinder(d=12, h=9);
    translate([0, 0, 19])
        cylinder(d=10.5, h=20);
    }
}


// Module: LED - Mock of the LED with holder
module LED() {
    color("darkred")
        sphere(d=5);
    color("lightgrey") {
        cylinder(d1=8, d2=9, h=4);
        translate([0, 0, 4])
            cylinder(d=7.5, h=9);
    }
}


// Module: m3nut - M3 nut
// Z = height of the nut
// rotate = orientation of the flat sides
module m3nut(Z, rotate=0) {
    $fn=6;
    rotate([0,0,rotate]) cylinder(d=6.2, h=Z);
}


// Module: base_case - Solid hull of case
module base_case(height, thickness=0) {
    h = height + 2*thickness;
    r = R_CORNER + thickness;
    hull() {
        translate([0, 0, 0]) cylinder(r=r, h=h);
        translate([X_HOLE, 0, 0]) cylinder(r=r, h=h);
        translate([0, Y_HOLE, 0]) cylinder(r=r, h=h);
        translate([X_HOLE, Y_HOLE, 0]) cylinder(r=r, h=h);
    }
}


// Module: case - Hollow outer wall of case
module case() {
    difference(){
        base_case(Z_CASE, WALL_THICKNESS);
        translate([0, 0, -WALL_THICKNESS]) base_case(Z_CASE);
        translate([0, 0, 3*WALL_THICKNESS]) base_case(Z_CASE);
    }
}

module case_corner(r, shift) {
   hull() {
        translate([shift, shift, -r]) cylinder(r=r, h= .1);
        translate([0, 0, -.1]) cylinder(r=r, h= .1);
   }
}

// Module: base_case_top - Solid top with rounded edges and corners
// thickness = wall thickness
module base_case_top(thickness, shift_factor) {
    hull() {
        radius = R_CORNER + thickness;
        translate([0, 0, 0]) rotate([0, 0, 0]) case_corner(radius, shift_factor*radius);
        translate([X_HOLE, 0, 0]) rotate([0, 0, 90]) case_corner(radius, shift_factor*radius);
        translate([0, Y_HOLE, 0]) rotate([0, 0, -90]) case_corner(radius, shift_factor*radius);
        translate([X_HOLE, Y_HOLE, 0]) rotate([0, 0, -180]) case_corner(radius, shift_factor*radius);
    }
}


// Module: case_top - Hollow case top
module case_top(){
    difference(){
        base_case_top(WALL_THICKNESS, SHIFT_FACTOR);
        translate([0, 0, TOL]) base_case_top(0*WALL_THICKNESS/2, SHIFT_FACTOR);
    }
}


// Module: nut_stand: cylinder with slit for M3 nut and pylon to prevent overhang
module nut_stand(){
    rotate([180, 0, 0])
        difference(){
            h = Z_CASE + WALL_THICKNESS + R_CORNER - TOLERANCE;
            hull(){
                cylinder(r=R_CORNER+WALL_THICKNESS-TOL, h=h);
                intersection() {
                    translate([R_CORNER+.2*WALL_THICKNESS, 0, h+WALL_THICKNESS+R_CORNER-.1]) cylinder(r=R_CORNER+WALL_THICKNESS, h=.1);
                    translate([0, 0, h+WALL_THICKNESS+R_CORNER-.1]) cylinder(r=R_CORNER+WALL_THICKNESS, h=.1);
                }
            }
            translate([0, 0, WALL_THICKNESS/2]) m3nut(M3NUT_Z);
            translate([0, 0, WALL_THICKNESS/2+M3NUT_Z]) {
                hull(){
                    m3nut(M3NUT_Z);
                    translate([2*(R_CORNER+WALL_THICKNESS), 0, 0]) m3nut(M3NUT_Z);
                }
            }
            translate([0, 0, -.1]) cylinder(d=M3BOLT_D, h=WALL_THICKNESS+.2);
        }
}


// Module: nut_stands - 4 nut_stand's positioned in each corner of the case
module nut_stands(){
    difference() {
        z_offset = Z_CASE + WALL_THICKNESS + R_CORNER - TOLERANCE;
        union() {
            translate([0, 0, z_offset]) rotate([0, 0, 45]) nut_stand();
            translate([X_HOLE, 0, z_offset]) rotate([0, 0, 135]) nut_stand();
            translate([0, Y_HOLE, z_offset]) rotate([0, 0, -45]) nut_stand();
            translate([X_HOLE, Y_HOLE, z_offset]) rotate([0, 0, -135]) nut_stand();
        }
        difference() {
            base_case(z_offset, WALL_THICKNESS);
            translate([0, 0, -WALL_THICKNESS]) base_case(z_offset+3*WALL_THICKNESS+TOL, -TOLERANCE);        }
    }
}

module mains_strain_relief() {
    difference() {
        cube([X_MAINS_STRAIN_RELIEF, Y_MAINS_STRAIN_RELIEF, Z_MAINS_STRAIN_RELIEF]);
        translate([.5*X_MAINS_STRAIN_RELIEF, Y_MAINS_STRAIN_RELIEF + TOL, Z_MAINS_STRAIN_RELIEF]) 
            rotate([90, 0, 0])
                cylinder(d=D_STRAIN_RELIEF_CABLE, h=Y_MAINS_STRAIN_RELIEF + 2*TOL);
        translate([.2*X_MAINS_STRAIN_RELIEF, Y_MAINS_STRAIN_RELIEF/2, -TOL])
            cylinder(d=D_STRAIN_RELIEF_SCREW, h=Z_MAINS_STRAIN_RELIEF + 2*TOL);
        translate([.8*X_MAINS_STRAIN_RELIEF, Y_MAINS_STRAIN_RELIEF/2, -TOL])
            cylinder(d=D_STRAIN_RELIEF_SCREW, h=Z_MAINS_STRAIN_RELIEF + 2*TOL);
    }
}

module top_strain_relief() {
    difference() {
        y_top = .8*Y_MAINS_STRAIN_RELIEF;
        cube([X_MAINS_STRAIN_RELIEF, y_top, Z_TOP_STRAIN_RELIEF]);
        translate([.5*X_MAINS_STRAIN_RELIEF, Y_MAINS_STRAIN_RELIEF + TOL, 1.3*Z_MAINS_STRAIN_RELIEF]) 
            rotate([90, 0, 0])
                cylinder(d=D_STRAIN_RELIEF_CABLE, h=Y_MAINS_STRAIN_RELIEF + 2*TOL);
        translate([.2*X_MAINS_STRAIN_RELIEF, y_top/2, -TOL]) {
            cylinder(d=D_TOP_STRAIN_RELIEF_SCREW, h=Z_MAINS_STRAIN_RELIEF + 2*TOL);
            translate([0, 0, -TOL])
                cylinder(d=D_STRAIN_RELIEF_SCREW_CAP, h=2 + TOL);
        }
        translate([.8*X_MAINS_STRAIN_RELIEF, y_top/2, -TOL]) {
            cylinder(d=D_TOP_STRAIN_RELIEF_SCREW, h=Z_MAINS_STRAIN_RELIEF + 2*TOL);
            translate([0, 0, -TOL])
                cylinder(d=D_STRAIN_RELIEF_SCREW_CAP, h=2 + TOL);
        }
    }
}


// Module: side_cut - shave of side of bolt_stand
// r = radius
// h = height
// shift = distance between top and bottom
module side_cut(r, h, shift) {
    translate([-2*r, -2*r, 0])
        hull() {
            case_corner(r, shift);
            translate([0, 2*h, 0]) case_corner(r, shift);
        }
}


module rotated_side_cut(r, h, shift) {
    translate([0, 0, 0])
        rotate([0, 0, 90]) 
            side_cut(r, h, shift);
}


module cylindrical_cut(r, shift) {
    difference() {
        translate([-r, -r, -r]) cube([2*r, 2*r, r]);
        case_corner(r, shift);
    }
}


// Module: bolt_stand: cylinder with hole for M3 bolt
module bolt_stand() {
    r = R_CORNER + WALL_THICKNESS;
    shift = SHIFT_FACTOR*r;
    difference(){
        translate([0, 0, -r]) cylinder(r=r, h=r+WALL_THICKNESS);
        cylindrical_cut(r, shift);
        side_cut(r, 2*r, shift);
        rotated_side_cut(r, 2*r, shift);
    }
}


// Module: bolt_stands - 4 bolt_stand-s positioned in each corner of the case
module bolt_stands(){
    z_offset = 0;
    translate([0, 0, z_offset]) rotate([0, 0, 0]) bolt_stand();
    translate([X_HOLE, 0, z_offset]) rotate([0, 0, 90]) bolt_stand();
    translate([0, Y_HOLE, z_offset]) rotate([0, 0, 270]) bolt_stand();
    translate([X_HOLE, Y_HOLE, z_offset]) rotate([0, 0, 180]) bolt_stand();
}


// Module: bolt_hole
module bolt_hole() {
    r = R_CORNER + WALL_THICKNESS;
    union() {
        translate([0, 0, -r]) cylinder(d=M3BOLT_D, h=r+WALL_THICKNESS);
        translate([0, 0, -r]) cylinder(d=M3BOLTHEAD_D, h=r+WALL_THICKNESS-1);
    }
}


// Module: bolt_holes - 4 bolt_hole-s positioned in each corner of the case
module bolt_holes(){
    z_offset = 0;
    translate([0, 0, z_offset]) rotate([0, 0, 90]) bolt_hole();
    translate([X_HOLE, 0, z_offset]) rotate([0, 0, 180]) bolt_hole();
    translate([0, Y_HOLE, z_offset]) rotate([0, 0, 0]) bolt_hole();
    translate([X_HOLE, Y_HOLE, z_offset]) rotate([0, 0, 270]) bolt_hole();
}


// Module: border - 1mm recessed border around a port hole
// x = Width of the port
// y = Depth of the port
// z = Height of the port
// r = Width of the border
// right = true if port is on the right side, false if port is on the left
module border(r, x, y, z, right=false) {
    y_offset = right ? -y+r : -r;
    translate([-1, y_offset, -z])
        hull() {
            //cube([x, y, z]);
            translate([0, r, z-Z_BOARD])
                rotate([0, 90, 0])
                    cylinder(h=x, r=r);
            translate([0, -r+y, z-Z_BOARD])
                rotate([0, 90, 0])
                    cylinder(h=x, r=r);
            translate([0, r, -2*r])
                rotate([0, 90, 0])
                    cylinder(h=x, r=r);
            translate([0, -r+y, -2*r])
                rotate([0, 90, 0])
                    cylinder(h=x, r=r);
        }
}

// Module: side_port: wire passthrough
module side_port(width, rotate_z = 0) {
    r = R_PORT;
    height = Z_PORT;
    h = 2*WALL_THICKNESS;
        rotate([90, 0, rotate_z])
        translate([r - width/2, r - height/2, -h/2])
            hull() {
                cylinder(r=r, h=h);
                translate([0, height - 2*r, 0]) cylinder(r=r, h= h);
                translate([width - 2*r, 0, 0]) cylinder(r=r, h= h);
                translate([width - 2*r, height - 2*r, 0]) cylinder(r=r, h= h);
            }
}


// Module: full_case - full top case including port cutouts
module full_case() {
    difference() {
        union() {
            case();
            case_top();
            bolt_stands();
        }
        bolt_holes();
        translate([X_POS_PUSH_BUTTON_1, Y_POS_PUSH_BUTTON_1, -TOL - WALL_THICKNESS - R_CORNER])
            cylinder(d=D_PUSH_BUTTON, h=2*WALL_THICKNESS);
        translate([X_POS_PUSH_BUTTON_2, Y_POS_PUSH_BUTTON_2, -TOL - WALL_THICKNESS - R_CORNER])
            cylinder(d=D_PUSH_BUTTON, h=2*WALL_THICKNESS);
        translate([X_POS_LED, Y_POS_LED, -TOL - WALL_THICKNESS - R_CORNER])
            cylinder(d=D_LED, h=2*WALL_THICKNESS);
    }
}


// Module: wall_mount_hole - screw hole for wall mount
module wall_mount_hole() {
    translate([0, 0, R_CORNER+WALL_THICKNESS/2]) {
        cylinder(d=7, h=2*WALL_THICKNESS);
        hull() {
            translate([0, 0, WALL_THICKNESS/4]) cylinder(d=7, h=WALL_THICKNESS);
            translate([0, 3.5, -WALL_THICKNESS/2]) cylinder(d=7, h=WALL_THICKNESS);
        }
        hull() {
            cylinder(d=7, h=WALL_THICKNESS);
            translate([0, 3.5+5, 0]) cylinder(d=7, h=WALL_THICKNESS);
        }
        hull() {
            cylinder(d=3, h=2*WALL_THICKNESS);
            translate([0, 3.5+5, 0]) cylinder(d=3, h=2*WALL_THICKNESS);
        }
    }
}

// Module: wall_mount_hole_cover - internal cover for screw hole to protect backside of the PCB
module wall_mount_hole_cover() {
    translate([0, 0, R_CORNER-WALL_THICKNESS+1]) {
        difference() {
            hull() {
                cylinder(d1=9, d2=12, h=3);
                translate([0, 3.5+5, 0]) cylinder(d1=9, d2=12, h=3);
            }
            translate([0, 0, -.1]) hull() {
                translate([0, 0, 1.1]) cylinder(d1=5.5, d2=7, h=2.1);
                translate([0, 3.5+5, 1.1]) cylinder(d1=5.5, d2=7, h=2.1);
            }
        }
    }
}


// Module: full_lid - Bottom lid to close the case
module full_lid() {
    z_offset =  0;
    union() {
        difference() {
            translate([0, Y_HOLE, WALL_THICKNESS])
                rotate([180, 0, 0])
                    difference() {
                        union() {
                            difference() {
                                base_case(Z_LID, WALL_THICKNESS);
                                translate([0, 0, -WALL_THICKNESS]) base_case(Z_CASE);
                            }
                            case_top();
                            nut_stands();
                        }
                    }
            // Wall mount openings
            translate([X_CASE/4, 2*Y_CASE/3, z_offset]) wall_mount_hole();
            translate([3*X_CASE/4, 2*Y_CASE/3, z_offset]) wall_mount_hole();
            // Mains port
            translate([X_MAIN_PORT, -2.5*WALL_THICKNESS, -Z_MAINS_STRAIN_RELIEF + D_STRAIN_RELIEF_CABLE/2+0*TOL])
                side_port(6.5);
            // Outlet port
            translate([-2.5*WALL_THICKNESS, Y_OUTLET_PORT, -Z_MAINS_STRAIN_RELIEF + D_STRAIN_RELIEF_CABLE/2+TOL])
                side_port(6.5, 90);
        }
        // Basis of strain reliefs
        translate([0, Y_HOLE, WALL_THICKNESS])
                rotate([180, 0, 0]) {
                    translate([X_MAIN_PORT - X_MAINS_STRAIN_RELIEF/2, Y_BOARD - R_CORNER + Y_BOARD_MARGIN - Y_MAINS_STRAIN_RELIEF - .5, - R_CORNER])
                        mains_strain_relief();
                    translate([Y_MAINS_STRAIN_RELIEF/2 + WALL_THICKNESS - 1, Y_CASE - 4*WALL_THICKNESS - Y_OUTLET_PORT - X_MAINS_STRAIN_RELIEF/2, -2*WALL_THICKNESS])
                        rotate([0, 0, 90])
                        mains_strain_relief();
                }

        // Cover to protect backside PCB from wall mount screws
        translate([X_CASE/4, 2*Y_CASE/3, z_offset]) wall_mount_hole_cover();
        translate([3*X_CASE/4, 2*Y_CASE/3, z_offset]) wall_mount_hole_cover();
        translate([X_BOARD_MARGIN_TOP -R_CORNER, Y_BOARD_MARGIN_TOP - R_CORNER, z_offset + 0]) {
            difference() {
                union() {
                    PCB_stands(D_BOARD_HOLE + 2, 6.5);
                    translate([0, 0, -1]) PCB_stands(D_BOARD_HOLE -.75, 7.5);
                }
                translate([0, 0, -1.5]) PCB_stands(D_BOARD_HOLE - 2, 10);
            }
        }
    }
}

module washer() {
    difference() {
        height = 2;
        translate([0, 0, height/2]) cube([6, 6, 2], center = true);
        translate([0, 0, -TOL]) cylinder(d=2.5, h=height+2*TOL);
    }
}

difference() {
    union() {
        full_case();
        *translate([0, 0, Z_CASE + Z_BOARD + WALL_THICKNESS + TOL]) full_lid();
    }
    *translate([70, -10, -10]) cube([20 + X_CASE, 20 + Y_CASE, 25]);
}

*color("lightblue")
    translate([-R_CORNER + X_BOARD_MARGIN_TOP, -R_CORNER + Y_BOARD_MARGIN_TOP, Z_CASE + Z_BOARD + WALL_THICKNESS + TOL - Z_PCB])
        PCB();

translate([0, -.2*Y_CASE, WALL_THICKNESS])
    rotate([-180, 0, 0])
        full_lid();

*color("lightblue")
    translate([-R_CORNER + X_BOARD_MARGIN_TOP, -.2*Y_CASE + R_CORNER - Y_BOARD_MARGIN_TOP, Z_BOARD])
    rotate([-180, 0, 0])
        PCB();

*translate([X_POS_PUSH_BUTTON_1, Y_POS_PUSH_BUTTON_1, -10 - WALL_THICKNESS - R_CORNER])
    push_button();
*translate([X_POS_PUSH_BUTTON_2, Y_POS_PUSH_BUTTON_2, -10 - WALL_THICKNESS - R_CORNER])
    push_button();
*translate([X_POS_LED, Y_POS_LED, -4 - WALL_THICKNESS - R_CORNER])
    LED();

translate([2*X_CASE, 0, 0]) washer();
translate([2*X_CASE, 10, 0]) top_strain_relief();