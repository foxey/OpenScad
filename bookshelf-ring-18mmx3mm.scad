$fn=80;
RING_DIAMETER=18;
NOTCH_DIAMETER=8;
SCREW_HOLE=3;
HEIGHT=5;
NOTCH_HEIGHT=1.5;

module ring(diameter,height) { 
    difference() {
        cylinder(d=diameter, h=height);
        translate([0,0,-.5*height]) cylinder(d=SCREW_HOLE,h=2*height);
    }
}

union() {
    ring(RING_DIAMETER, HEIGHT);
    ring(NOTCH_DIAMETER, HEIGHT+NOTCH_HEIGHT);
}

translate([2*RING_DIAMETER,0,0]) {
    union() {
        ring(RING_DIAMETER, HEIGHT+1);
        ring(NOTCH_DIAMETER, HEIGHT+NOTCH_HEIGHT+1);
    }
}