// Sureflap battery lid
// (c) 2022 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

$fn = 25;

lid_width = 82.8;
lid_height = 28.8;
lid_depth = 2;
lid_radius = 2.5;

left_cutout_width = 4;
left_cutout_height = 16;
left_cutout_depth = 1;

right_cutout_width_1 = 5;
right_cutout_width_2 = 8;
right_cutout_height_1 = 5;
right_cutout_height_2 = 2;
right_cutout_depth = 1;

middle_cutout_width = 5;
middle_cutout_height = 1.5;
middle_cutout_depth = lid_depth;

stand_width = 54;
stand_height = .75;
stand_depth = 7;
stand_radius = 2.5;

stand_x = 19;
stand_y = 1.2;
stand_z = 0;

hook_width = 3;
hook_height = .75;
hook_depth = 1.5;

hook_1_x = 26;
hook_2_x = lid_width - 18;

// Tolerance
t = .1;

module base_plate() {
    hull() {
        for (x = [0, lid_width - 2*lid_radius]) {
            for (y = [0, lid_height - 2* lid_radius]) {
                translate([x + lid_radius, y + lid_radius, 0])
                    cylinder(r=lid_radius, h=lid_depth);
            }
        }
    }
}

module stand_base() {
    translate([0, stand_height, 0])
        rotate([90, 0, 0])
            hull() {
                for (x = [0, stand_width - 2*stand_radius]) {
                    for (y = [0, stand_depth - 2* stand_radius]) {
                        translate([x, y, 0])
                        if (y==0) {
                                cube([stand_radius*2, stand_radius*2, stand_height]);
                            } else {
                                translate([stand_radius,stand_radius, 0])
                                    cylinder(r=stand_radius, h=stand_height);
                            }
                    }
                }
            }
}

module hook(hook_height) {
    cube([hook_width, hook_height, hook_depth]);
}

module stand() {
    union() {
        stand_base();
        translate([hook_1_x - stand_x, -hook_height, stand_depth - hook_depth])
            hook(hook_height);
        translate([hook_2_x - stand_x, -hook_height, stand_depth - hook_depth])
            hook(hook_height);
    }
}

module mirrored_stand() {
    translate([0, stand_height, 0])
    mirror([0, 1 , 0]) { 
            stand();
    }
}

module left_cutout() {
    translate([-t, (lid_height - left_cutout_height)/2, lid_depth - left_cutout_depth])
        cube([left_cutout_width + t, left_cutout_height, left_cutout_depth + t]);
}

module right_cutout() {
// Bottom cutout
    translate([lid_width - right_cutout_width_1, -t, lid_depth - left_cutout_depth])
        cube([right_cutout_width_1 + t, right_cutout_height_1 + t, right_cutout_depth + t]);
    translate([lid_width - right_cutout_width_2, right_cutout_height_1 - right_cutout_height_2, lid_depth - left_cutout_depth])
        cube([right_cutout_width_2 + t, right_cutout_height_2, right_cutout_depth + t]);
// Top cutout
    translate([lid_width - right_cutout_width_1, lid_height - right_cutout_height_1, lid_depth - left_cutout_depth])
        cube([right_cutout_width_1 + t, right_cutout_height_1 + t, right_cutout_depth + t]);
    translate([lid_width - right_cutout_width_2, lid_height - right_cutout_height_1, lid_depth - left_cutout_depth])
        cube([right_cutout_width_2 + t, right_cutout_height_2, right_cutout_depth + t]);

}

module middle_cutout() {
    translate([(lid_width - middle_cutout_width)/2, lid_height - middle_cutout_height, -t])
        cube([middle_cutout_width, middle_cutout_height + t, middle_cutout_depth + 2*t]);
}

module lid_base() {
    difference() {
        base_plate();
        left_cutout();
        right_cutout();
        // middle_cutout();
    }
}

module lid() {
    union() {
        lid_base();
        translate([stand_x, stand_y, stand_z])
            stand();
        translate([stand_x, lid_height - (stand_y + stand_height), stand_z])
            mirrored_stand();
    }
}

lid();
//mirrored_stand();