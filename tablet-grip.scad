$fn=36;
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

BACKPLATE_DEPTH=41;
BACKPLATE_WIDTH=81;
BACKPLATE_HEIGHT=2.5;
BACKPLATE_RADIUS=5;
BACKPLATE_SCREW_DIAMETER=3;
MOUNT_SCREW_DIAMETER=6;

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

// Module: backplate_base - cube with rounded edges
// Z = height of the cube
// radius = radius of the corners
// band_x = excess width from BACKPLATE_WIDTH
// band_y = excess depth from BACKPLAYE_DEPTH
module backplate_base(Z, radius, band_x, band_y=0) {
    band_y = (band_y == 0 ) ? band_x : band_y;
    center_shift_x = -BACKPLATE_RADIUS + radius - band_x;
    center_shift_y = -BACKPLATE_RADIUS + radius - band_y;
    translate([center_shift_x, center_shift_y ,0])
        hull()
            {
                for (x =[0, BACKPLATE_WIDTH - 2*radius + 2*band_x])
                    for (y=[0, BACKPLATE_DEPTH - 2*radius + 2*band_y])
                        translate([x, y, 0])
                            cylinder(r=radius,h=Z);
            }
        }

module backplate_screwhole(Z) {
    translate([0,0,0])
        cylinder(d=BACKPLATE_SCREW_DIAMETER,h=Z*10);
}

// Module: backplate_bottom - recess to attach to clamp
module backplate_bottom(Z) {
union() {
        backplate_base(Z, 5, 0);
        tolerance=-.5;
        translate([tolerance/2,tolerance,0])
            backplate_screwhole(Z);
        translate([tolerance/2,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance,0])
            backplate_screwhole(Z);
        translate([BACKPLATE_WIDTH-2*BACKPLATE_RADIUS-tolerance/2,tolerance,0])
            backplate_screwhole(Z);
        translate([BACKPLATE_WIDTH-2*BACKPLATE_RADIUS-tolerance/2,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance,0])
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
                    for (z= [D/2, Z-D/2])
                        translate([x, y, z]+shift) cylinder(d=D, h=D, center=true);
            }
    }
}

// Module: half_rounded_cube - cube with round bottom and edges, but flat top
// X = length
// Y = width
// Z = height
// D = diameter of rounded edge
module half_rounded_cube(X, Y, Z, D,) {
    hull(){
        shift=[D/2, D/2, 0];
        for (x = [0, X-D])
                for (y = [0, Y-D]) {
                    translate([x, y, D/2]+shift) sphere(d=D);
                    translate([x, y, Z-D/2]+shift) cylinder(d=D, h=D, center=true);
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
                    translate([-D/2, 0, 0]) half_rounded_cube(X, Y, Z, D);
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
                    bolt_slit(X-D-Y,Y,Z);
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

//tablet();

difference(){
    backplate_base(7, 2.5, 170 - BACKPLATE_WIDTH, 90 - BACKPLATE_DEPTH);
    translate([0,0,-.1]) backplate_base(12, 2.5, -7);
    translate([0,0,-.1]) backplate_bottom(2);
}

X=80;
Y=20;
Z=5;
Z2=8;
D=3;

// translate[]
//     rotate([0, 0, -45])
//         fixed_arm(X, Y, Z, Z2, D);

// backplate_bottom(2);