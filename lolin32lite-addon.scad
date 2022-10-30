// Lolin32 Lite Addon Case
// (c) 2021 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

$fn = 100;

// Definition of mil (1/1000 inch) in mm (used by Eagle)
mil = 1/39.3701;

// Dimensions of the addon board
addon_width = 2163*mil; // ESP32: 2556
addon_height = 1330*mil; // 33.78mm ESP32: 1406 (35.7mm)
addon_depth = 1.5;
edge_radius = 118*mil;

// Dimensions of the lolin32 prototyping board
lolin32_width = 49;
lolin32_height = 26;
lolin32_depth = 1.5;
lolin32_pinheader_depth = 2.5;
// clearance needed for JST 2.0 connector + folded cable
jst_connector = 4;

// Dimensions of the sensor board
sensor_width = 13;
sensor_height = 10;

// Outer dimensions
case_top_depth = 10.5;
case_bottom_depth = 15;
case_width = 76 + 2;
case_height = 21 + 28 + 2*edge_radius + 2 + 1.5;

// Tiewrap cutout dimensions
tiewrap_width = 11;
tiewrap_height = .5;

// Battery dimensions
battery_width = 76;
battery_height = 21;
battery_depth = 20.5;

// Battery clip dimensions
clip_width = 10;
clip_height = 2;
clip_depth = 7;


module lolin32(width, height, depth, pinheader_depth) {
    difference() {
        cube([width, height, depth]);
//        translate([2.5, 2.5, -depth]) cylinder(r=1.5, h=4*depth);
//        translate([2.5, height-2.5,-depth]) cylinder(r=1.5, h=4*depth);
        translate([10 - 1.5, 2.5, -depth]) cylinder(r=1.5, h=4*depth);
        translate([width-2.5, height-2.5, -depth]) cylinder(r=1.5, h=4*depth);
        // next 4 cutouts are not fully accurate!
//        translate([0, 0, -depth]) rotate([0, 0, -45]) cube([3, 3, 8], true);
        translate([width, 0, -depth]) rotate([0, 0, 45]) cube([3, 3, 8], true);
        translate([width, height, -depth]) rotate([0, 0, -45]) cube([3, 3, 8], true);
//        translate([0, height, -depth]) rotate([0, 0, -45]) cube([3, 3, 8], true);
    }
    // Pinheaders (plastic part only)
    translate([10, 0, -pinheader_depth]) cube([33, 2.5, pinheader_depth]);
    translate([10, height-2.5, -pinheader_depth]) cube([33, 2.5, pinheader_depth]);

    // Reset button
    translate([1.5, (height - 3)/2, depth]) cube([3.8, 3, 2]);
    // USB port
    translate([0, 2, depth]) cube([6, 8, 4 - depth]);
    // JST 2.0 battery connector
    translate([0, height - 1 - 8, depth]) cube([8, 8, 7 - depth]);
}


module addon_board(width, height, depth, edge) {
    difference() {
        translate([edge, edge, 0]) {
            minkowski() {
                cube([width-2*edge, height-2*edge, depth/2]);
                cylinder(r=edge, h=depth/2);
            }
        }
        // screw holes
        translate([2000*mil, 150*mil, -depth]) cylinder(r=1.5, h=4*depth);
        translate([2000*mil, 1150*mil, -depth]) cylinder(r=1.5, h=4*depth);
        }

    // Pinheaders
    translate([150*mil, 4, depth]) cube([33, 2.5, 8.5]);
    translate([150*mil, lolin32_height + 4 - 2.5, depth]) cube([33, 2.5, 8.5]);
    translate([2000*mil - 1.25, (addon_height - 12)/2, depth]) cube([2.5, 10, 8.5]);
}

module sensor(sensor_width, sensor_height) {
    color("lightblue")
    union() {
        // Pinheader
        cube([2.5, sensor_height, 2.5]);
        // PCB
        translate([0, 0, 2.5]) cube([sensor_width, sensor_height, 1.5]);
        
    }
    // Actual sensor
    translate([sensor_width - 5, 1, 4]) color("lightcoral") cube([4, 4, .5]);

}


module battery() {
    cube([battery_width, battery_height, battery_depth]);
}


