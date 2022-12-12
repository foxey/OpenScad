// OpenTherm Gateway Case
// (c) 2022 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

// Number of facets in a circle
// $fn = 16;
$fn = 64;

// Tolerance to prevent non manifold objects (0 height)
TOL = .1;

// Board dimensions
X_board = 34.5;
Y_board = 81.5;
Z_board = 24;
Z_pcb = 1.5;

// Connector dimensions
Y_screw_connector = 8;
Z_screw_connector = 5;
R_screw_connector = 1.5;
Y_usb_connector = 10;
Z_usb_connector = 7;
R_usb_connector = 3.5;

// Connector skirt
Y_usb_connector_skirt = 12;
Z_usb_connector_skirt = 9;
R_usb_connector_skirt = 4.5;


// Connection positions
Y_screw_connector_from_edge = 9;
Y_screw_connector_from_center = 0;
Y_usb_connector_from_edge = 8;

// PCB hole dimensions
R_hole = 1.5;
X_hole_distance = X_board - 2*R_hole - 2*1.5;
Y_hole_distance = Y_board - 2*R_hole - 2*1.5;

// Clearance for the through hole pins under the PCB
Z_clearance = 1.5;

// Wall thickness
D = 2;
D_bottom = 1.2;
D_top = D_bottom;

// Dimensions of the case
X = X_board + 2*D + .5; // board + 2* wall thickness + clearing
Y = Y_board + 2*D + .5; // board + 2* wall thickness + clearing
Z = Z_board + 2*D_bottom + 1.5; // board + 2* wall thickness + clearing
Z_bottom = 14 + D_bottom + Z_usb_connector/2 + 1.5; // top-top + wall thickness + connector middle line + pin clearing
Z_top = Z - Z_bottom;

// Outer corner radius
R = 3;
// Size of bezel (as fraction of R) 
R_fraction = .4;

// Top ridge dimensions
top_Z_ridge = 3.1;
top_ridge_fraction_1 = .425;
top_ridge_fraction_2 = .6;
top_z_fraction = .6;

// Bottom ridge dimensions
bottom_Z_ridge = 3;
bottom_ridge_fraction_1 = .45;
bottom_ridge_fraction_2 = .6;
bottom_z_fraction = .6;

module roundcube(size, r, slant_fraction=0) {
    assert(slant_fraction>=0 && slant_fraction<=1, "slant_fraction should in [0,1]")
    assert(size[0] >= 2*r, "x dimension should be bigger than 2*r  "); 
    assert(size[1] >= 2*r, "y dimension should be bigger than 2*r"); 
    translate([-size[0]/2, -size[1]/2, 0]) {
        hull() {
            for (x=[0, size[0] - 2*r]) {
                for (y=[0, size[1] - 2*r]) {
                    translate([x + r, y + r, 0]) {
                        translate([0, 0, slant_fraction*r]) cylinder(r=r, h=size[2] - slant_fraction*r, center=false);
                        cylinder(r1=(1-slant_fraction)*r, r2=r, h=slant_fraction*r, center=false);
                    }
                }  
            }
        }
    }
}

module hollow_roundcube(size, r, d, d_bottom, slant_fraction=0) {
    assert(r > d, "radius (r) should be larger than the wall thickness (d)");
    difference() {
        roundcube(size, r, slant_fraction);
        translate([0, 0, d_bottom]) roundcube(size - [2*d, 2*d, -2*TOL], r - d);
    }
}

module hollow_roundcube_with_bottom(size, r, d, d_bottom) {
    hollow_roundcube(size, r, d, d_bottom, R_fraction);
}

