// $fn=50;
PROTRUSION=0.1; // additional size for clean substractions
TOL = 1; // tolerance between tablet and grip
TABLET_X = 258.70;
TABLET_Y = 171.80;
TABLET_Z = 7.30;

M3NUT_Z = 2;
M3BOLT_Z = 11;
M3BOLTHEAD_Z = 2.5;
M3BOLT_D = 3;
M3BOLTHEAD_D= 5.5;

BACKPLATE_Y=40;
BACKPLATE_X=80;
BACKPLATE_Z=2.5;
BACKPLATE_R=5;
BACKPLATE_SCREW_D=3;
MOUNT_SCREW_D=6;

// Module: tablet - HUAWEI TABLET mock
module tablet() {
    z=(TABLET_Z+TOL)/2;
    hull(){
        for (x = [0, TABLET_X-2*z])
            for (y = [0, TABLET_Y-2*z]) {
                translate([x+z, y+z, z]) sphere(d=TABLET_Z+TOL);
        }
    }
}

// Module: m3nut - M3 nut
// Z = Z of the nut
// rotate = orientation of the flat sides
module m3nut(Z, rotate=0) {
    $fn=6;
    rotate([0,0,rotate]) cylinder(d=6.2,h=Z);
}

// Module: backplate_screwhole
// Z = height
module backplate_screwhole(Z) {
    translate([0,0,PROTRUSION])
        cylinder(d=BACKPLATE_SCREW_D,h=Z+2*PROTRUSION);
}

// Module: backplate_base_orig - original base where grip is attached
module backplate_base_orig(Z) {
minkowski()
    {
      cube([BACKPLATE_X-2*BACKPLATE_R,BACKPLATE_Y-2*BACKPLATE_R,Z/2]);
      cylinder(r=5,h=Z/2);
    }
}

// Module: backplate_bottom - recess to attach to clamp
module backplate_bottom(Z) {
union() {
    rounded_cube(BACKPLATE_X + TOL, BACKPLATE_Y + TOL, Z, 2*BACKPLATE_R);
        translate([TOL/2, TOL/2]) {
        tolerance=-1;
        translate([tolerance/2 + BACKPLATE_R,tolerance + BACKPLATE_R,0])
            backplate_screwhole(10*Z);
        translate([tolerance/2 + BACKPLATE_R,BACKPLATE_Y-BACKPLATE_R-tolerance,0])
            backplate_screwhole(10*Z);
        translate([BACKPLATE_X-BACKPLATE_R-tolerance/2,tolerance + BACKPLATE_R,0])
            backplate_screwhole(10*Z);
        translate([BACKPLATE_X-BACKPLATE_R-tolerance/2,BACKPLATE_Y-BACKPLATE_R-tolerance,0])
            backplate_screwhole(10*Z);
        }
    }
}

// Module: backplate_bottom_orig - original backplate to screw the grip on
module backplate_bottom_orig(Z) {
    difference() {
        backplate_base_orig(Z);
        tolerance=-1;
        translate([tolerance/2,tolerance,0])
            backplate_screwhole(Z);
        translate([tolerance/2,BACKPLATE_Y-2*BACKPLATE_R-tolerance,0])
            backplate_screwhole(Z);
        translate([BACKPLATE_X-2*BACKPLATE_R-tolerance/2,tolerance,0])
            backplate_screwhole(Z);
        translate([BACKPLATE_X-2*BACKPLATE_R-tolerance/2,BACKPLATE_Y-2*BACKPLATE_R-tolerance,0])
            backplate_screwhole(Z);
        translate([BACKPLATE_X/2-BACKPLATE_R,BACKPLATE_Y-2*BACKPLATE_R-tolerance*1.5,0])
            backplate_screwhole(Z);
        translate([BACKPLATE_X/2-BACKPLATE_R,tolerance*1.5,0])
            backplate_screwhole(Z);
    }
}

// Module: rounded_cube - cube with round bottom, top and sharp edges
// X = length
// Y = width
// Z = height
// D = diameter of rounded edge
module rounded_cube(X, Y, Z, D) {
    hull(){
        shift=[D/2, D/2, 0];
        for (x = [0, X-D])
                for (y = [0, Y-D]) {
                    for (z= [Z/4, 3*Z/4])
                        translate([x, y, z] + shift) cylinder(d=D, h=Z/2, center=true);
            }
    }
}