module case_part(board_width, board_height, board_radius, case_depth, case_enlargement) {
    width = board_width+case_enlargement;
    height = board_height+case_enlargement;
    edge = board_radius+.5*case_enlargement;
    translate([edge, edge, 0]) {
        minkowski() {
              cube([width-2*edge, height-2*edge, case_depth/2]);
              cylinder(r=edge, h=case_depth/2);
        }
    }
}


module battery_clip(x, y, z) {
    // cube([x, y, z]);
    hull() {
        translate([y/2, y/2, 0]) {
            cylinder(d=y, h=z);
            translate([x - y, 0, 0]) cylinder(d=y, h=z); 
        }
    }
}


module case_bottom(board_width, board_height, case_depth, board_radius) {
    enlargement=5;
    depth=2;
    tolerance=15.5/15;
    difference() {
        case_part(board_width, board_height, board_radius, case_depth, case_enlargement=enlargement);
        // main cutout
        translate([2, 2, depth]) case_part(board_width, board_height, board_radius, case_depth, case_enlargement=1);
        // click closing edge
        //translate([2-.25, 2.5-.25, 13]) case_bottom_part(board_width+3, board_height, board_radius, 3, case_enlargement=1.50);
        translate([2-.5, 2-.5, 11]) case_part(board_width, board_height, board_radius, 2, case_enlargement=2);
        //tiewrap cutout
        translate([(board_width-tiewrap_width)/2,-tiewrap_height,-1]) cube([tiewrap_width,tiewrap_height*2,20]);
        translate([(board_width-tiewrap_width)/2,board_height+enlargement-tiewrap_height,-1]) cube([tiewrap_width,tiewrap_height*2,20]);

     }
    // rests without screw holes
     translate([jst_connector + 10 + 50*mil, 150*mil+2.5, 0]) cylinder(r=1.5, h=4);
     translate([jst_connector + 10 + 50*mil, 1150*mil+2.5, 0]) cylinder(r=1.5, h=4);
    // rests with screw holes
    translate([jst_connector + 10 + 1850*mil + 2.5, 150*mil+2.5, 0]) cylinder(r=1.4, h=6);
    translate([jst_connector + 10 + 1850*mil + 2.5, 1150*mil+2.5, 0]) cylinder(r=1.4, h=6);
    translate([jst_connector + 10 + 1850*mil + 2.5, 150*mil+2.5, 0]) cylinder(r=4, h=4);
    translate([jst_connector + 10 + 1850*mil + 2.5, 1150*mil+2.5, 0]) cylinder(r=4, h=4);
    // battery clips
    translate([0, addon_height - clip_height + 2.5, 0])
        battery_clip(2 + clip_width, clip_height, 2 + clip_depth);
    translate([case_width - clip_width + 3, addon_height - clip_height + 2.5, 0])
        battery_clip(2 + clip_width, clip_height, 2 + clip_depth);
}


module usb_port(depth) {
    z = 4;
    translate([-1, depth + .5 + 150*mil, -z ]) cube([10, 12, 7 + z]);
}


module case_top_closed(board_width, board_height, case_depth, board_radius) {
    enlargement=5;
    depth=2;
                                                                           
    union(){
        difference() {
            case_part(board_width, board_height, board_radius, case_depth, case_enlargement=enlargement);
            // main cutout
            translate([2, 2, -depth])
                case_part(board_width, board_height, board_radius, case_depth, case_enlargement=1);
            
            // USB port
            usb_port(depth);

            //tiewrap cutout
            translate([(board_width-tiewrap_width)/2,-tiewrap_height,-1])
                cube([tiewrap_width,tiewrap_height*2,20]);
            translate([(board_width-tiewrap_width)/2,board_height+enlargement-tiewrap_height,-1])
                cube([tiewrap_width,tiewrap_height*2,20]);

        }
        // stands for lolin32 module
        // translate([3+3+6+2, (board_height+enlargement)/2, 3]) cylinder(r=1.5, h=4);
        // translate([47, 7.5, 3]) cylinder(r=1.5, h=5.5);
        // translate([47, board_height+enlargement-7.5, 3]) cylinder(r=1.5, h=5.5);
    }

