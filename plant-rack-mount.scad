$fn=20;

DEPTH=6;
WIDTH=23;
SCREW_HOLE_DIAMETER=6;
SCREW_HOLE_LEFT=0;
SCREW_HOLE_RIGHT=1;

width=WIDTH;
dent_depth=2;

module screw_hole(placement=SCREW_HOLE_LEFT) {
        translate([width/2,(1+2*placement)*width/2,-1]) cylinder(d=SCREW_HOLE_DIAMETER,h=DEPTH+2);
}

module plate(width, height,placement=SCREW_HOLE_LEFT) {
    difference() {
        union() {
            cube([width, height, DEPTH]);
        }
        screw_hole(placement);
    }
}

module small_plate() {
    plate(width, width*2);
}

module big_plate() {
    plate(2*width, 2*width, placement=SCREW_HOLE_RIGHT);
}

module edge(depth) {
    cube([width, DEPTH, depth]);
}

module cutoff_edge(depth) {
    difference(){
        edge(depth);
        rotate([19,0,0]) translate([0,-.2,-depth]) edge(3*depth);
    }
}

module bottom_part(){
     union() {
        small_plate();
        translate([0,2*width,0]) edge(3*DEPTH);
        translate([width,-DEPTH,3*DEPTH]) rotate([0,180,0]) cutoff_edge(3*DEPTH);
    }
 }

module top_part(){
     union() {
        big_plate();
        translate([0,0,DEPTH]) plate(width, width*2,placement=SCREW_HOLE_RIGHT);
        translate([0,-DEPTH,0]) cutoff_edge(3*DEPTH);
        translate([width,2*width+DEPTH,0]) rotate([0,0,180]) cutoff_edge(3*DEPTH);
        translate([2*width+DEPTH,0,0]) rotate([0,0,90]) edge(2*DEPTH);
    }
}

//translate([0,0,3*DEPTH]) rotate([180,0,90]) color("green") bottom_part();
translate([3*width,0,0]) bottom_part();
top_part();