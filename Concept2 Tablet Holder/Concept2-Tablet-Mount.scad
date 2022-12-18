$fn=50;

BACKPLATE_DEPTH=40;
BACKPLATE_WIDTH=80;
BACKPLATE_HEIGHT=2.5;
BACKPLATE_RADIUS=5;
BACKPLATE_SCREW_DIAMETER=3;
MOUNT_SCREW_DIAMETER=6;

MOUNT_ARM_WIDTH=16;
MOUNT_ARM_DEPTH=27.6;
MOUNT_ARM_HEIGHT=3;

MOUNT_ARM_PLUGHEAD_DIAMETER=18;

CONCEPT2_WIDTH=70;
CONCEPT2_ANGLE=asin(10/150);
CONCEPT2_HEIGHT=25;

CONCEPT2_ARM_BRIM=8;
CONCEPT2_ARM_SMOOTH_RADIUS=1.5;

M3BOLTHEAD_DIAMETER=5.5;
M3BOLTHEAD_HEIGHT=3;
M3BOLT_DIAMETER=3;

echo("Concept2 angle = ", CONCEPT2_ANGLE);

module m3nut(height, rotate=0) {
    $fn=6;
    rotate([0,0,rotate]) cylinder(d=6.2,h=height);
}

module backplate_base(height) {
minkowski()
    {
      cube([BACKPLATE_WIDTH-2*BACKPLATE_RADIUS,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS,height/2]);
      cylinder(r=5,h=height/2);
    }
}

module inner_backplate_base(height) {
    inner_radius=2.5;
    band_width=7;
    center_shift=-BACKPLATE_RADIUS+inner_radius+band_width;
    translate([center_shift,center_shift,-height/2])
        minkowski()
            {
              cube([BACKPLATE_WIDTH-2*inner_radius-2*band_width,
                BACKPLATE_DEPTH-2*inner_radius-2*band_width,height]);
              cylinder(r=inner_radius,h=height);
            }
        }

module backplate_screwhole(height) {
    translate([0,0,-1])
        cylinder(d=BACKPLATE_SCREW_DIAMETER,h=height+2);
}

module backplate_bottom(height) {
    difference() {
        backplate_base(height);
        tolerance=-1;
        translate([tolerance/2,tolerance,0])
            backplate_screwhole(height);
        translate([tolerance/2,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance,0])
            backplate_screwhole(height);
        translate([BACKPLATE_WIDTH-2*BACKPLATE_RADIUS-tolerance/2,tolerance,0])
            backplate_screwhole(height);
        translate([BACKPLATE_WIDTH-2*BACKPLATE_RADIUS-tolerance/2,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance,0])
            backplate_screwhole(height);
        translate([BACKPLATE_WIDTH/2-BACKPLATE_RADIUS,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance*1.5,0])
            backplate_screwhole(height);
        translate([BACKPLATE_WIDTH/2-BACKPLATE_RADIUS,tolerance*1.5,0])
            backplate_screwhole(height);
    }
}

module backplate_top_without_nuts(height) {
    middle_rib_width=10;
    union() {
        difference() {
            backplate_base(height);
            inner_backplate_base(height);
        }
        translate([-BACKPLATE_RADIUS+BACKPLATE_WIDTH/2-middle_rib_width/2,-BACKPLATE_RADIUS,0])
            cube([middle_rib_width,BACKPLATE_DEPTH,height]);
    }
}

module backplate_top(height) {
    difference() {
        backplate_top_without_nuts(height);
                tolerance=-1;
        translate([tolerance/2,tolerance,0])
            m3nut(height+1,30);
        translate([tolerance/2,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance,0])
            m3nut(height+1,30);
        translate([BACKPLATE_WIDTH-2*BACKPLATE_RADIUS-tolerance/2,tolerance,0])
            m3nut(height+1,30);
        translate([BACKPLATE_WIDTH-2*BACKPLATE_RADIUS-tolerance/2,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance,0])
            m3nut(height+1,30);
        translate([BACKPLATE_WIDTH/2-BACKPLATE_RADIUS,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance*1.5,0])
            m3nut(height+1);
        translate([BACKPLATE_WIDTH/2-BACKPLATE_RADIUS,tolerance*1.5,0])
            m3nut(height+1);
    }
}

