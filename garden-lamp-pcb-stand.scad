// Garden Lamp PCB Stand
// (c) 2023 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

$fn = 50;
TOL = .01;

// Definition of mil (1/1000 inch) in mm (used by Eagle)
mil = 1/39.3701;

module body(h, r) {
    hull() {
        translate([150*mil ,150*mil, 0])
            cylinder(r=r, h=h);
        translate([3750*mil ,150*mil, 0])
            cylinder(r=r, h=h);
        translate([1900*mil ,2405*mil, 0])
            cylinder(r=r, h=h);
    }
}

module stands(h, r) {
    union() {
        translate([150*mil ,150*mil, 0])
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
    h = 1000;
    translate([0, 0, -h/2])
    cylinder(r=r, h=h);
}

module hexagons(r, d) {
    translate([d, 0, 0])
        for (i = [0:9])
            for (j = [0:19])
            {
                d = 1 + d/r;
                translate([d*(3*i*r + 1.5*(j%2)*r), d*j*r*cos(30), 0])
                    hexagon(r);
            }
}

difference() {
    h = 8;
    r = 150*mil;
    union() {
        difference() {
            body(2, r);
            hexagons(200*mil, 50*mil);
        }
        body(.2, r);
        hollow_body(2, r, 50*mil);
        stands(h, r);
    }
    translate([0, 0, .4])
        stands(h, 25*mil);
}