// Module: rounded_cube_centered - rounded_cube centered around mid point of backplate_base
// X = length
// Y = width
// Z = height
// D = diameter of rounded edge
module rounded_cube_centered(X, Y, Z, D) {
    translate([(BACKPLATE_X - X)/2, (BACKPLATE_Y - Y)/2, 0])
        rounded_cube(X, Y, Z, D);
}


// Module: rounded_cube_round_bottom - cube with round bottom and edges, but flat top
// X = length
// Y = width
// Z = height
// D = diameter of rounded edge
module rounded_cube_round_bottom(X, Y, Z, D,) {
    hull(){
        shift=[D/2, D/2, 0];
        for (x = [0, X-D])
                for (y = [0, Y-D]) {
                    translate([x, y, D/2] + shift) sphere(d=D);
                    translate([x, y, 3*Z/4] + shift) cylinder(d=D, h=Z/2, center=true);
            }
    }
}

// Module: fixed_arm - 2 lower arms to be screwed to the base plate
// X = length
// Y = width
// Z = Z
// Z2 = Z of cutout for tablet
// D = diameter of rounded edge
module fixed_arm(X, Y, Z, Z2, D){
    translate([X-D/2, Y, 0])
        rotate([0, 0, 180])
            difference(){
                union(){
                    translate([-D/2, 0, 0]) rounded_cube_round_bottom(X, Y, Z, D);
                    translate([0, D-sqrt(2*(D/2)^2), D/2]) rotate([0, 0, 45])
                        minkowski(){
                            rounded_cube(D+sqrt((Y-2*D)^2/2), D+sqrt((Y-2*D)^2/2), Z2+Z, D);
                            sphere(d=D);
                        }
                }
                y=sqrt(Y^2/2);
                translate([D, 0, Z]) rotate([0, 0, 45])
                    cube([y, y, Z2]);
                translate([2*D, 0, Z]) rotate([0, 0, 45])
                    rounded_cube(y, y, Y, D);
                translate([Y/2, (Y-M3BOLTHEAD_D)/2, 0])
                    bolt_slit(X-Y,Y,Z);
                R=3;
                translate([0, 0, D/2])
                    ridge(X, R);
                translate([0, Y, D/2])
                     rotate([90, 0, 0])
                         ridge(X, R);
            }
}

// ridge (to fix sliding arm in base plate)
// X = length
// Y = width of the ridge (from 0)
module ridge(X,Y) {
    translate([X, Y, Y])
        rotate([0, 90, 180])
                scale([Y, Y, 1])
                    linear_extrude(X)
                        polygon([[1,1],[0,1],[1,0]]);
}

module bolt_slit(X,Y,Z) {
    translate([0, 0, Z-M3BOLTHEAD_Z]) {
        hull(){
            translate([M3BOLTHEAD_D/2, M3BOLTHEAD_D/2, 0])
                cylinder(d=M3BOLTHEAD_D, h=M3BOLTHEAD_Z+PROTRUSION);
            translate([X-M3BOLTHEAD_D/2, M3BOLTHEAD_D/2, 0])
                cylinder(d=M3BOLTHEAD_D, h=M3BOLTHEAD_Z+PROTRUSION);
        }
    }
    translate([0, 0, Z-M3BOLT_Z]) {
        hull(){
            translate([M3BOLTHEAD_D/2, M3BOLTHEAD_D/2, -PROTRUSION])
                cylinder(d=M3BOLT_D, h=M3BOLT_Z+2*PROTRUSION);
            translate([X-M3BOLTHEAD_D/2, M3BOLTHEAD_D/2, -PROTRUSION])
                cylinder(d=M3BOLT_D, h=M3BOLT_Z+2*PROTRUSION);
        }
    }
}

