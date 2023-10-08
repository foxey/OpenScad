// Garden Lamp PCB Stand
// (c) 2023 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

$fn = 50;
TOL = .01;

// Definition of mil (1/1000 inch) in mm (used by Eagle)
mil = 1/39.3701;

BASE_HEIGHT = 2;
STAND_R = 150*mil;
STAND_X1 = STAND_R;
STAND_Y1 = STAND_R;
STAND_X2 = 3750*mil;
STAND_Y2 = STAND_R;
STAND_X3 = 1900*mil;
STAND_Y3 = 2405*mil;

STAND_HEIGHT = 8;
LAMP_STAND_BRIDGE_HEIGHT = 30.5;
LAMP_STAND_HEIGHT = 70 + LAMP_STAND_BRIDGE_HEIGHT/2;

module body(h, r) {
    hull() {
        translate([STAND_X1, STAND_Y1, 0])
            cylinder(r=r, h=h);
        translate([STAND_X2, STAND_Y2, 0])
            cylinder(r=r, h=h);
        translate([STAND_X3, STAND_Y3, 0])
            cylinder(r=r, h=h);
    }
}

module stands(h, r) {
    union() {
        translate([STAND_X1 ,150*mil, 0])
            cylinder(r=r, h=h);
        translate([3750*mil ,150*mil, 0])
            cylinder(r=r, h=h);
        translate([1900*mil ,2405*mil, 0])
            cylinder(r=r, h=h);
    }
}

module hollow_body(d, r1, r2) {
    difference() {
        body(d, r1);
        translate([0, 0, -TOL])
            body(d + 2*TOL, r2);
    }
}

module hexagon(r) {
    $fn = 6;
    h = 30;
    translate([0, 0, -h/2])
    cylinder(r=r, h=h);
}

module hexagons(r, d) {
    translate([d, 0, 0])
        for (i = [0:6])
            for (j = [0:14])
            {
                d = 1 + d/r;
                translate([d*(3*i*r + 1.5*(j%2)*r), d*j*r*cos(30), 0])
                    hexagon(r);
            }
}

module lamp_stand_leg(r, x, orientation = 0) {
        r2 = 1;
        translate([r, 0, 0]) {
            difference() {
                union(){
                    hull() {
                        cylinder(r=r, h = BASE_HEIGHT);
                        translate([x, 0, 0])
                            cylinder(r=r, h = BASE_HEIGHT);

                        translate([r2, -r2, STAND_HEIGHT - TOL])
                            cylinder(r=r2, h = TOL);
                        translate([x - r2, -r2, STAND_HEIGHT - TOL])
                            cylinder(r=r2, h = TOL);
                        translate([r2, -r + r2, STAND_HEIGHT - TOL])
                            cylinder(r=r2, h = TOL);
                        translate([x - r2, -r + r2, STAND_HEIGHT - TOL])
                            cylinder(r=r2, h = TOL);
                    }
                    hull() {
                        translate([r2, -r2, STAND_HEIGHT - TOL])
                            cylinder(r=r2, h = TOL);
                        translate([x - r2, -r2, STAND_HEIGHT - TOL])
                            cylinder(r=r2, h = TOL);
                        translate([r2, -r + r2, STAND_HEIGHT - TOL])
                            cylinder(r=r2, h = TOL);
                        translate([x - r2, -r + r2, STAND_HEIGHT - TOL])
                            cylinder(r=r2, h = TOL);

                        translate([r2, -r2, LAMP_STAND_HEIGHT - r2])
                            sphere(r=r2);
                        translate([x - r2, -r2, LAMP_STAND_HEIGHT - r2])
                            sphere(r=r2);
                        translate([r2, -r + r2, LAMP_STAND_HEIGHT - r2])
                            sphere(r=r2);
                        translate([x - r2, -r + r2, LAMP_STAND_HEIGHT - r2])
                            sphere(r=r2);
                    }
                }
                slit_x = 3;
                slit_y = 1.5;
                slit_z = LAMP_STAND_BRIDGE_HEIGHT;
                translate([orientation*(x - slit_x + 2*TOL) - TOL, -r/2 - slit_y/2, LAMP_STAND_HEIGHT - slit_z])
                    cube([slit_x + TOL, slit_y, slit_z + TOL]);
            }
        }
}