module ridge_corners(size, r, d, d_bottom) {
    difference() {
        hollow_roundcube_with_bottom(size, r, d, d_bottom);
        x_1 = size[0] - 2*r;
        y_1 = size[1];
        x_shift_1 = -x_1/2;
        y_shift_1 = -size[1]/2;
        translate([x_shift_1, y_shift_1, 0]) cube([x_1, y_1, size[2]]);
        x_2 = size[0];
        y_2 = size[1] - 2*r;
        x_shift_2 = -size[0]/2;
        y_shift_2 = -y_2/2;
        translate([x_shift_2, y_shift_2, 0]) cube([x_2, y_2, size[2]]);
    }
}

module top_ridge(size, r, d) {
    size_1 = size - [2*(1 - top_ridge_fraction_1)*d,
                     2*(1 - top_ridge_fraction_1)*d,
                      size[2] - top_Z_ridge - TOL];
    size_2 = size - [2*(1 - top_ridge_fraction_2)*d,
                     2*(1 - top_ridge_fraction_2)*d,
                      size[2] - top_z_fraction*top_Z_ridge];
    corner_size = size - [2*(1 - top_ridge_fraction_2)*d,
                     2*(1 - top_ridge_fraction_2)*d,
                     size[2] - top_Z_ridge - TOL];
    roundcube(size_1, r - (size[0]-size_1[0])/2);
    roundcube(size_2, r - (size[0]-size_2[0])/2);
    ridge_corners(corner_size, r - (size[0]-size_2[0])/2, d, -TOL);
}

module ridge_corners(size, r, d, d_bottom) {
    difference() {
        hollow_roundcube_with_bottom(size, r, d, d_bottom);
        x_1 = size[0] - 2*r;
        y_1 = size[1];
        x_shift_1 = -x_1/2;
        y_shift_1 = -size[1]/2;
        translate([x_shift_1, y_shift_1, 0]) cube([x_1, y_1, size[2]]);
        x_2 = size[0];
        y_2 = size[1] - 2*r;
        x_shift_2 = -size[0]/2;
        y_shift_2 = -y_2/2;
        translate([x_shift_2, y_shift_2, 0]) cube([x_2, y_2, size[2]]);
    }
}

module bottom_ridge(size, r, d) {
    size_1 = size + [TOL, TOL, bottom_Z_ridge - size[2] + TOL];
    size_2 = size + [TOL, TOL, top_z_fraction*bottom_Z_ridge - size[2]];
    hollow_roundcube(size_1, r, bottom_ridge_fraction_1*d + TOL, -TOL);
    ridge_corners(size_1, r, bottom_ridge_fraction_2*d + TOL, -TOL);
    hollow_roundcube(size_2, r, bottom_ridge_fraction_2*d + TOL, 0);
}

module case_bottom(size, r, d, d_bottom) {
    difference(){
        size = size + [0, 0, bottom_Z_ridge];
        hollow_roundcube_with_bottom(size, r, d, d_bottom);
        translate([0, 0, size[2] - bottom_Z_ridge])
           bottom_ridge(size, r, d);
    }
}

module case_top(size, r, d, d_bottom) {
    difference(){
        hollow_roundcube_with_bottom(size, r, d, d_bottom);
        translate([0, 0, size[2] - top_Z_ridge])
           top_ridge(size, r, d);
    }
}

module pcb_stand() {
    translate([0, 0, Z_clearance]) cylinder(r=R_hole-TOL, h=Z_pcb);
    cylinder(r=R_hole*1.5, h=Z_clearance);
}

module pcb_stand_set() {
    translate([-X_hole_distance/2, -Y_hole_distance/2, 0])
        for (x=[0, X_hole_distance]) {
            for (y = [0, Y_hole_distance]) {
                translate([x, y, 0])
                    pcb_stand();
            }
        }    
}

module connector(connector_size, r_connector) {
    rotate([90, 0, 90])
        translate([r_connector - connector_size[1]/2, r_connector - connector_size[2]/2, -connector_size[0]/2])
            hull() {
                for (y=[0, connector_size[1] - 2*r_connector]) {
                    for (z = [0, connector_size[2] - 2*r_connector]) {
                        translate([y, z, 0])
                            cylinder(r=r_connector, h=connector_size[0]);
                    }
                }    
            }
}

