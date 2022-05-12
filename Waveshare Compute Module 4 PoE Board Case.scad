// Waveshare Compute Module 4 PoE Board Case
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

Z_LAYER = .15;

X_BOARD = 124.5; // Length of the board
Y_BOARD = 108.8; // Width of the board
Z_BOARD = 1.5; // Height of the board (PCB only)
Z_CASE = 47-3; // Height of the case (minus the top and bottom parts)
T_CASE = 2; // Wall thickness of the case
X_HOLE = 118.5; // Length between mount holes
Y_HOLE = 102.8; // Width between mount holes 

TOLERANCE = .25;
R_CORNER = (X_BOARD-X_HOLE)/2 + TOLERANCE; // Radius of the corners of the board
H_CORNER = 20; // Height of the screw pillars

M3NUT_Z = 3; // exact: 2.3
M3BOLT_Z = 11.5; // exact: 11
M3BOLTHEAD_Z = 3.5; // exact 3
M3BOLT_D = 3;
M3BOLTHEAD_D= 5.5;

// Dimensions of the ventilation grate in the side panels
vent_d = 3;
vent_rows = 3;
vent_cols = 10;
x_vent = (sqrt(2)+(vent_cols)*2)*vent_d;
z_vent = (sqrt(2)+vent_rows*2)*vent_d;

// Dimensions of the ventilation grate in the top
top_vent_d = 3;
top_vent_rows = 6;
top_vent_cols = 9;
x_top_vent = (sqrt(2)+top_vent_rows*2)*top_vent_d;
y_top_vent = (sqrt(2)+(top_vent_cols)*2)*top_vent_d;
echo(" TOP VENT x=", x_top_vent," y=", y_top_vent);

// Width of the recessed border around the USB and HDMI ports
port_border = 2;

// Module: m3nut - M3 nut
// Z = height of the nut
// rotate = orientation of the flat sides
module m3nut(Z, rotate=0) {
    $fn=6;
    rotate([0,0,rotate]) cylinder(d=6.2,h=Z);
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
        base_case(Z_CASE, T_CASE);
        translate([0, 0, -T_CASE]) base_case(Z_CASE);
        translate([0, 0, 3*T_CASE]) base_case(Z_CASE);
    }
}


// Module: base_case_top - Solid top with rounded edges and corners
// thickness = wall thickness
module base_case_top(thickness) {
    hull() {
        radius = R_CORNER + thickness;
        translate([0, 0, 0]) sphere(r=radius);
        translate([X_HOLE, 0, 0]) sphere(r=radius);
        translate([0, Y_HOLE, 0]) sphere(r=radius);
        translate([X_HOLE, Y_HOLE, 0]) sphere(r=radius);
    }
}


// Module: case_top - Hollow case top
module case_top(){
    difference(){
        base_case_top(T_CASE);
        translate([0, 0, 0]) base_case_top(0*T_CASE/2);
        translate([-X_BOARD/2, -Y_BOARD/2, 0]) cube([2*X_BOARD, 2*Y_BOARD, 2*(R_CORNER+T_CASE)]);
    }
}


// Module: nut_stand: cylinder with slit for M3 nut and pylon to prevent overhang
module nut_stand(){
    rotate([180, 0, 0])
        difference(){
            hull(){
                cylinder(r=R_CORNER+T_CASE, h=T_CASE+M3NUT_Z*2);
                translate([-R_CORNER-T_CASE/2, 0, H_CORNER-.1]) cylinder(r=T_CASE/2, h=.1);
            }
            translate([0, 0, T_CASE]) m3nut(M3NUT_Z);
            translate([0, 0, T_CASE+M3NUT_Z]) {
                hull(){
                    m3nut(M3NUT_Z);
                    translate([2*(R_CORNER+T_CASE), 0, 0]) m3nut(M3NUT_Z);
                }
            }
            translate([0, 0, -.1]) cylinder(d=M3BOLT_D, h=T_CASE+.2);
        }
}


// Module: nut_stands - 4 nut_stand's positioned in each corner of the case
module nut_stands(){
    z_offset = Z_CASE + 2*T_CASE - Z_BOARD;
    translate([0, 0, z_offset]) rotate([0, 0, 45]) nut_stand();
    translate([X_HOLE, 0, z_offset]) rotate([0, 0, 135]) nut_stand();
    translate([0, Y_HOLE, z_offset]) rotate([0, 0, -45]) nut_stand();
    translate([X_HOLE, Y_HOLE, z_offset]) rotate([0, 0, -135]) nut_stand();
}


// Module: quartre_sphere
// r = radius
module eights_sphere(r) {
    difference() {
        sphere(r=r);
        cylinder(r=r, h=r);
        translate([0, -r, -r]) cube([r, 2*r, r+TOLERANCE]);
        translate([-r, -r, -r]) cube([2*r, r, r+TOLERANCE]);
    }
}