module arm_grip(X, Y, Z, D, W) {
    ARM_GRIP_WALL = 2;
    ARM_GRIP_X2 = Y/2;
    ARM_GRIP_X = X - ARM_GRIP_X2;
    ARM_GRIP_Y = 2*Y;
    ARM_GRIP_Z = Z + W + M3BOLTHEAD_Z;
    ARM_GRIP_SCREW_X = ARM_GRIP_X2;
    translate([ARM_GRIP_X2, -Y/2, 0])
        union(){
            difference(){
                translate([-ARM_GRIP_X2, -Y/2, 0]) rounded_cube_round_bottom(ARM_GRIP_X, ARM_GRIP_Y, ARM_GRIP_Z, D);
                translate([0, -TOL/2, ARM_GRIP_Z-Z]) rounded_cube_round_bottom(X, Y+TOL, Z + PROTRUSION, D);
                screw_hole_x = ARM_GRIP_X - ARM_GRIP_SCREW_X - ARM_GRIP_X2 + M3BOLT_D/2;
                screw_hole_y = -Y/2+ARM_GRIP_Y/2;
                translate([screw_hole_x, screw_hole_y, -PROTRUSION]) m3nut(M3NUT_Z + PROTRUSION, 90);
                translate([screw_hole_x, screw_hole_y, -PROTRUSION]) backplate_screwhole(ARM_GRIP_Z);
            }
            R=3;
            translate([0, -TOL/2, ARM_GRIP_Z - Z + D/2 + TOL/4]) {
                ridge(ARM_GRIP_X - ARM_GRIP_X2, R);
                translate([0, Y + TOL, 0])
                    rotate([90, 0, 0])
                        ridge(ARM_GRIP_X - ARM_GRIP_X2, R);
            }
        }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

BASE_GRIP_Z=9;

ARM_X=80;  // 80
ARM_Y=20;  // 20
ARM_Z=5;  // 5
ARM_Z2=8;  // 8
ARM_D=3;  // 3

WALL_THICKNESS = 2;

// #translate([-(TABLET_X-BACKPLATE_X)/2, -(TABLET_Y-BACKPLATE_Y)/2, BASE_GRIP_Z]) tablet();

difference(){
    rounded_cube_centered(BACKPLATE_X + 10, BACKPLATE_Y + 10, BASE_GRIP_Z, BACKPLATE_R);
    translate([0,0,-PROTRUSION]) rounded_cube_centered(BACKPLATE_X - 14, BACKPLATE_Y - 14, BASE_GRIP_Z + 2*PROTRUSION, BACKPLATE_R);
    translate([0,0,-PROTRUSION]) backplate_bottom(2 + 2*PROTRUSION);
}

diff = 2*sqrt(40^2/2);
diff2 = 2*sqrt(40^2/2) + 24;
arm1_shift_x = BACKPLATE_X/2 + (TABLET_X+TOL-diff)/2 - .9*diff;
arm1_shift_y = BACKPLATE_Y/2 - (TABLET_Y+TOL-diff)/2 + .9*diff;
arm2_shift_x = BACKPLATE_X/2 - (TABLET_X+TOL-diff)/2 + .9*diff;
arm2_shift_y = BACKPLATE_Y/2 - (TABLET_Y+TOL-diff)/2 + .9*diff;

difference(){
    rounded_cube_centered(TABLET_X - diff, TABLET_Y - diff, BASE_GRIP_Z, BACKPLATE_R);
    translate([0, 0, -PROTRUSION]) rounded_cube_centered(TABLET_X - diff2, TABLET_Y - diff2, BASE_GRIP_Z + 2*PROTRUSION, BACKPLATE_R);
    translate([arm1_shift_x, arm1_shift_y, -PROTRUSION])
        rotate([0, 0, -45])
            translate([0, -ARM_Y, 0])
                rounded_cube(ARM_X, 2*ARM_Y, BASE_GRIP_Z + 2*PROTRUSION, ARM_D);
    translate([arm2_shift_x, arm2_shift_y, -PROTRUSION])
        rotate([0, 0, -135])
            translate([0, -ARM_Y, 0])
                rounded_cube(ARM_X, 2*ARM_Y, BASE_GRIP_Z + 2*PROTRUSION, ARM_D);

}
translate([arm1_shift_x, arm1_shift_y, -.5])
    rotate([0, 0, -45])
        arm_grip(ARM_X, ARM_Y, ARM_Z, ARM_D, WALL_THICKNESS);

translate([arm2_shift_x, arm2_shift_y, -.5])
    rotate([0, 0, -135])
        arm_grip(ARM_X, ARM_Y, ARM_Z, ARM_D, WALL_THICKNESS);

//backplate_bottom(2);

//translate([30, 0, WALL_THICKNESS + M3BOLTHEAD_Z]) fixed_arm(ARM_X, ARM_Y, ARM_Z, ARM_Z2, ARM_D);
// intersection() {
//     arm_grip(ARM_X, ARM_Y, ARM_Z, ARM_D, WALL_THICKNESS);
//     translate([40, -10, 0]) cube([20, 40, 40]);
// }

//arm_grip(ARM_X, ARM_Y, ARM_Z, ARM_D, WALL_THICKNESS);
