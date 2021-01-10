// Gaggia Classic - drip tray (lower version to allow larger cups)
use <roundedcube.scad>;
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
delta_h = 18;
foot_r_tolerance=1;
foot_h_tolerance=2;

tray_h = TRAY_H - delta_h;
reservoir_h = TRAY_H - floor_h - delta_h;

module tray_outer() {
    difference() {
        delta_d = (tray_h/TRAY_H)*(TRAY_BOTTOM_D - TRAY_TOP_D);
        one_min_delta_d = (1 - tray_h/TRAY_H)*(TRAY_BOTTOM_D - TRAY_TOP_D);
        echo("delta_d=",delta_d,"one_min_delta_d=",one_min_delta_d);
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
//    translate([-TRAY_W/2, 0,-tray_h]) cube([200,200,200]);
}