// Module: eigth_cylinder
// r = radius
// h = height
module eights_cylinder(r, h) {
    difference() {
        cylinder(r=r, h=h);
        translate([0, -r, -TOLERANCE]) cube([r, 2*r, h+2*TOLERANCE]);
        translate([-r, -r, -TOLERANCE]) cube([2*r, r, h+2*TOLERANCE]);
    }
}


module spherical_cut(r) {
    difference() {
        translate([0, 0, -r]) eights_cylinder(r, r);
        eights_sphere(r);
    }
}


module cylindrical_cut(r, h) {
    difference() {
        translate([-r, -r, -r]) cube([r, h, r]);
        translate([0, r, 0]) rotate([90, 0, 0]) cylinder(r=r,h=h);
    }
}


module rotated_cylindrical_cut(r, h) {
    translate([0, -h, 0])
        rotate([0, -90, 90]) 
            cylindrical_cut(r, h);
}

// Module: bolt_stand: cylinder with hole for M3 bolt
module bolt_stand() {
    r = R_CORNER + T_CASE;
    difference(){
        translate([0, 0, -r]) cylinder(r=r, h=r+T_CASE);
        spherical_cut(r);
        cylindrical_cut(r, 2*r);
        translate([0, 2*r, 0]) rotated_cylindrical_cut(r, 2*r);
    }
}


// Module: bolt_stands - 4 bolt_stand-s positioned in each corner of the case
module bolt_stands(){
    z_offset = 0;
    translate([0, 0, z_offset]) rotate([0, 0, 90]) bolt_stand();
    translate([X_HOLE, 0, z_offset]) rotate([0, 0, 180]) bolt_stand();
    translate([0, Y_HOLE, z_offset]) rotate([0, 0, 0]) bolt_stand();
    translate([X_HOLE, Y_HOLE, z_offset]) rotate([0, 0, 270]) bolt_stand();
}


