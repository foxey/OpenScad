TOL = 1; // tolerance between tablet and grip
TABLET_X = 258.70;
TABLET_Y = 171.80;
TABLET_Z = 7.30;

BACKPLATE_DEPTH=41;
BACKPLATE_WIDTH=81;
BACKPLATE_HEIGHT=2.5;
BACKPLATE_RADIUS=5;
BACKPLATE_SCREW_DIAMETER=3;
MOUNT_SCREW_DIAMETER=6;

module tablet() {
    z=(TABLET_Z+TOL)/2;
    hull(){
        for (x = [0, TABLET_X-2*z])
            for (y = [0, TABLET_Y-2*z]) {
                translate([x+z, y+z, z]) sphere(d=TABLET_Z+TOL);
        }
    }
}

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
    translate([0,0,0])
        cylinder(d=BACKPLATE_SCREW_DIAMETER,h=height*4);
}

module backplate_bottom(height) {
union() {
        backplate_base(height);
        tolerance=-.5;
        translate([tolerance/2,tolerance,0])
            backplate_screwhole(height);
        translate([tolerance/2,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance,0])
            backplate_screwhole(height);
        translate([BACKPLATE_WIDTH-2*BACKPLATE_RADIUS-tolerance/2,tolerance,0])
            backplate_screwhole(height);
        translate([BACKPLATE_WIDTH-2*BACKPLATE_RADIUS-tolerance/2,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance,0])
            backplate_screwhole(height);
    }
}


//tablet();
backplate_bottom(2);
inner_backplate_base(2);

BOTTOM_ARM_X=80;
BOTTOM_ARM_Y=20;