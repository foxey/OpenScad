$fn = 100;

// Main dimensions of the knob
radius = 15;
height = 15;
thickness = 2.4;

// Number and sizing of the edge profile
nr_bumps = 60;
bump_size = 0.8;
bump_turn = 45;

// Mount dimensions
mount_radius = 3;
mount_height = height-thickness-1.6;
mount_cutout = 1.5;
mount_thickness = thickness;
cutout_bump = 1.5;

// Top decoration
profile_depth = .4;

module hull() {
    translate([0,0,.5*height])
        rotate([180,0,0])
            difference(){
                cylinder(h = height, r = radius, center = true);
                translate([0,0,-height/2-1])
                    cylinder(h = height-thickness+1,
                        r = radius-thickness, center = false);
                for (i = [0:nr_bumps-1]) {
                    rotate([0,0,i*360/nr_bumps])
                        translate([radius,0,0])
                            rotate([0,0,bump_turn])
                                cube([bump_size,
                                    bump_size,1.1*height],
                                    center = true);
                }
            }
}

module decoration_ring() {
    difference() {
        cylinder(h = profile_depth,
            r = radius/2, center = true);
        cylinder(h = profile_depth,
            r = radius/2-profile_depth,
            center = true);
    }
}

module mount() {
    // width of the flat part of the shaft of the knob
    flat_width=2*sqrt(pow(mount_radius,2)-
        pow(mount_radius-mount_cutout,2));
    
    translate([0,0,thickness])
        difference() {
            union(){
    // cylinder flattend at one side
                difference() {
                    cylinder(h = mount_height,
                        r = mount_radius+mount_thickness,
                        center = false);
                    cylinder(h = 1.2*mount_height,
                        r = mount_radius,
                        center = false);
                    translate([-mount_radius-mount_thickness,
                            -.5*mount_thickness,-.1*mount_height])
                        cube([1.1*mount_radius+mount_thickness,
                            mount_thickness,
                            1.2*mount_height],
                            center = false);
                    translate([mount_radius+mount_thickness+
                        -mount_cutout,
                        -mount_radius-mount_thickness,
                        -.1*mount_height])
                        cube([1.1*mount_radius+mount_thickness,
                            2*(mount_radius+mount_thickness),
                            1.2*mount_height],
                            center = false);
                }
    // flat part to match cutout in knob shaft
                translate([mount_radius-mount_cutout,-mount_radius,0])
                    cube([mount_thickness,mount_radius*2,mount_height],
                        center = false);
            }
            translate([mount_radius,0
                ,mount_height-0.5*cutout_bump])
                cube([mount_thickness*2,flat_width,
                cutout_bump],center = true);
        }
}
//difference() {
union() {
    hull();
    mount();
}
//cube([30,30,30]);
//}