/* [Gaggia Classic - drip tray] */
// Height difference from original (mm)
delta_h = -18; // [-35:.2:20]

module roundedcube(size = [1, 1, 1], shift = [0, 0], center = false, radius = 0.5, apply_to = "all") {
	// Higher definition curves
    $fs = .15;        
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

// Original dimensions (in mm)
TRAY_W=195;
TRAY_H=52;
TRAY_TOP_D=125;
TRAY_BOTTOM_D=130;
GRID_W=170;
GRID_D=100;
GRID_H=6.5;
RESERVOIR_R=12;
RESERVOIR_W=160;
RESERVOIR_D=90;
RESERVOIR_H=48.5;
RIDGE_D_FROM_BACK=82;
RIDGE_W_FROM_SIDE=40;
RIDGE_W=2;
RIDGE_H=1.5;
RIDGE_D=7;

FOOT_R=6.5;
FOOT_H=2.5;
FOOT_W=8; // distance from foot to side
FOOT_D=13; // distance from foot to front

// Design parameters (in mm)
floor_h = 2.5;
radius = 2.5;
//delta_h = -18; Set by customizer on top
foot_r_tolerance=1;
foot_h_tolerance=2;

tray_h = TRAY_H + delta_h;
reservoir_h = TRAY_H - floor_h + delta_h;

module tray_outer() {
    difference() {
        delta_d = (tray_h/TRAY_H)*(TRAY_BOTTOM_D - TRAY_TOP_D);
        one_min_delta_d = (1 - tray_h/TRAY_H)*(TRAY_BOTTOM_D - TRAY_TOP_D);
        roundedcube([TRAY_W, TRAY_TOP_D+one_min_delta_d, tray_h], [0, -delta_d, 0], true, radius, "all");
        translate([0,0,tray_h-reservoir_h+.5*GRID_H])
            roundedcube([RESERVOIR_W, RESERVOIR_D, tray_h+GRID_H], 0, true, RESERVOIR_R, "all");
     }
}

module grid() {
    translate([0, 0, tray_h/2-GRID_H/2])
        cube([GRID_W, GRID_D, GRID_H], true);
}

module edge_bar(h=1,r=1, c="cube") {
    if (c == "cube") {
        cube([r, r, h], true);
    } else if (c == "round") {
        $fn=64;
        translate([-r/2, -r/2, 0])
            difference() {
                cylinder(h=h, r=r, center=true);
                translate([-r, 0, 0])
                    cube([2*r,2*r,h+2*r], true);
                translate([0, -r, 0])
                    cube([2*r,2*r,h+2*r], true);
            }
    }
} 

module grid_edge(c="cube") {
    translate([-GRID_W/2-radius, -GRID_D/2, (tray_h/2-radius)]) {
        translate([radius/2, GRID_D/2, radius/2])
            rotate([90,0,0])
                edge_bar(GRID_D+radius, radius, c);
        translate([GRID_W+1.5*radius, GRID_D/2, radius/2])
            rotate([90,-90,0])
                edge_bar(GRID_D+radius, radius, c);
        translate([GRID_W/2+radius,-radius/2,radius/2])
            rotate([90,0,90])        
                edge_bar(GRID_W+radius, radius, c);
        translate([GRID_W/2+radius,GRID_D+radius/2,radius/2])
            rotate([90,-90,90])        
                edge_bar(GRID_W+radius, radius, c);
    }
}

module foot_recess(side="right") {
    tray_d = TRAY_BOTTOM_D-TRAY_TOP_D/2-FOOT_R-FOOT_D;
    tray_w = TRAY_W/2-FOOT_R-FOOT_W;
    tray_w_side = (side == "left") ? -tray_w : tray_w;
     translate([tray_w_side, -tray_d, -tray_h/2+(FOOT_H+foot_h_tolerance)/2])
        cylinder(h=FOOT_H+foot_h_tolerance, r=FOOT_R+foot_r_tolerance, center=true);
}

module tray() {
    union() {
        difference() {
            tray_outer();
            grid();
            grid_edge("cube");
        }
        grid_edge("round");
    }
}

difference() {
    tray();
    foot_recess("left");
    foot_recess("right");
//    translate([-TRAY_W/2-1, 0,-tray_h]) cube([200,200,200]);
}