module connector_ridge(connector_size, z_ridge) {
    size = [ connector_size[0], connector_size[1], z_ridge+TOL ];
    translate([-connector_size[0]/2, -connector_size[1]/2, 0])
        cube(size);
}

module connector_cut(connector_size, r_connector, z_ridge) {
    union() {
        connector(connector_size, r_connector);
        connector_ridge(connector_size, z_ridge);
    }
}

module connector_cuts(connector_x_shift, connector_z_shift, connector_z_ridge) {
    translate([connector_x_shift, (Y_board-Y_screw_connector)/2 - Y_screw_connector_from_edge, connector_z_shift])
    connector_cut([D+2*TOL, Y_screw_connector, Z_screw_connector], R_screw_connector, connector_z_ridge);
translate([connector_x_shift, Y_screw_connector_from_center, connector_z_shift])
    connector_cut([D+2*TOL, Y_screw_connector, Z_screw_connector], R_screw_connector, connector_z_ridge);
translate([connector_x_shift, -(Y_board-Y_usb_connector)/2 + Y_usb_connector_from_edge, connector_z_shift])
    connector_cut([D+2*TOL, Y_usb_connector, Z_usb_connector], R_usb_connector, connector_z_ridge);
}

module connector_skirt(connector_x_shift, connector_z_shift) {
    translate([connector_x_shift, -(Y_board-Y_usb_connector)/2 + Y_usb_connector_from_edge, connector_z_shift])
    connector([D+2*TOL, Y_usb_connector_skirt, Z_usb_connector_skirt], R_usb_connector_skirt);
}

module pcb_corner_cuts(size, r, d) {
    translate([-size[0]/2 + D, size[1]/2 - D - r, d])
        cube([r, r, size[2]]);
    translate([-size[0]/2 + D, -size[1]/2 + D, d])
        cube([r, r, size[2]]);
    translate([size[0]/2 - D -r, size[1]/2 - D - r, d])
        cube([r, r, size[2]]);
    translate([size[0]/2 - D - r, -size[1]/2 + D, d])
        cube([r, r, size[2]]);
}

module led_viewports() {
    r = 1.5;
    h = D;
    x = -X/2 + D + 4;
    y = -Y/2 + D;
    z = 0.2;
    translate([x, y + 32, z]) cylinder(r=r, h=h);
    translate([x, y + 59.5, z]) cylinder(r=r, h=h);
    translate([X/2 - D - 2, y + 8.5, z]) cylinder(r=r, h=h);
}

module complete_bottom() {
    difference(){
        union() {
            difference() {
                case_bottom([X, Y, Z_bottom], R, D, D_bottom);
                pcb_corner_cuts([X, Y, Z_bottom - D_bottom], R, D_bottom);
            }
            translate([0, 0, D_bottom])
                pcb_stand_set();
        }
        connector_cuts(-(X - D)/2, Z_bottom, bottom_Z_ridge);
        connector_skirt(-X/2+TOL, Z_bottom);
    }
}

module complete_top() {
    difference(){
        case_top([X, Y, Z_top], R, D, D_top);
        connector_cuts((X-D)/2, Z_top, top_Z_ridge);
        connector_skirt(X/2-TOL, Z_top);
        led_viewports();
    }
}

// ---------------------------------- MAIN ---------------------------------- //
orientation = 0;
cut = 0;

difference(){
    complete_bottom();
    if (cut == 1)
        translate([-50, 0*(Y-D)/2, -.1]) cube(size=[100, 100, 100], center=false);
}

translate([-(1 - orientation)*(X + 20), 0, orientation*(Z+TOL)]) {
    rotate([0, orientation*180, 0])
        difference(){
            complete_top();
    if (cut == 1)
        translate([-50, 0*(Y-D)/2, -50]) cube(size=[100, 100, 100], center=false);
    }
}