// Module: bolt_hole
module bolt_hole() {
    r = R_CORNER + T_CASE;
    union() {
        translate([0, 0, -r]) cylinder(d=M3BOLT_D, h=r+T_CASE);
        translate([0, 0, -r]) cylinder(d=M3BOLTHEAD_D, h=M3BOLTHEAD_Z);
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


// Module: ethernet - cutout for ethernet port
module ethernet(lid=false) {
    x = lid ? 1 : 21.2+2;
    x_offset = lid ? 1 : -2-1;
    y = lid ? 16-TOLERANCE : 16+TOLERANCE;
    y_offset = lid ? TOLERANCE : 0;
    z = lid ? Z_BOARD : 13.4 + 2*TOLERANCE + Z_BOARD;
    translate([x_offset, y_offset, -z]) cube([x, y, z]);
}


// Module: ethernet_mount - cutout in corner pillar for ethernet solder mount
module ethernet_mount() {
    x = 7.5 + 2;
    x_offset = T_CASE;
    y = 5;
    y_offset = 0;
    z = 2 + TOLERANCE;
    z_offset = 2 - 3*TOLERANCE - Z_BOARD;
    translate([x_offset, y_offset, z_offset]) cube([x, y, z]);
}


// Module: serial - cutout for serial ports
module serial(lid=false) {
    x = lid ? 1 : 9+2;
    x_offset = lid ? 1 : -2-1;
    y = lid ? 31 - TOLERANCE : 31+TOLERANCE;
    y_offset = lid ? TOLERANCE : 0;
    z = lid ? Z_BOARD : 7 + 2*TOLERANCE + Z_BOARD;
    translate([x_offset, y_offset, -z]) cube([x, y, z]);
}


// Module: ethernet - cutout for status leds
module leds() {
    d_led = 2.5;
    y = 3.5 + TOLERANCE;
    z = 10.5 + 2*TOLERANCE+Z_BOARD;
    translate([-TOLERANCE/2+1, 0, -z]) cube([10, y, z]);
    translate([T_CASE/2+Z_LAYER, y/2, -TOLERANCE-4]) rotate([0, 90, 0]) cylinder(d=d_led, h=T_CASE, center=true);
    translate([T_CASE/2+Z_LAYER, y/2, -TOLERANCE-9]) rotate([0, 90, 0]) cylinder(d=d_led, h=T_CASE, center=true);
}


// Module: usb_c - cutout for USB C port
module usb_c(lid=false) {
    x = lid ? 1: 7.5 + 2;
    x_offset = lid ? 1 : -2-1;
    y = lid ? 9 - TOLERANCE : 9 + TOLERANCE;
    y_offset = lid ? TOLERANCE : 0;
    z = lid ? Z_BOARD : 3.5 + 2*TOLERANCE+Z_BOARD;
    translate([x_offset, y_offset, -z]) cube([x, y, z]);
}


// Module: sd_card_slot - cutout for SD Card Reader
module sd_card_slot() {
    x = 7.5 + 2;
    x_offset = -2-1;
    y = 14 + TOLERANCE;
    y_offset = 0;
    z = 2 + TOLERANCE;
    z_offset = 2 - 3*TOLERANCE - Z_BOARD;
    translate([x_offset, y_offset, z_offset]) cube([x, y, z]);
}


// Module: usb_c_border - 1mm recessed / 2mm border around the USB-C port to fit bigger plugs
module usb_c_border(r) {
    x = 2;
    y = 9 + 2*r + TOLERANCE;
    z = 3.5 - 2*2 + 2*TOLERANCE+Z_BOARD;
    border(r, x, y, z);

}


// Module: power_resistor: cutout for power resistor next to usb_c port
module power_resistor() {
    x = 5;
    y = 4;
    z = 1.5+Z_BOARD;
    translate([4, 0, -z]) cube([x, y, z]);
}


// Module: hdmi - cutout for HDMI port
// 1: y_position = 8.5
// 2: y_position = 33.0
module hdmi(lid=false) {
    x = lid ? 1 : 11.5 + 2;
    x_offset = lid ? -1-x : 2+1-x;
    y = lid ? 15 - TOLERANCE : 15 + TOLERANCE;
    y_offset = lid ? -y-TOLERANCE : -y;
    z = lid ? Z_BOARD : 6.5 + 2*TOLERANCE+Z_BOARD;
    translate([x_offset, y_offset, -z]) cube([x, y, z]);
}


// Module: hdmi_border - mm recessed / 2mm border around the HDMI port to fit bigger plugs
module hdmi_border(r) {
    x = 2;
    y = 15 + 2*r + TOLERANCE;
    z = 6.5 - 2*r + 2*TOLERANCE+Z_BOARD;
    border(r, x, y, z, right=true);
}


// Module: usb - cutout for USB port
// 1: y_position = 61.6
// 2: y_position = 88.0
module usb(lid=false) {
    x = lid ? 1 : 17 + 2;
    x_offset = lid ? -1-x : 2+1-x;
    y = lid ? 13.3 - TOLERANCE : 13.3 + TOLERANCE;
    y_offset = lid ? -y-TOLERANCE : -y;
    z = lid ? Z_BOARD : 15.7 + 2*TOLERANCE + Z_BOARD;
    translate([x_offset, y_offset, -z]) cube([x, y, z]);
}


// Module: usb_border - 1mm recessed / 2 mm border around the usb port to fit the metal grips
module usb_border(r) {
    x = 2;
    y = 13.3 + 2*r + TOLERANCE;
    z = 15.7 - 2*r + 2*TOLERANCE + Z_BOARD;
    border(r, x, y, z, right=true);
}


// Module: ssd_led - See-through window for SSD activity LED
module ssd_led(d) {
    cylinder(d=d, h=T_CASE);
}

// Module: ventilation_slit - single ventilation slit
module ventilation_slit(d) {
    rotate([0, 0, 45]) cube([d, d, 2*T_CASE]);
}


// Module: ventilation_grate - array of slits for case side
module ventilation_grate(d, rows, cols) {
    translate([0, 0, (.5*sqrt(2)+2*rows)*d])
        rotate([0, 90, 0])
            for (row = [0:rows]) {
                for (col = [0:cols-1]) {
                    translate([2*row*d, 2*d*col, 0])
                        ventilation_slit(d);
                    if (row<rows)
                        translate([(1+2*row)*d, (1+2*col)*d, 0])
                            ventilation_slit(d);
                }
                translate([2*row*d, 2*d*cols, 0])
                    ventilation_slit(d);
            }
}


// Module: full_case - full top case including port cutouts
module full_case() {
    z_offset = Z_CASE + 2*T_CASE + TOLERANCE;
    difference() {
        union() {
            case();
            case_top();
            nut_stands();
        }
// Left ports
    translate([-R_CORNER-T_CASE, -R_CORNER+7, z_offset]) ethernet();
    translate([-R_CORNER-T_CASE, -R_CORNER+35.6, z_offset]) serial();
    translate([-R_CORNER-T_CASE, -R_CORNER+85.5, z_offset]) leds();
    translate([-R_CORNER-T_CASE, -R_CORNER+91.75, z_offset]) usb_c();
    translate([-R_CORNER-T_CASE, -R_CORNER+91.75, z_offset]) usb_c_border(port_border);
    translate([-R_CORNER-T_CASE, -R_CORNER+100, z_offset]) power_resistor();

// Right ports
    translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-8.5, z_offset]) hdmi();
    translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-8.5, z_offset]) hdmi_border(port_border);
    translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-33, z_offset]) hdmi();
    translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-33, z_offset]) hdmi_border(port_border);
    translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-61.6, z_offset]) usb();
    translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-61.6, z_offset]) usb_border(port_border);
    translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-88, z_offset]) usb();
    translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-88, z_offset]) usb_border(port_border);