    // inner walls with ridge to fit on bottom
    difference() {
        difference() {
            union() {
                translate([2, 2, -3.5]) case_part(board_width, board_height, board_radius, case_depth, case_enlargement=1);
                translate([1.5, 1.5, -3]) case_part(board_width, board_height, board_radius, 1, case_enlargement=2);
                    }
            translate([3, 3, -4]) case_part(board_width, board_height, board_radius, case_depth+3, case_enlargement=-1);
        }
        // USB port
        usb_port(depth);
        // edge cutout on front left corner (rectangular)
        translate([0, board_height+enlargement/2-board_radius, -4])
            cube([board_radius*1.8, board_radius*1.8, 20]);
        // edge cutout on front right corner (rectangular)
        translate([0, 0, -4])
            cube([board_radius*1.8, board_radius*1.8, 20]);
        // edge cutout on back left (rectangular)
        translate([board_width+3-board_radius, board_height+enlargement/2-board_radius, -4])
            cube([board_radius*1.8, board_radius*1.8, 20]);
        // edge cutout on back right (rectangular)
        translate([board_width+3-board_radius, 0, -4])
            cube([board_radius*1.8, board_radius*1.8, 20]);
        // remove part of the top ridge           
        translate([0, 0, -3.99])
            cube([board_radius*1.8, board_height+board_radius, 2]);
        }
}


module funnel_solid(hole_radius, height) {
    hull(){
        translate([0, 0, case_top_depth - 5])
            cylinder(r=1.7*hole_radius, h=height);
        translate([0, 0, 2 - height])
            cylinder(r=hole_radius, h=height);
    }
}


module funnel(hole_radius) {
    difference(){
        funnel_solid(hole_radius + .5, height=2);
        funnel_solid(hole_radius, height=2);
    }
}


module case_top(board_width, board_height, case_depth, board_radius) {
    funnel_translation = [2.5 + .25 + jst_connector + 10 - 
                   150*mil + 2000*mil -1.5 + sensor_width - 2,
                   2.5 + addon_height/2 - sensor_height/2 + 2, 3];
    hole_radius = 3;
    difference(){
        union(){
            case_top_closed(board_width, board_height, case_depth, board_radius);
            translate(funnel_translation) funnel(hole_radius);
        }
        translate(funnel_translation) funnel_solid(hole_radius, height=2.01);
        // Viewport for charging LED
        translate([25, 24, 2.30]) cylinder(d=3, h=8);
        // Viewport for user LED
        translate([48, 11, 2.30]) cylinder(d=3, h=8);
        // Opening for Reset button
        translate([10, 20, 3.1]) cylinder(d=2, h=8);
    }
}

// Rendering the modules

module full_assembly() {
    // translate([jst_connector, 4, 12.5]) color("lightblue")
    //     lolin32(lolin32_width, lolin32_height, lolin32_depth, lolin32_pinheader_depth);
    // translate([jst_connector + 10 - 150*mil, 0, 0])
    //     addon_board(addon_width, addon_height, addon_depth, edge_radius);
    // translate([jst_connector + 10 - 150*mil + 2000*mil - 1.25,
    //     (addon_height - sensor_height)/2 - 1, 10]) //color("lightblue")
    //     sensor(sensor_width, sensor_height);
    // translate([1, addon_height + .5, -1])
    //     battery();

    translate([-2.5, -2.5, -3.5]) color("lightgreen") case_bottom(case_width, case_height, case_bottom_depth, edge_radius);
    translate([-2.5, -12.5, 10.5 - 3.5]) color("lightgreen")
        rotate([180, 0, 0])
            case_top(case_width, case_height, case_top_depth, edge_radius);
    // translate([-2.5, -2.5, 11.5 + 0]) color("lightgreen")
    //     case_top(case_width, case_height, case_top_depth, edge_radius);
}

difference(){
    full_assembly();
    //translate([case_width-7, -5, -10]) cube([30, 80, 50]);
    //translate([-5, -105, -10]) cube([10, 180, 50]);
    //translate([-5, 45, -10]) cube([10 + case_width, 50, 50]);
}

// color("purple") translate([case_width-15, 10, 1.5]) cube([5, 5, case_bottom_depth-5]);
// color("violet") translate([case_width-15, 10, 1.5+case_bottom_depth-5]) cube([5, 5, 3]);
// color("purple") translate([0, -20, -3.5]) cube([5, 5, case_top_depth-3]);
