$fn=60;

DEPTH=6;
WIDTH=23;
GRATE_WIDTH=100;

SCREW_HOLE_DIAMETER=6;
SCREW_HOLE_LEFT=0;
SCREW_HOLE_RIGHT=1;

module bar() {
    translate([-WIDTH,0,DEPTH]) cube([GRATE_WIDTH+2*WIDTH, WIDTH, DEPTH]);
    translate([0,WIDTH/4,0]) cube([GRATE_WIDTH, WIDTH/2, DEPTH]);
}

module rotated_bar() {
    translate([GRATE_WIDTH/2,WIDTH/2,0]) {
        rotate([0,0,90]) translate([-GRATE_WIDTH/2,-WIDTH/2,0]) {
            difference() {
                bar();
                translate([GRATE_WIDTH-WIDTH/2,WIDTH/2,-2*DEPTH])
                    rounder(diameter=4,width=WIDTH/2);
                translate([WIDTH/2,WIDTH/2,-2*DEPTH]) rotate([0,0,180])
                    rounder(diameter=4,width=WIDTH/2);
            }
        }
    }
}

module end_stop() {
    difference() {
        translate([-WIDTH/2,-WIDTH/2,0]) cube([WIDTH,WIDTH,DEPTH]);
        translate([-WIDTH/2,0,0]) rounder();
    }
}

module cross() {
    translate([-GRATE_WIDTH/2,-WIDTH/2,0]) {
        bar();
        rotated_bar();
    }
}

module ring() {
    difference() {
        $fn=120;
        cylinder(d=GRATE_WIDTH,h=DEPTH);
        cylinder(d=GRATE_WIDTH-WIDTH,h=DEPTH);
    }
}

module mount() {
    union() {
        cross();
        cylinder(d=sqrt(2)*WIDTH,h=DEPTH);
        translate([0,0,DEPTH]) ring();
        translate([-(GRATE_WIDTH+WIDTH)/2,0,0]) end_stop();
        translate([(GRATE_WIDTH+WIDTH)/2,0,0]) rotate([0,0,180]) end_stop();
    }
}

module rounder(width=WIDTH, diameter=8) {
    module outer_cube() {
        cube([width,width,DEPTH*4]);
    }
    
    module rounder_cube() {
        hull() {
            cube([diameter/2,WIDTH,DEPTH*8]);
            translate([width-diameter/2,diameter/2,0]) cylinder(d=diameter,h=DEPTH*8);
            translate([width-diameter/2,width-diameter/2,0]) cylinder(d=diameter,h=DEPTH*8);        
        }
    }
    
    translate([0,-width/2,-DEPTH]) difference() {
        outer_cube();
        rounder_cube();
    }
}


module screw_hole() {
    cylinder(d=SCREW_HOLE_DIAMETER,h=2*DEPTH);
    translate([0,0,2*DEPTH]) rotate([180,0,0]) cylinder(d1=4/3*SCREW_HOLE_DIAMETER,d2=0,h=2*DEPTH);
}

rotate([180,0,0]) translate([0,0,-2*DEPTH])
difference() {
    mount();
    translate([GRATE_WIDTH/2,0,0]) rounder();
    translate([-GRATE_WIDTH/2,0,0]) rotate([0,0,180]) rounder();
    translate([0,-GRATE_WIDTH/2,0]) rotate([0,0,270]) rounder();
    translate([0,GRATE_WIDTH/2,0]) rotate([0,0,90]) rounder();
    screw_hole();
}