module mount_arm_base_2d(width,depth) {
    FACTOR=.85;
    union() {
        translate([width,depth/2]) circle(r=(2*FACTOR-1)*depth/2);
        polygon([[0,0],[width,(1-FACTOR)*depth],[width,FACTOR*depth],[0,depth]]);
    }
}

module mount_arm_2d(width,depth) {
    difference() {
        mount_arm_base_2d(width,depth);
        $fn=100;
        translate([width,depth/2]) circle(d=MOUNT_SCREW_DIAMETER);
    }
}

module mount_arm(width,depth,height) {
    rotate([0,-90,0])
        translate([0,0,-height/2])
            linear_extrude(height=height)
                mount_arm_2d(width,depth);
}

module double_mount_arm(width,depth,height) {
    translate([-1*height,0,0])
        union() {
            mount_arm(width,depth,height);
            translate([2*height,0,0]) mount_arm(width,depth,height);
        }
}

module triple_mount_arm(width,depth,height) {
    translate([-2*height,0,0])
        union() {
            mount_arm(width,depth,height);
            translate([2*height,0,0]) mount_arm(width,depth,height);
            translate([4*height,0,0]) mount_arm(width,depth,height);
        }
}

module backplate_holder() {
    holder_height=2;
    nut_height=2.5;
    backplate_bottom(holder_height);
    translate([0,0,holder_height]) backplate_top(nut_height);
    translate([BACKPLATE_WIDTH/2-BACKPLATE_RADIUS,(BACKPLATE_DEPTH-2*BACKPLATE_RADIUS)/2-MOUNT_ARM_DEPTH/2,holder_height])
        triple_mount_arm(MOUNT_ARM_WIDTH,MOUNT_ARM_DEPTH,MOUNT_ARM_HEIGHT);
}

module concept2_arm_2d_sharpedged(depth) {
    brim=CONCEPT2_ARM_BRIM;
    width=CONCEPT2_WIDTH/2;
    height=CONCEPT2_HEIGHT;
    outerwidth=width+depth;
    outerheight=height+2*depth;
    polygon([[0,0],
        [outerwidth,0],[outerwidth,outerheight],
        [2*depth,outerheight],[2*depth,outerheight+brim],
        [0,outerheight+brim],
        [0,height+depth],[width,height+depth],
        [width,depth],
        [0,depth]]);
}

module edge_smoother_2d(radius) {
    translate([-radius/2,radius/2,0]) rotate([0,0,-90])
        difference() {
            square(radius);
            circle(r=radius);
        }
}

module concept2_arm_2d(depth) {
    union() {
        translate([2*depth++CONCEPT2_ARM_SMOOTH_RADIUS/2,CONCEPT2_HEIGHT+2*depth+CONCEPT2_ARM_SMOOTH_RADIUS/2,0])
            rotate([0,0,-90]) edge_smoother_2d(CONCEPT2_ARM_SMOOTH_RADIUS);
        difference() {
            concept2_arm_2d_sharpedged(depth);
            translate([CONCEPT2_WIDTH/2+depth-CONCEPT2_ARM_SMOOTH_RADIUS/2,CONCEPT2_ARM_SMOOTH_RADIUS/2,0])
                edge_smoother_2d(CONCEPT2_ARM_SMOOTH_RADIUS);
            translate([CONCEPT2_WIDTH/2+depth-CONCEPT2_ARM_SMOOTH_RADIUS/2,CONCEPT2_HEIGHT+2*depth-CONCEPT2_ARM_SMOOTH_RADIUS/2,0])
                rotate([0,0,90]) edge_smoother_2d(CONCEPT2_ARM_SMOOTH_RADIUS);
            translate([2*depth-CONCEPT2_ARM_SMOOTH_RADIUS/2,CONCEPT2_HEIGHT+2*depth-CONCEPT2_ARM_SMOOTH_RADIUS/2+CONCEPT2_ARM_BRIM,0])
                rotate([0,0,90]) edge_smoother_2d(CONCEPT2_ARM_SMOOTH_RADIUS);

        }
    }
}

