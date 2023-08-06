// Terminal Block Case
// (c) 2023 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

// Number of facets in a circle
// $fn = 16;
$fn = 64;

// Tolerance to prevent non manifold objects (0 height)
TOL = .1;
CLEARING = .5;

// Board dimensions
X_board = 14;
Y_board = 18 + 38;
Z_board = 15;
Z_bottom_base = 2/3 * Z_board;

// Connector dimensions
D_screw_connector = 5.5;


// Wall thickness
D = 2;
D_bottom = 2;
D_top = D_bottom;

// Strain relief dimensions
D_STRAIN_RELIEF_CABLE = D_screw_connector;
X_MAINS_STRAIN_RELIEF = 14 + CLEARING;
Y_MAINS_STRAIN_RELIEF = 8;
Z_MAINS_STRAIN_RELIEF = D + D_STRAIN_RELIEF_CABLE/2;
Z_TOP_STRAIN_RELIEF = 5;
D_STRAIN_RELIEF_SCREW = 1.5;
D_TOP_STRAIN_RELIEF_SCREW = 2.5;
D_STRAIN_RELIEF_SCREW_CAP = 5;

// Dimensions of the case
X = X_board + 2*D + CLEARING; // board + 2* wall thickness + clearing
Y = Y_board + 2*D + CLEARING; // board + 2* wall thickness + clearing
Z = Z_board + 2*D_bottom + 3*CLEARING; // board + 2* wall thickness + clearing
Z_bottom = Z_bottom_base + D_bottom; // base + wall thickness
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


module connector_cut(z_connector, d_connector) {
    rotate([90, 0, 0])
        translate([0, 0, -z_connector/2])
            cylinder(d=d_connector, h=z_connector);
}


module mains_strain_relief() {
    difference() {
        cube([X_MAINS_STRAIN_RELIEF, Y_MAINS_STRAIN_RELIEF, Z_MAINS_STRAIN_RELIEF]);
        translate([.5*X_MAINS_STRAIN_RELIEF, Y_MAINS_STRAIN_RELIEF + TOL, Z_MAINS_STRAIN_RELIEF]) 
            rotate([90, 0, 0])
                cylinder(d=D_STRAIN_RELIEF_CABLE, h=Y_MAINS_STRAIN_RELIEF + 2*TOL);
        translate([.18*X_MAINS_STRAIN_RELIEF, Y_MAINS_STRAIN_RELIEF/2, -TOL])
            cylinder(d=D_STRAIN_RELIEF_SCREW, h=Z_MAINS_STRAIN_RELIEF + 2*TOL);
        translate([.82*X_MAINS_STRAIN_RELIEF, Y_MAINS_STRAIN_RELIEF/2, -TOL])
            cylinder(d=D_STRAIN_RELIEF_SCREW, h=Z_MAINS_STRAIN_RELIEF + 2*TOL);
    }
}

module top_strain_relief() {
    difference() {
        y_top = .8*Y_MAINS_STRAIN_RELIEF;
        x_top = X_MAINS_STRAIN_RELIEF - CLEARING;
        union(){
            translate([-.5*x_top/2, -.5*y_top/2, 0])
               cube([1.5*x_top, 1.5*y_top, .2]);
            cube([x_top, y_top, Z_TOP_STRAIN_RELIEF]);
        }
        translate([.5*x_top, Y_MAINS_STRAIN_RELIEF + TOL, 1.3*Z_MAINS_STRAIN_RELIEF]) 
            rotate([90, 0, 0])
                cylinder(d=D_STRAIN_RELIEF_CABLE, h=Y_MAINS_STRAIN_RELIEF + 2*TOL);
        translate([.18*x_top, y_top/2, TOL]) {
            cylinder(d=D_TOP_STRAIN_RELIEF_SCREW, h=2*Z_MAINS_STRAIN_RELIEF);
            translate([0, 0, -2*TOL])
                cylinder(d=D_STRAIN_RELIEF_SCREW_CAP, h=2 + TOL);
        }
        translate([.82*x_top, y_top/2, TOL]) {
            cylinder(d=D_TOP_STRAIN_RELIEF_SCREW, h=2*Z_MAINS_STRAIN_RELIEF);
            translate([0, 0, -2*TOL])
                cylinder(d=D_STRAIN_RELIEF_SCREW_CAP, h=2 + TOL);
        }
    }
}


module complete_bottom() {
    difference(){
        union(){
            case_bottom([X, Y, Z_bottom], R, D, D_bottom);
            translate([-X_MAINS_STRAIN_RELIEF/2, Y/2 - D - Y_MAINS_STRAIN_RELIEF, 0])
                mains_strain_relief();
            translate([-X_MAINS_STRAIN_RELIEF/2, -Y/2 + D, 0])
                mains_strain_relief();
        }
        translate([0, -Y/2 + D/2, D_screw_connector/2 + D_bottom])
            connector_cut(D+2*TOL, D_screw_connector);
        translate([0, Y/2 - D/2, D_screw_connector/2 + D_bottom])
            connector_cut(D+2*TOL, D_screw_connector);
    }
}

module complete_top() {
    case_top([X, Y, Z_top], R, D, D_top);
}

// ---------------------------------- MAIN ---------------------------------- //
orientation = 0;
cut = 0;

difference(){
    complete_bottom();
    if (cut == 1)
        translate([-50, 0*(Y-D)/2, -.1]) cube(size=[100, 100, 100], center=false);
}

translate([-(1 - orientation)*(X + 10), 0, orientation*(Z+TOL)]) {
    rotate([0, orientation*180, 0])
        difference(){
            complete_top();
    if (cut == 1)
        translate([-50, 0*(Y-D)/2, -50]) cube(size=[100, 100, 100], center=false);
    }
}

translate([X/2 + 10, 0, 0]) {
    top_strain_relief();
    translate([0, Y_MAINS_STRAIN_RELIEF, 0])
        top_strain_relief();
}