module lamp_stand() {
    x = 23;
    r = 5;
    x_leg = 10;
    translate([x - r, 0, 0])
        lamp_stand_leg(r, x_leg, orientation = 1);
    translate([STAND_X2 + STAND_R - x_leg - 2*r - x, 0, 0])
        lamp_stand_leg(r, x_leg, orientation = 0);
}

module main() {
    difference() {
        h = STAND_HEIGHT;
        r = STAND_R;
        union() {
            difference() {
                body(2, r);
                hexagons(200*mil, 50*mil);
            }
            body(.2, r);
            hollow_body(2, r, 50*mil);
            stands(h, r);
            lamp_stand();
        }
        translate([0, 0, .4])
            stands(h, 25*mil);
    }
}

module lamp_stand_bridge() {
    z = 5;
    z2 = 1.3;
    difference() {
        union() {
            translate([-2, 0, 0])
                cube([(STAND_X2 + STAND_R) - 2*(23 + 10) - 5 + 4, LAMP_STAND_BRIDGE_HEIGHT, 1.3]);
            cube([(STAND_X2 + STAND_R) - 2*(23 + 10) - 5, LAMP_STAND_BRIDGE_HEIGHT, (z + z2)/2]);
            translate([((STAND_X2 + STAND_R) - 2*(23 + 10) - 5)/2, LAMP_STAND_BRIDGE_HEIGHT/2, 0])
                cylinder(d=10, h=(z + z2)/2+.5);
        }
        translate([((STAND_X2 + STAND_R) - 2*(23 + 10) - 5)/2, LAMP_STAND_BRIDGE_HEIGHT/2, -TOL])
            cylinder(r=25*mil, h=10);
    }
}

module lamp_stand_cover() {
    difference() {
        rotate_extrude($fn=90){
            union(){
                square([4,3]);
                difference(){
                translate([4,0])
                    circle(r=3);
                translate([0,-5])
                square([8,5]);
                }
            }
        }
        translate([0, 0, -TOL])
            cylinder(d=2, h=5);
        translate([0, 0, 2])
            cylinder(d1=2, d2=8, h=4);
    }
}

module sensor_mount() {
    h = 9;
    union(){
        difference() {
            cylinder(r=10, h=h);
            translate([5, -11/2, -TOL]) {
                translate([0, 0, 0])
                    cylinder(r=25*mil, h=h+2*TOL);
                translate([0, 11, 0])
                    cylinder(r=25*mil, h=h+2*TOL);
            }
            translate([0, 0, -TOL])
                cylinder(d=3, h=h+2*TOL);
            translate([1.5, 0, h-1.5])
                rotate([0, 0, -45])
                    cube([10, 10, 10]);
            translate([0, 0, -TOL])
                cylinder(d=sqrt(18)+.2, h=h+2*TOL);
        }
        translate([1.7, -1.5, 0])
            cube([.6, 3, h]);
    }
}

module sensor_mount_top() {
    h = 5;
    e = 2;
    d = 1.2;
    difference() {
        cylinder(r=10, h=h);
        translate([5, -11/2, -TOL]) {
            translate([0, 0, 0])
                cylinder(r=1, h=h+2*TOL);
            translate([0, 11, 0])
                cylinder(r=1, h=h+2*TOL);
        }
        translate([5, -11/2, -TOL]) {
            translate([0, 0, 0])
                cylinder(r=2.1, h=2+TOL);
            translate([0, 11, 0])
                cylinder(r=2.1, h=2+TOL);
        }
        translate([-2.7, -2.7, h-d])
            cube([15, 5.4, d+TOL]);
        translate([2.7, -8.25, h-d])
            difference(){
                cube([15, 16.5, d+TOL]);
                translate([0, -e, 0])
                    rotate([0, 0, 45])
                        cube([e, e, d+2*TOL]);
                translate([0, 16.5-e/2, 0])
                    rotate([0, 0, 45])
                        cube([e, e, d+2*TOL]);
            }
    }
}


main();
// translate([23 + 10, -5+1.5, LAMP_STAND_HEIGHT])
//     rotate([-90, 0, 0])
translate([120, 0, 0])
    lamp_stand_bridge();
translate([120, 50, 0])
    lamp_stand_cover();
translate([140, 50, 0])
    sensor_mount();
translate([140, 75, 0])
    sensor_mount_top();
