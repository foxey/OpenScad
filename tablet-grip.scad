FN = 30;
$fn = FN;
PROTRUSION = 0.1;  // additional size for clean substractions
TOL = 1;  // tolerance between tablet and grip
TABLET_X = 258.70;  // exact length (according to HUAWEI documentation)
TABLET_Y = 171.80;  // exact width
TABLET_Z = 7.30;  // exact height

M3NUT_Z = 3; // exact: 2.3
M3BOLT_Z = 11.5; // exact: 11
M3BOLTHEAD_Z = 3.5; // exact 3
M3BOLT_D = 3;
M3BOLTHEAD_D= 5.5;

BACKPLATE_Y=40;
BACKPLATE_X=80;
BACKPLATE_Z=2;
BACKPLATE_R=5;
BACKPLATE_SCREW_D=3;
MOUNT_SCREW_D=6;


// Module: tablet - HUAWEI TABLET mock (enlarged with TOL in each dimension)
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
// Z = height of the nut
// rotate = orientation of the flat sides
module m3nut(Z, rotate=0) {
    $fn=6;
    rotate([0,0,rotate]) cylinder(d=6.2,h=Z);
}


// Module: backplate_screwhole
// Z = height
module backplate_screwhole(D, Z) {
    translate([0, 0, PROTRUSION])
        cylinder(d=D, h=Z+2*PROTRUSION);
}


// Module: backplate_base_orig - original base where grip is attached (not used in model)
// Z = height
module backplate_base_orig(Z) {
minkowski()
    {
      cube([BACKPLATE_X-2*BACKPLATE_R,BACKPLATE_Y-2*BACKPLATE_R,Z/2]);
      cylinder(r=5,h=Z/2);
    }
}


// Module: backplate_bottom - recess to attach to clamp
// Z = height
module backplate_bottom(Z) {
union() {
    rounded_cube(BACKPLATE_X + TOL, BACKPLATE_Y + TOL, Z, 2*BACKPLATE_R);
        translate([TOL/2, TOL/2]) {
        tolerance=-1;
        bolthead_shift = BACKPLATE_Z + M3BOLT_Z - Z - M3BOLTHEAD_Z - PROTRUSION - 2.3;
        translate([tolerance/2 + BACKPLATE_R, tolerance + BACKPLATE_R, 0]) {
            backplate_screwhole(BACKPLATE_SCREW_D, BASE_GRIP_Z + PROTRUSION);
            translate([0, 0, bolthead_shift])
                backplate_screwhole(M3BOLTHEAD_D, M3BOLT_Z + PROTRUSION);
        }
        translate([tolerance/2 + BACKPLATE_R, BACKPLATE_Y-BACKPLATE_R-tolerance, 0]) {
            backplate_screwhole(BACKPLATE_SCREW_D, BASE_GRIP_Z + PROTRUSION);
            translate([0, 0, bolthead_shift])
                backplate_screwhole(M3BOLTHEAD_D, M3BOLT_Z + PROTRUSION);
        }
        translate([BACKPLATE_X-BACKPLATE_R-tolerance/2, tolerance + BACKPLATE_R, 0]) {
            backplate_screwhole(BACKPLATE_SCREW_D, BASE_GRIP_Z + PROTRUSION);
            translate([0, 0, bolthead_shift])
                backplate_screwhole(M3BOLTHEAD_D, M3BOLT_Z + PROTRUSION);
        }
        translate([BACKPLATE_X-BACKPLATE_R-tolerance/2, BACKPLATE_Y - BACKPLATE_R - tolerance, 0]) {
            backplate_screwhole(BACKPLATE_SCREW_D, BASE_GRIP_Z + PROTRUSION);
            translate([0, 0, bolthead_shift])
                backplate_screwhole(M3BOLTHEAD_D, M3BOLT_Z + PROTRUSION);       }
        }
    }
}