// SSD activity LED window
    translate([-R_CORNER+20, -R_CORNER+30, -R_CORNER-T_CASE+Z_LAYER ])
        ssd_led(5);

// Ventilation grates (side panels)
    translate([(X_HOLE+TOLERANCE-x_vent)/2, -T_CASE, (Z_CASE-z_vent)/2])
        rotate([0, 0, -90])
            ventilation_grate(vent_d, vent_rows, vent_cols);
    translate([(X_HOLE+TOLERANCE-x_vent)/2, Y_BOARD+TOLERANCE, (Z_CASE-z_vent)/2])
        rotate([0, 0, -90])
            ventilation_grate(vent_d, vent_rows, vent_cols);

// Ventilation grate (top)
    translate([50+TOLERANCE+x_top_vent, Y_HOLE+TOLERANCE-y_top_vent-3.5, -R_CORNER-T_CASE])
    rotate([0, -90, 0])
        ventilation_grate(top_vent_d, top_vent_rows, top_vent_cols);
    }
}


// Module: wall_mount_hole - screw hole for wall mount
module wall_mount_hole() {
    translate([0, 0, R_CORNER+T_CASE/2]) {
        cylinder(d=7, h=2*T_CASE);
        hull() {
            translate([0, 0, T_CASE/4]) cylinder(d=7, h=T_CASE);
            translate([0, 3.5, -T_CASE/2]) cylinder(d=7, h=T_CASE);
        }
        hull() {
            cylinder(d=7, h=T_CASE);
            translate([0, 3.5+5, 0]) cylinder(d=7, h=T_CASE);
        }
        hull() {
            cylinder(d=3, h=2*T_CASE);
            translate([0, 3.5+5, 0]) cylinder(d=3, h=2*T_CASE);
        }
    }
}

// Module: wall_mount_hole_cover - internal cover for screw hole to protect backside of the PCB
module wall_mount_hole_cover() {
    translate([0, 0, R_CORNER-T_CASE+1]) {
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
            translate([0, Y_HOLE, T_CASE])
                rotate([180, 0, 0])
                    difference() {
                        union() {
                            difference() {
                                base_case(-T_CASE, T_CASE);
                                translate([0, 0, -T_CASE]) base_case(Z_CASE);
                            }
                            case_top();
                            bolt_stands();
                        }
                        bolt_holes();
                    }
            translate([-R_CORNER-T_CASE, 3.5, z_offset]) ethernet_mount();
            translate([-R_CORNER-T_CASE, -R_CORNER+69, z_offset]) sd_card_slot();
            translate([-R_CORNER-T_CASE, -R_CORNER+91.75, z_offset]) usb_c_border(port_border);
            translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-8.5, z_offset]) hdmi_border(port_border);
            translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-33, z_offset]) hdmi_border(port_border);
            translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-61.6, z_offset]) usb_border(port_border);
            translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-88, z_offset]) usb_border(port_border);
            translate([X_BOARD/3, 2*Y_BOARD/3, z_offset]) wall_mount_hole();
            translate([2*X_BOARD/3, 2*Y_BOARD/3, z_offset]) wall_mount_hole();
        }

        // Cover to protect backside PCB
        translate([X_BOARD/3, 2*Y_BOARD/3, z_offset]) wall_mount_hole_cover();
        translate([2*X_BOARD/3, 2*Y_BOARD/3, z_offset]) wall_mount_hole_cover();

        // Lid extentions to cover port cutouts in front of the PCB
        // Left ports
        translate([-R_CORNER-T_CASE, -R_CORNER+7, z_offset]) ethernet(lid=true);
        translate([-R_CORNER-T_CASE, -R_CORNER+35.6, z_offset]) serial(lid=true);
        translate([-R_CORNER-T_CASE, -R_CORNER+91.75, z_offset]) usb_c(lid=true);

        // Right ports
        translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-8.5, z_offset]) hdmi(lid=true);
        translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-33, z_offset]) hdmi(lid=true);
        translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-61.6, z_offset]) usb(lid=true);
        translate([-R_CORNER+2*TOLERANCE+X_BOARD+T_CASE, -R_CORNER+TOLERANCE+Y_BOARD-88, z_offset]) usb(lid=true);
    }
}

difference() {
    full_case();
//    translate([-10, -10, -10]) cube([20+X_BOARD, 20+ Y_BOARD, 35]);
}

// translate([0, 0, 1*(Z_CASE + 2*T_CASE)])
//     full_lid();

translate([1.5*X_BOARD, Y_HOLE, T_CASE])
    rotate([-180, 0, 0])
        full_lid();