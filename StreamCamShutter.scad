$fn=50;

// Outside dimensions of the Logitech streamcam
STREAMCAM_HEIGHT=48; // mm
STREAMCAM_WIDTH=58; // mm
STREAMCAM_RADIUS=12; // mm (rounded corners)

// Diameter of the metal axis in the hinge
AXIS_DIAMETER=2;
    
// Gap between moving parts
TOLERANCE=.5; // mm


module streamcam(thickness=0, depth=1) {
    height=STREAMCAM_HEIGHT+2*thickness;
    width=STREAMCAM_WIDTH+2*thickness;
    radius=STREAMCAM_RADIUS+thickness;
    translate([radius,radius,0])
    {
        minkowski()
        {
          cube([width-2*radius, height-2*radius, depth/2]);
          cylinder(r=radius, h=depth/2);
        }
    }
}

module hinge(diameter, height) {
    difference() {
        union(){
            translate([0,0,diameter/2]) rotate([0,90,0]) cylinder(r=diameter/2, h=height);
            cube([height,diameter/2,diameter]);
        }
        translate([0,0,diameter/2]) rotate([0,90,0]) cylinder(r=AXIS_DIAMETER/2, h=height);        
    }
}

module brace(thickness, depth) {
    union(){
        difference(){
            streamcam(thickness=thickness, depth=depth);
            translate([thickness,thickness,0]) streamcam(depth=depth*1.1);
        }
        height=(STREAMCAM_WIDTH-2*STREAMCAM_RADIUS)/5-TOLERANCE;
        translate([STREAMCAM_RADIUS,-depth/2,0])
            hinge(diameter=depth, height=height);
        translate([(STREAMCAM_WIDTH-height)/2,-depth/2,0])
            hinge(diameter=depth, height=height);
        translate([STREAMCAM_WIDTH-STREAMCAM_RADIUS-height,-depth/2,0])
            hinge(diameter=depth, height=height);
    }
}

module shutter_hinge(diameter, height, thickness) {
    difference() {
        union(){
            translate([0,0,diameter/2]) rotate([0,90,0]) cylinder(r=diameter/2-TOLERANCE, h=height);
            translate([0,0,TOLERANCE]) cube([height,diameter/2-TOLERANCE-.1,diameter-2*TOLERANCE]);
            translate([0,thickness+TOLERANCE,diameter/2])
                rotate([0,90,0]) cylinder(r=diameter/2-TOLERANCE, h=height);
            translate([0,2*thickness+.1,diameter/4+2*TOLERANCE])
                cube([height,thickness,diameter-2*TOLERANCE]);
            translate([0,thickness+.1,diameter/4+2*TOLERANCE])
                cube([height,thickness,(diameter-TOLERANCE)/2]);
            translate([height,2*thickness+.1,diameter-TOLERANCE]) rotate([90,0,270])
                support(TOLERANCE,height);
            translate([0,2*thickness+.1,diameter+.05]) rotate([-90,90,0])
                support(diameter/2, thickness);
            translate([height,3*thickness+.1,diameter+.05]) rotate([90,90,0])
                support(diameter/2, thickness);
        }
        translate([-.5*height,0,diameter/2]) rotate([0,90,0]) cylinder(r=AXIS_DIAMETER/2, h=height*2);        
    }
}

module shutter(thickness, depth) {
    height=(STREAMCAM_WIDTH-2*STREAMCAM_RADIUS)/5-TOLERANCE;
    union(){    
        streamcam(thickness=thickness, depth=thickness);
        rotate([-90,0,0])
            translate([STREAMCAM_RADIUS+height+1.25*TOLERANCE,-depth+thickness+.1,-depth])
                shutter_hinge(diameter=depth, height=height, thickness=thickness);
        rotate([-90,0,0])
            translate([STREAMCAM_WIDTH-STREAMCAM_RADIUS-2*height-1.25*TOLERANCE,-depth+thickness+.1,-depth])
                shutter_hinge(diameter=depth, height=height, thickness=thickness);
    }
}

module support(radius, thickness) {
    translate([radius,radius,0])
        difference() {
            translate([-radius,-radius,0]) cube([radius,radius,thickness]);
            translate([0,0,-thickness/2]) cylinder(r=radius, h=thickness*2);
        }
}


thickness=1.2;
depth=5;

brace(thickness, depth);
translate([0,0*60,-1.1*thickness]) shutter(thickness, depth);
//translate([12,-5,2]) rotate([0,90,0]) cylinder(r=1, h=34);