module concept2_arm_without_nuts(depth,height,angle) {
        linear_extrude(height=height,scale=[1-2*height*sin(angle)/CONCEPT2_WIDTH,1])
                concept2_arm_2d(depth);
        translate([MOUNT_ARM_HEIGHT,0,(height-MOUNT_ARM_DEPTH)/2])
            rotate([90,0,0])
                mount_arm(MOUNT_ARM_WIDTH,MOUNT_ARM_DEPTH,MOUNT_ARM_HEIGHT);
}

module concept2_arm_right(depth,height,angle) {
    difference() {
        concept2_arm_without_nuts(depth,height,angle);
        translate([depth,CONCEPT2_HEIGHT+depth+CONCEPT2_ARM_BRIM/2+5.5/2,5]) rotate([0,90,0]) {
            m3nut(10);
            translate([0,0,-depth]) backplate_screwhole(10);
        }
        translate([depth,CONCEPT2_HEIGHT+depth+CONCEPT2_ARM_BRIM/2+5.5/2,height-5]) rotate([0,90,0]) {
            m3nut(10);
            translate([0,0,-depth]) backplate_screwhole(10);
        }
    }
}

module concept2_arm_left(depth,height,angle) {
    mirror([0,180,0])
    difference() {
        concept2_arm_without_nuts(depth,height,angle);
        translate([depth,CONCEPT2_HEIGHT+depth+CONCEPT2_ARM_BRIM/2+5.5/2,5]) rotate([0,90,0]) {
            cylinder(d=5.5,h=depth*2);
            translate([0,0,-depth]) backplate_screwhole(10);
        }
        translate([depth,CONCEPT2_HEIGHT+depth+CONCEPT2_ARM_BRIM/2+5.5/2,height-5]) rotate([0,90,0]) {
            cylinder(d=M3BOLTHEAD_DIAMETER,h=depth*2);
            translate([0,0,-depth]) backplate_screwhole(10);
        }
    }
}

module mount_arm_plug_without_holes(bolt_height) {
    union() {
        cylinder(d=18,h=bolt_height);
        translate([0,0,bolt_height]) cylinder(d=MOUNT_SCREW_DIAMETER-.5,h=5*MOUNT_ARM_HEIGHT);
    }
}

module mount_arm_plug() {
    difference() {
        nut_diameter=M3BOLT_DIAMETER;
        bolt_height=12;
        mount_arm_plug_without_holes(M3BOLTHEAD_HEIGHT);
        m3nut(M3BOLTHEAD_HEIGHT);
        translate([0,0,-1]) cylinder(d=nut_diameter,h=5*MOUNT_ARM_HEIGHT+bolt_height+20);
    }
}

module mount_arm_plug_top() {
    difference() {
        cylinder(d=MOUNT_ARM_PLUGHEAD_DIAMETER,h=M3BOLTHEAD_HEIGHT);
        translate([0,0,-1]) cylinder(d=M3BOLTHEAD_DIAMETER,h=M3BOLTHEAD_HEIGHT+2);
    }
}

module bolt_support_ring() {
    difference() {
        cylinder(d=18,h=4.5);
        translate([0,0,-1]) cube([8,8,2*4.5+4], center=true);
    }
}

backplate_holder();
translate([0,-55,0]) concept2_arm_right(3,40,CONCEPT2_ANGLE);
translate([0,-110,0]) concept2_arm_left(3,40,0);

//translate([0,-180,0]) bolt_support_ring();

//translate([0,-180,0]) mount_arm_plug();
//translate([0,-230,0]) mount_arm_plug_top();