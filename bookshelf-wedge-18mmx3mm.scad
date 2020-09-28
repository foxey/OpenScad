$fn=80;
SHELF_DEPTH=200;
WIDTH=28;
RING_DIAMETER=18;
NOTCH_DIAMETER=8;
SCREW_HOLE=3;
HEIGHT=3;
NOTCH_HEIGHT=4.5;
HOLE1_CENTER=187;
HOLE2_CENTER=87;

angle=atan(HEIGHT/SHELF_DEPTH);

module ring() { 
    difference() {
        cylinder(d=RING_DIAMETER, h=HEIGHT);
        translate([0,0,-.5*HEIGHT]) cylinder(d=SCREW_HOLE,h=2*HEIGHT);
    }
}

module notch() { 
    rotate([0,angle,0]) {
        difference() {
            cylinder(d=NOTCH_DIAMETER, h=NOTCH_HEIGHT);
            translate([0,0,-.5*HEIGHT]) cylinder(d=SCREW_HOLE,h=2*HEIGHT);
        }
    }
}


module full_wedge(height) {
    rotate([90,0,0]) {
        linear_extrude(height=WIDTH) {
            polygon(points=[[0,0],[SHELF_DEPTH,0],[0,height]]);
        }
    }
}

union() {
    intersection() {
        full_wedge(HEIGHT);   
        translate([SHELF_DEPTH-HOLE1_CENTER,-WIDTH/2,0]) ring();
    }
        intersection() {
            full_wedge(NOTCH_HEIGHT);
            translate([SHELF_DEPTH-HOLE1_CENTER,-WIDTH/2,0]) notch();
        }}

translate([HOLE2_CENTER-HOLE1_CENTER+1.5*RING_DIAMETER,0,0]) {
    union() {
        intersection() {
            full_wedge(HEIGHT);   
            translate([SHELF_DEPTH-HOLE2_CENTER,-WIDTH/2,0]) ring();
        }
        intersection() {
            full_wedge(NOTCH_HEIGHT);
            translate([SHELF_DEPTH-HOLE2_CENTER,-WIDTH/2,0]) notch();
        }
    }
}