// Module: backplate_bottom_orig - original backplate to screw the grip on
// Z = height
module backplate_bottom_orig(Z) {
    difference() {
        backplate_base_orig(Z);
        tolerance=-1;
        translate([tolerance/2,tolerance,0])
            backplate_screwhole(BACKPLATE_SCREW_D, Z);
        translate([tolerance/2,BACKPLATE_Y-2*BACKPLATE_R-tolerance,0])
            backplate_screwhole(BACKPLATE_SCREW_D, Z);
        translate([BACKPLATE_X-2*BACKPLATE_R-tolerance/2,tolerance,0])
            backplate_screwhole(BACKPLATE_SCREW_D, Z);
        translate([BACKPLATE_X-2*BACKPLATE_R-tolerance/2,BACKPLATE_Y-2*BACKPLATE_R-tolerance,0])
            backplate_screwhole(BACKPLATE_SCREW_D, Z);
        translate([BACKPLATE_X/2-BACKPLATE_R,BACKPLATE_Y-2*BACKPLATE_R-tolerance*1.5,0])
            backplate_screwhole(BACKPLATE_SCREW_D, Z);
        translate([BACKPLATE_X/2-BACKPLATE_R,tolerance*1.5,0])
            backplate_screwhole(BACKPLATE_SCREW_D, Z);
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
module rounded_cube_round_bottom(X, Y, Z, D) {
    hull(){
        shift=[D/2, D/2, 0];
        for (x = [0, X-D])
                for (y = [0, Y-D]) {
                    translate([x, y, D/2] + shift) sphere(d=D);
                    translate([x, y, 3*Z/4] + shift) cylinder(d=D, h=Z/2, center=true);
            }
    }
}


// Module: tablet_rest - cube with round bottom and edges
// X = length
// Y = width
// Z = height
// D = diameter of rounded edge
module rounded_cube_round_all(X, Y, Z, D) {
    hull(){
        shift=[D/2, D/2, 0];
        for (x = [0, X-D])
                for (y = [0, Y-D]) {
                    translate([x, y, D/2] + shift) sphere(d=D);
                    translate([x, y, 3*Z/4] + shift) sphere(d=D);
            }
    }
}


// Module: tablet_rest - cube with round bottom and edges
// X = length
// Y = width
// Z = height
// D = diameter of rounded edge
module rounded_cube_round_all_centered(X, Y, Z, D) {
    translate([(BACKPLATE_X - X)/2, (BACKPLATE_Y - Y)/2, 0])
        rounded_cube_round_all(X, Y, Z, D);
}


// Module: tablet_rest - cube with round bottom and edges
// X = length
// Y = width
// Z = height
// D = diameter of rounded edge
module tablet_rest(X, Y, Z, D) {
    rounded_cube_round_all(X, Y, Z, D);
}



// Module: ridge - to fix sliding arm in base plate
// X = length
// Y = width of the ridge (from 0)
module ridge(X,Y) {
    translate([X, Y, Y])
        rotate([0, 90, 180])
                scale([Y, Y, 1])
                    linear_extrude(X)
                        polygon([[1,1],[0,1],[1,0]]);
}


// Module: bolt_slit - slit to slide and fix the fixed arm to the base
// X = length of the slit
// Z = height of the arm
module bolt_slit(X, Z) {
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

// Module: rubber_band_slit - slit to fit a rubber band in the moving arm
// X = length of the slit
// Y = width of the arm
// Z = height of the arm
// Z_SLIT = height of the slit
// W = wall thinkness
module rubber_band_slit(X, Y, Z, Z_SLIT, D1, D2) {
    translate([0, 0, Z - Z_SLIT + PROTRUSION]) {
        union() {
            cylinder(d=Y/2, h=Z_SLIT+PROTRUSION);
            hull(){
                cylinder(d1=D1, d2=D2, h=Z_SLIT+PROTRUSION);
                translate([X-D2/2, 0, 0])
                    cylinder(d1=D1, d2=D2, h=Z_SLIT+PROTRUSION);
            }
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
    E = 2*D;  // Extra width & depth for corner block (0 = flush with Y)
    translate([X-D/2, Y, 0])
        rotate([0, 0, 180])
            difference(){
                union(){
                    translate([-D/2, 0, 0]) rounded_cube_round_bottom(X, Y, Z, D);
                    translate([0, D - sqrt(2*(D/2)^2) - sqrt(E^2/2), D/2]) rotate([0, 0, 45])
                        minkowski(){
                            rounded_cube((D + sqrt((Y - 2*D)^2/2)) + E, (D+sqrt((Y-2*D)^2/2)) + E, Z2 + Z, D);
                            sphere(d=D);
                        }
                }
                y=sqrt(Y^2/2);
                translate([D, -sqrt(E^2/2), Z]) rotate([0, 0, 45])
                    cube([y + E , y + E, Z2]);
                translate([3*D, -sqrt(E^2/2), Z]) rotate([0, 0, 45])
                    rounded_cube(y + E, y + E, Y, D);
                translate([Y/2, (Y - M3BOLTHEAD_D)/2, 0])
                    bolt_slit(X-Y,Z);
                R=3;
                translate([0, 0, D/2])
                    ridge(X, R);
                translate([0, Y, D/2])
                     rotate([90, 0, 0])
                         ridge(X, R);
            }
}


// Module: moving_arm - 2 lower arms to be screwed to the base plate
// X = length
// Y = width
// Z = Z
// Z2 = Z of cutout for tablet
// D = diameter of rounded edge
module moving_arm(X, Y, Z, Z2, D){
    E = Y;  // Extra width & depth for corner block (0 = flush with Y)
    Z_SLIT = Z + TOL/2 - WALL_THICKNESS; // Inner chamber height
    D1 = Y/2 - 3;  // Bottom chamber width
    D2 = 3;  // Top chamber width (slit width)

    translate([X-D/2, Y, 0])
        rotate([0, 0, 180])
            union() {
                difference(){
                    union(){
                        translate([-D/2, 0, 0]) rounded_cube_round_bottom(X, Y, Z, D);
                        translate([0, D/2 - E/2, D/2])
                            minkowski(){
                                rounded_cube((Y - D)/2, Y + E - D, Z2 + Z, D);
                                sphere(d=D);
                            }
                    }
                    translate([D, -Y/2-PROTRUSION, Z])
                        cube([Y/2 , Y + E + 2*PROTRUSION, Z2]);
                    translate([Y/2, Y/2, 0])
                        rubber_band_slit(X,Y, Z, Z_SLIT, D1, D2);
                    R=3;
                    translate([0, 0, D/2])
                        ridge(X, R);
                    translate([0, Y, D/2])
                        rotate([90, 0, 0])
                            ridge(X, R);
                    //translate([30, 0, 0]) cube([20, 20, 10]);
                }
                translate([Y/2, Y/2, Z - Z_SLIT]) {
                    cylinder(d1=D2, d2=D1, h=Z_SLIT);
                    cylinder(d=D2 + 1.5, h = Z_SLIT);
                }
            }
}


// Module: arm_grip - slider that fits an arm
// X = length of the arm
// Y = width of the arm
// Z = height of the arm
// D = diameter of the rounded edge
// W = wall thickness under the arm
module arm_grip(X, Y, Z, D, W) {
    ARM_GRIP_Y = 1.5*Y;
    ARM_GRIP_X2 = (ARM_GRIP_Y-Y)/2;
    ARM_GRIP_X = X - ARM_GRIP_X2;
    ARM_GRIP_Z = Z + W + M3NUT_Z + TOL;
    ARM_GRIP_SCREW_X = ARM_GRIP_X2;
    translate([ARM_GRIP_X2, -ARM_GRIP_Y/2, 0])
        union(){
            difference(){
                translate([-ARM_GRIP_X2, 0, 0])
                    rounded_cube_round_bottom(ARM_GRIP_X, ARM_GRIP_Y, ARM_GRIP_Z, D);
                translate([0, -TOL/2 + (ARM_GRIP_Y - Y)/2, ARM_GRIP_Z-Z-TOL/2])
                    rounded_cube_round_bottom(X, Y+TOL, Z + TOL + PROTRUSION, D);
                screw_hole_x = ARM_GRIP_X - 2*ARM_GRIP_X2 - M3BOLT_D/2;
                screw_hole_y = ARM_GRIP_Y/2;
                translate([screw_hole_x, screw_hole_y, -PROTRUSION]) m3nut(M3NUT_Z + PROTRUSION, 90);
                translate([screw_hole_x, screw_hole_y, -PROTRUSION]) backplate_screwhole(BACKPLATE_SCREW_D, ARM_GRIP_Z);
            }
            R=RIDGE;
            translate([0, -TOL/2 + (ARM_GRIP_Y - Y)/2, ARM_GRIP_Z - Z + D/2 + TOL/4]) {
                ridge(ARM_GRIP_X - ARM_GRIP_X2, R);
                translate([0, Y + TOL, 0])
                    rotate([90, 0, 0])
                        ridge(ARM_GRIP_X - ARM_GRIP_X2, R);
            }
        }
}


// Module: outer_base - exterior shape for stiffness 
module outer_base_orig() {
    diff = 2*sqrt(50^2/2);
    diff2 = 2*sqrt(50^2/2) + 20;
    difference() {
        rounded_cube_centered(TABLET_X - diff, TABLET_Y - diff, OUTER_BASE_GRIP_Z, BACKPLATE_R);
        translate([0, 0, -PROTRUSION])
            rounded_cube_centered(TABLET_X - diff2, TABLET_Y - diff2, BASE_GRIP_Z + 2*PROTRUSION, (diff/diff2)*BACKPLATE_R);
    }
}


// Module: outer_base - exterior shape for stiffness 
module outer_base() {
    $fn=18;
    diff = 2*sqrt(50^2/2);
    diff2 = 2*sqrt(50^2/2) + 18;
    translate([0, 0, ARM_D/2])
        minkowski() {
            difference() {
                $fn=FN;
                rounded_cube_centered(TABLET_X - diff, TABLET_Y - diff, OUTER_BASE_GRIP_Z - ARM_D - PROTRUSION, BACKPLATE_R);
                translate([0, 0, -PROTRUSION])
                    rounded_cube_centered(TABLET_X - diff2, TABLET_Y - diff2, BASE_GRIP_Z + 2*PROTRUSION, (diff/diff2)*BACKPLATE_R);
            }
            sphere(d=ARM_D);
        }
}


// Module: outer_base - exterior shape for stiffness 
module outer_base_straight() {
    diff = 2*sqrt(50^2/2);
    diff2 = 2*sqrt(50^2/2) + 13;
            difference() {
                rounded_cube_centered(TABLET_X - diff, TABLET_Y - diff, OUTER_BASE_GRIP_Z, BACKPLATE_R);
                translate([0, 0, -PROTRUSION])
                    rounded_cube_centered(TABLET_X - diff2, TABLET_Y - diff2, BASE_GRIP_Z + 2*PROTRUSION, (diff/diff2)*BACKPLATE_R);
        }
}


// Module: full_base - base backplate plus 3 arm grips
module full_base() {
    union() {
        difference() {
            rounded_cube_centered(BACKPLATE_X + 10, BACKPLATE_Y + 10, BASE_GRIP_Z, BACKPLATE_R);
            translate([0,0,-PROTRUSION])
                rounded_cube_centered(BACKPLATE_X - 14, BACKPLATE_Y - 14, BASE_GRIP_Z + 2*PROTRUSION, BACKPLATE_R);
            translate([0,0,-PROTRUSION])
                union(){
                    backplate_bottom(BACKPLATE_Z + PROTRUSION);
                    rotate([0, 0, 90])
                    translate([BACKPLATE_Y - ARM_D, -(BACKPLATE_X/2 + ARM_Y/2 - RIDGE + TOL/2), WALL_THICKNESS + M3NUT_Z + PROTRUSION])
                        rounded_cube(ARM_Y, ARM_Y+TOL-2*RIDGE, ARM_Z + TOL + PROTRUSION, ARM_D);
                }
        }

        diff = 2*sqrt(40^2/2);
        diff2 = 2*sqrt(40^2/2) + 24;
        arm1_shift_x = BACKPLATE_X/2 + (TABLET_X+TOL-diff)/2 - .9*diff;
        arm1_shift_y = BACKPLATE_Y/2 - (TABLET_Y+TOL-diff)/2 + .9*diff;
        arm2_shift_x = BACKPLATE_X/2 - (TABLET_X+TOL-diff)/2 + .9*diff;
        arm2_shift_y = BACKPLATE_Y/2 - (TABLET_Y+TOL-diff)/2 + .9*diff;
        arm3_shift_x = BACKPLATE_X/2; // - (TABLET_X+TOL-diff)/2 + .9*diff;
        arm3_shift_y = BACKPLATE_Y; // - (TABLET_Y+TOL-diff)/2 + .9*diff;

        arm_shift_z = BASE_GRIP_Z - (ARM_Z + WALL_THICKNESS + M3NUT_Z + TOL);

        arm_grip_factor = 1.5;

        // Outer base cube with 3 holes for the arm_grip's
        difference(){
            outer_base();
            translate([arm1_shift_x, arm1_shift_y, -PROTRUSION])
                rotate([0, 0, -45])
                    translate([0, -arm_grip_factor*ARM_Y/2 + 2, 0])
                        rounded_cube(ARM_X, arm_grip_factor*ARM_Y - 4, BASE_GRIP_Z + 2*PROTRUSION, ARM_D);
            translate([arm2_shift_x, arm2_shift_y, -PROTRUSION])
                rotate([0, 0, -135])
                    translate([0, -arm_grip_factor*ARM_Y/2 + 2, 0])
                        rounded_cube(ARM_X, arm_grip_factor*ARM_Y - 4, BASE_GRIP_Z + 2*PROTRUSION, ARM_D);
            translate([arm3_shift_x, arm3_shift_y, -PROTRUSION])
                rotate([0, 0, 90])
                    translate([0, -arm_grip_factor*ARM_Y/2 + 2, 0])
                        rounded_cube(ARM_X, arm_grip_factor*ARM_Y - 4, BASE_GRIP_Z + 2*PROTRUSION, ARM_D);
        }

        // Top right tablet rest
        rest_diff = 2*sqrt(50^2/2);
        translate([(BACKPLATE_X - 2*12 + ARM_D + (TABLET_X - rest_diff))/2, (BACKPLATE_Y - 2*12 + ARM_D + (TABLET_Y - rest_diff))/2])
                tablet_rest(12, 12, BASE_GRIP_Z, BACKPLATE_R + ARM_D);

        // Top left tablet rest
        translate([(BACKPLATE_X - ARM_D - (TABLET_X - rest_diff))/2, (BACKPLATE_Y - 2*12 + ARM_D + (TABLET_Y - rest_diff))/2])
                tablet_rest(12, 12, BASE_GRIP_Z, BACKPLATE_R + ARM_D);

        // Arm grip - lower right
        translate([arm1_shift_x, arm1_shift_y, arm_shift_z])
            rotate([0, 0, -45])
                arm_grip(ARM_X, ARM_Y, ARM_Z, ARM_D, WALL_THICKNESS);

        // Arm grip - lower left
        translate([arm2_shift_x, arm2_shift_y, arm_shift_z])
            rotate([0, 0, -135])
                arm_grip(ARM_X, ARM_Y, ARM_Z, ARM_D, WALL_THICKNESS);

        // Arm grip - upper center
        translate([arm3_shift_x, arm3_shift_y, arm_shift_z])
            rotate([0, 0, 90])
                difference(){
                    arm_grip(FIXED_ARM_X, ARM_Y, ARM_Z, ARM_D, WALL_THICKNESS);
                    cube([ARM_D, arm_grip_factor*ARM_Y, ARM_Z], center=true); // dirty fix! to remove overlap of fixed arm with baseplate_bottom
                    translate([-ARM_D, -ARM_Y/2-TOL/2+RIDGE, WALL_THICKNESS + M3NUT_Z + .5])
                        rounded_cube(ARM_Y, ARM_Y+TOL-2*RIDGE, ARM_Z + TOL + PROTRUSION, ARM_D);
                }

        // Rubber band pole in upper center arm_grip
        POLE_D1 = ARM_Y-2*RIDGE-6;
        POLE_D2 = ARM_Y-2*RIDGE-3;
        POLE_Y = 3;
        translate([arm3_shift_x, arm3_shift_y, arm_shift_z])
            rotate([0, 0, 90]) {
                hull() {
                    translate([-ARM_D + POLE_Y/2 + (POLE_D2-POLE_D1)/2 , -POLE_D1/2, WALL_THICKNESS + M3NUT_Z - 3/2*TOL - arm_shift_z + PROTRUSION + POLE_Y])
                        rounded_cube(POLE_D1 - ARM_D, POLE_D1, PROTRUSION, ARM_D);
                    translate([-ARM_D + POLE_Y/2 , -POLE_D2/2, ARM_Z + WALL_THICKNESS + M3NUT_Z + TOL])
                        rounded_cube(POLE_D2 - POLE_Y/2 - ARM_D, POLE_D2, PROTRUSION, ARM_D);
                }
                translate([-ARM_D + POLE_Y/2  + (POLE_D2-POLE_D1)/2, -POLE_D1/2, WALL_THICKNESS + M3NUT_Z - 3/2*TOL - arm_shift_z + 2*PROTRUSION])
                    rounded_cube(POLE_D1 - ARM_D, POLE_D1, POLE_Y, ARM_D);

            }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

OUTER_BASE_GRIP_Z = 4;

ARM_X = 80;  // 80
FIXED_ARM_X = 50;  // 40
ARM_Y = 20;  // 20
ARM_Z = 5;  // 5
ARM_Z2 = 8;  // 8
ARM_D = 3;  // 3

WALL_THICKNESS = 2;
BASE_GRIP_Z = ARM_Z + WALL_THICKNESS + M3NUT_Z + TOL;
echo("BASE_GRIP_Z = ", BASE_GRIP_Z);
RIDGE = 3;

// #translate([-(TABLET_X-BACKPLATE_X)/2, -(TABLET_Y-BACKPLATE_Y)/2, BASE_GRIP_Z]) tablet();
full_base();

//translate([30, 0, WALL_THICKNESS + M3BOLTHEAD_Z]) fixed_arm(ARM_X, ARM_Y, ARM_Z, ARM_Z2, ARM_D);
// intersection() {
//     arm_grip(ARM_X, ARM_Y, ARM_Z, ARM_D, WALL_THICKNESS);
//     translate([50, -20, 0]) cube([20, 40, 40]);
// }

// WARNING: these measure are copied from the full_base module
diff = 2*sqrt(40^2/2);
diff2 = 2*sqrt(40^2/2) + 24;
arm1_shift_x = BACKPLATE_X/2 + (TABLET_X+TOL-diff)/2 - .9*diff;
arm1_shift_y = BACKPLATE_Y/2 - (TABLET_Y+TOL-diff)/2 + .9*diff;
arm2_shift_x = BACKPLATE_X/2 - (TABLET_X+TOL-diff)/2 + .9*diff;
arm2_shift_y = BACKPLATE_Y/2 - (TABLET_Y+TOL-diff)/2 + .9*diff;
arm3_shift_x = BACKPLATE_X/2; // - (TABLET_X+TOL-diff)/2 + .9*diff;
arm3_shift_y = BACKPLATE_Y; // - (TABLET_Y+TOL-diff)/2 + .9*diff;

arm_shift_z = BASE_GRIP_Z - (ARM_Z + WALL_THICKNESS + M3NUT_Z + TOL);

// Right bottom fixed arm in correct position with respect to full_base
// translate([arm1_shift_x, arm1_shift_y, arm_shift_z + WALL_THICKNESS + M3NUT_Z + TOL])
//     rotate([0, 0, -45])
//         translate([ARM_Y + 2, -ARM_Y/2, 0])
//             fixed_arm(ARM_X, ARM_Y, ARM_Z, ARM_Z2, ARM_D);
// // Left bottom fixed arm in correct position with respect to full_base
// translate([arm2_shift_x, arm2_shift_y, arm_shift_z + WALL_THICKNESS + M3NUT_Z + TOL])
//     rotate([0, 0, -135])
//         translate([ARM_Y + 2, -ARM_Y/2, 0])
//             fixed_arm(ARM_X, ARM_Y, ARM_Z, ARM_Z2, ARM_D);

// // Top moving arm in correct position with respect to full_base
// translate([arm3_shift_x, arm3_shift_y, arm_shift_z + WALL_THICKNESS + M3NUT_Z + TOL])
//     rotate([0, 0, 90])
//         translate([ARM_Y/2 + 10.5, -ARM_Y/2, 0])
//             moving_arm(FIXED_ARM_X, ARM_Y, ARM_Z, ARM_Z2, ARM_D);

// // Arms only
// fixed_arm(ARM_X, ARM_Y, ARM_Z, ARM_Z2, ARM_D);
// translate([0, 40, 0]) moving_arm(FIXED_ARM_X, ARM_Y, ARM_Z, ARM_Z2, ARM_D);