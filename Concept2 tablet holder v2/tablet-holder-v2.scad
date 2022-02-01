//$fn=50;

BACKPLATE_DEPTH=41;
BACKPLATE_WIDTH=81;
BACKPLATE_HEIGHT=2.5;
BACKPLATE_RADIUS=5;
BACKPLATE_SCREW_DIAMETER=3;
MOUNT_SCREW_DIAMETER=6;

radius=1;

module roundedcube(size = [1, 1, 1], shift = [0, 0], center = false, radius = 0.5, apply_to = "all") {
	// Higher definition curves
    //$fs = .15;        
	// Use shift parameter to change the size of the bottom left/bottom front side with respect to the top
	// If single value, convert to [x, y, z] vector
	size = (size[0] == undef) ? [size, size, size] : size;
	shift = (shift[0] == undef) ? [shift, shift, shift] : shift;

	translate_min = radius;
	translate_xmax = size[0] - radius;
	translate_ymax = size[1] - radius;
	translate_zmax = size[2] - radius;

	diameter = radius * 2;

	module build_point(type = "sphere", rotate = [0, 0, 0]) {
		if (type == "sphere") {
			sphere(r = radius);
		} else if (type == "cylinder") {
			rotate(a = rotate)
			cylinder(h = diameter, r = radius, center = true);
		}
	}

	obj_translate = (center == false) ?
		[0, 0, 0] : [
			-(size[0] / 2),
			-(size[1] / 2),
			-(size[2] / 2)
		];

	translate(v = obj_translate) {
		hull() {
			for (translate_x = [translate_min, translate_xmax]) {
				x_at = (translate_x == translate_min) ? "min" : "max";
				for (translate_y = [translate_min, translate_ymax]) {
					y_at = (translate_y == translate_min) ? "min" : "max";
					for (translate_z = [translate_min, translate_zmax]) {
						z_at = (translate_z == translate_min) ? "min" : "max";
						shift_x = (z_at == "min" && x_at == "min") ? shift[0] : 0;
						shift_y = (z_at == "min" && y_at == "min") ? shift[1] : 0; 
						translate(v = [translate_x + shift_x, translate_y + shift_y, translate_z])
						if (
							(apply_to == "all") ||
							(apply_to == "xmin" && x_at == "min") || (apply_to == "xmax" && x_at == "max") ||
							(apply_to == "ymin" && y_at == "min") || (apply_to == "ymax" && y_at == "max") ||
							(apply_to == "zmin" && z_at == "min") || (apply_to == "zmax" && z_at == "max")
						) {
							build_point("sphere");
						} else {
							rotate = 
								(apply_to == "xmin" || apply_to == "xmax" || apply_to == "x") ? [0, 90, 0] : (
								(apply_to == "ymin" || apply_to == "ymax" || apply_to == "y") ? [90, 90, 0] :
								[0, 0, 0]
							);
							build_point("cylinder", rotate);
						}
					}
				}
			}
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
        translate([BACKPLATE_WIDTH/2-BACKPLATE_RADIUS,BACKPLATE_DEPTH-2*BACKPLATE_RADIUS-tolerance*1.5,0])
            backplate_screwhole(height);
        translate([BACKPLATE_WIDTH/2-BACKPLATE_RADIUS,tolerance*1.5,0])
            backplate_screwhole(height);
    }
}

module bottom_arm() {
    arm_width=200;
    stand_width=100;
    stand_radius=25;
    out_depth=20;
    in_depth=10;
    height=10;
    difference() {
        union() {
        roundedcube(size=[arm_width,out_depth,height], radius=radius);
        translate([(arm_width-stand_width)/2,0,0])
            roundedcube(size=[stand_width,5,100], radius=radius);
        }
        translate([-2*radius,(out_depth-in_depth)/2, height/2])
            roundedcube(size=[arm_width*(1+2*radius),in_depth,height], radius=radius);

    }
}

difference(){
    bottom_arm();
    rotate([-90,0,0]) translate([BACKPLATE_RADIUS+60,-BACKPLATE_DEPTH+BACKPLATE_RADIUS-10,0]) backplate_bottom(2);
}