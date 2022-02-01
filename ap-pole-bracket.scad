$fn=128;
WIDTH=25.5;
DEPTH=54;
HEIGHT=4;
POLE_DIAMETER=22;
CUTOUT_WIDTH=7;
CUTOUT_DEPTH=18;
HOLES_DEPTH=32;

wall_thickness=3;
bolt_diameter=3;
nut_height=3;

tiewrap_width=2.5;
tiewrap_height=1.2;
tiewrap_passthrough_shift=4.58;

pole_grip_width=POLE_DIAMETER+2*wall_thickness;
pole_grip_edge_tolerance=.2;

module m3_nut(height, rotate=0) {
    $fn=6;
    rotate([0,0,rotate]) cylinder(d=6.2,h=height);
}

module nut_holder(height) {
    difference() {
        cylinder(d=WIDTH-2*CUTOUT_WIDTH, h=height);
        m3_nut(height);
    }
}

module bolt_hole() {
    cylinder(d=bolt_diameter,h=HEIGHT+2);
}

module tiewrap_gutter() {
    cube([tiewrap_width, DEPTH, tiewrap_height]);
}

module tiewrap_passthrough(angle=1) {
    translate([tiewrap_width/2,0,0])
        rotate([angle*30,0,0])
            cube([tiewrap_width,2,10], center=true);
}

module ground_plate_edge() {
    difference() {
        cube([CUTOUT_WIDTH, CUTOUT_WIDTH, wall_thickness]);
        cylinder(r=CUTOUT_WIDTH, h=wall_thickness);
    }
}

module ground_plate() {
    difference() {
        cube([WIDTH, DEPTH, wall_thickness]);
        // Cutouts
        translate([0, 0, -1])
            cube([CUTOUT_WIDTH, CUTOUT_DEPTH, HEIGHT+2]);
        translate([WIDTH-CUTOUT_WIDTH, DEPTH-CUTOUT_DEPTH, -1])
            cube([CUTOUT_WIDTH, CUTOUT_DEPTH, HEIGHT+2]);
        
        // Bolt holes
        translate([WIDTH/2,(DEPTH-HOLES_DEPTH)/2,-1])
            bolt_hole();
        translate([WIDTH/2,HOLES_DEPTH+(DEPTH-HOLES_DEPTH)/2,-1])
            bolt_hole();
        
        // Tiewrap gutters
        translate([CUTOUT_WIDTH-tiewrap_width,-(pole_grip_width/2+tiewrap_passthrough_shift),0])
            tiewrap_gutter();
        translate([WIDTH-CUTOUT_WIDTH,pole_grip_width/2+tiewrap_passthrough_shift,0])
            tiewrap_gutter();
        
        // Tiewrap passthroughs
        translate([CUTOUT_WIDTH-tiewrap_width,DEPTH-pole_grip_width/2-tiewrap_passthrough_shift,0])
            tiewrap_passthrough(-1);
        translate([WIDTH-CUTOUT_WIDTH,pole_grip_width/2+tiewrap_passthrough_shift,0])
            tiewrap_passthrough(1);
        translate([WIDTH-CUTOUT_WIDTH,DEPTH-pole_grip_width/2-tiewrap_passthrough_shift,0])
            tiewrap_passthrough(-1);
        translate([CUTOUT_WIDTH-tiewrap_width,pole_grip_width/2+tiewrap_passthrough_shift,0])
            tiewrap_passthrough(1);
        
        
        // Rounded corners (2x)
        translate([CUTOUT_WIDTH,DEPTH-CUTOUT_WIDTH,0])
            rotate([0,0,90])
                ground_plate_edge();
        translate([WIDTH-CUTOUT_WIDTH,CUTOUT_WIDTH,0])
            rotate([0,0,-90])
                ground_plate_edge();
    }
}

module pole_grip_cut() {
    rotate([30,0,0])
            cube([WIDTH,CUTOUT_DEPTH-(DEPTH-pole_grip_width)/2+1,pole_grip_width], center=true);
}

module half_pole_grip() {
        difference() {
            cube([WIDTH, pole_grip_width, pole_grip_width/2]);
            translate([0,POLE_DIAMETER/2+wall_thickness,pole_grip_width/2])
                rotate([0,90,0])
                    cylinder(d=POLE_DIAMETER,h=WIDTH);
            translate([WIDTH/2,1.55,0])
                pole_grip_cut();
            translate([0,pole_grip_width/2])
                cube([WIDTH, pole_grip_width/2, pole_grip_width/2]);
            translate([WIDTH,wall_thickness+pole_grip_edge_tolerance/2,pole_grip_width/2-wall_thickness/2])
                rotate([-90,180,90])
                    pole_grip_edge();
            
        }
}

module pole_grip() {
    half_pole_grip();
    translate([WIDTH,pole_grip_width,0])
        rotate([0,0,180])
            half_pole_grip();
}

module pole_grip_edge() {
    difference() {
        cube([wall_thickness+pole_grip_edge_tolerance, wall_thickness/2, WIDTH]);
       translate([wall_thickness/2,0,0])
            cylinder(d=wall_thickness+pole_grip_edge_tolerance,h=WIDTH);
    }
}

module ap_pole_bracket() {
    union() {
        ground_plate();
        translate([0, (DEPTH-pole_grip_width)/2, wall_thickness])
            pole_grip();
        translate([WIDTH/2,(DEPTH-HOLES_DEPTH)/2,wall_thickness])
            nut_holder(nut_height);
        translate([WIDTH/2,HOLES_DEPTH+(DEPTH-HOLES_DEPTH)/2,wall_thickness])
            nut_holder(nut_height);
    }
}

ap_pole_bracket();
