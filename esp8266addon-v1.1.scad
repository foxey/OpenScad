// ESP8266 Addon Case
// (c) 2021 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

$fn = 100;

// Definition of mil (1/1000 inch) in mm (used by Eagle)
mil = 1/39.3701;

// Dimensions of the addon board
addon_width = 2550*mil; // ESP32: 2556
addon_height = 1500*mil; // 38.25mm ESP32: 1406 (35.7mm)
addon_depth = 1.5;
edge_radius = 200*mil;

// Dimensions of the esp8266 prototyping board
esp8266_width = 46.8;
esp8266_height = 30.8;
esp8266_depth = 1.5;
esp8266_pinheader_depth = 2.5;

// RJ12 connector dimensions
rj12_width = 15;
rj12_height = 13;
rj12_depth = 15;

// Jack connector dimensions
jack_width_full = 16;
jack_diameter = 6.5;
jack_width = 11.5;
jack_diameter_full = 9;
jack_depth = 1;

// Pulse repeater LED dimensions
prl_height = 7;
prl_thickness = 1;
prl_inner_diameter = 5;


// Tiewrap cutout dimensions
tiewrap_width = 11;
tiewrap_height = .5;

module esp8266(width, height, depth, pinheader_depth) {
    difference() {
        cube([width, height, depth]);
//        translate([2.5, 2.5, -depth]) cylinder(r=1.5, h=4*depth);
//        translate([2.5, height-2.5,-depth]) cylinder(r=1.5, h=4*depth);
//        translate([width-2.5, 2.5, -depth]) cylinder(r=1.5, h=4*depth);
//        translate([width-2.5, height-2.5, -depth]) cylinder(r=1.5, h=4*depth);
        // next 4 cutouts are not fully accurate!
        translate([0, 0, -depth]) rotate([0, 0, -45]) cube([3, 3, 8], true);
        translate([width, 0, -depth]) rotate([0, 0, 45]) cube([3, 3, 8], true);
        translate([width, height, -depth]) rotate([0, 0, -45]) cube([3, 3, 8], true);
        translate([0, height, -depth]) rotate([0, 0, -45]) cube([3, 3, 8], true);
    }
    translate([3, 0, -pinheader_depth]) cube([38.5, 2.5, pinheader_depth]);
    translate([3, height-2.5, -pinheader_depth]) cube([38.5, 2.5, pinheader_depth]);
    translate([width-15-7.5, (height-12)/2, depth]) cube([15, 12, 3]);
    translate([0, (height-8)/2, depth]) cube([5.5, 8, 2.5]);
    translate([1.5, 6, depth]) cube([3.8, 3, 2]);
    translate([1.5, height-3-6, depth]) cube([3.8, 3, 2]);
}

module jack() {
    rotate([0,90,0]) {
        cylinder(d=jack_diameter_full,h=jack_width);
        cylinder(d=jack_diameter,h=jack_width_full);
    }
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
        translate([2350*mil, 200*mil, -depth]) cylinder(r=1.5, h=4*depth);
        translate([2350*mil, 1300*mil, -depth]) cylinder(r=1.5, h=4*depth);
        }
    translate([6, 4, depth]) cube([38.5, 2.5, 8.5]);
    translate([6,esp8266_height+4-2.5, depth]) cube([38.5, 2.5, 8.5]);
    // RJ12 connector for DSMR cable
    translate([width-rj12_width+2.2, (height-rj12_height)/2, depth])  cube([rj12_width, rj12_height, rj12_depth]);
    // Jack connector for optical sensor
    translate([width-jack_width, (height-rj12_height)/4, depth+jack_diameter_full/2+jack_depth]) jack();

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

module rj12_connector(board_width, board_height, enlargement, depth) {
    tolerance=15.5/15;
    //RJ12 connector opening
    translate([board_width-rj12_width+6, (board_height+enlargement-tolerance*rj12_height)/2, depth+3])  cube([tolerance*rj12_width, rj12_height*tolerance, rj12_depth]);
}

module case_bottom(board_width, board_height, board_radius) {
    enlargement=5;
    case_depth=15;
    depth=2;
    tolerance=15.5/15;
    difference() {
        case_part(board_width, board_height, board_radius, case_depth, case_enlargement=enlargement);
        // main cutout
        translate([2, 2, depth]) case_part(board_width, board_height, board_radius, case_depth, case_enlargement=1);
        // click closing edge
        //translate([2-.25, 2.5-.25, 13]) case_bottom_part(board_width+3, board_height, board_radius, 3, case_enlargement=1.50);
        translate([2-.5, 2-.5, 11]) case_part(board_width, board_height, board_radius, 2, case_enlargement=2);
        //RJ12 connector opening
        rj12_connector(board_width, board_height, enlargement, depth);
        //Jack connector opening
        translate([board_width-jack_width+3.6, (board_height+2*enlargement-rj12_height)/4, depth+jack_diameter_full/2+jack_depth+3]) jack();
        //tiewrap cutout
        translate([(board_width-tiewrap_width)/2,-tiewrap_height,-1]) cube([tiewrap_width,tiewrap_height*2,20]);
        translate([(board_width-tiewrap_width)/2,board_height+enlargement-tiewrap_height,-1]) cube([tiewrap_width,tiewrap_height*2,20]);

     }
    // rests without screw holes
    translate([100*mil+2.5, 200*mil+2.5, 0]) cylinder(r=1.5, h=4);
    translate([100*mil+2.5, 1300*mil+2.5, 0]) cylinder(r=1.5, h=4);
    // rests with screw holes
    translate([2350*mil+2.5, 200*mil+2.5, 0]) cylinder(r=1.4, h=6);
    translate([2350*mil+2.5, 1300*mil+2.5, 0]) cylinder(r=1.4, h=6);
    translate([2350*mil+2.5, 200*mil+2.5, 0]) cylinder(r=4, h=4);
    translate([2350*mil+2.5, 1300*mil+2.5, 0]) cylinder(r=4, h=4);
    
}

module usb_connector(board_height, enlargement) {
    // edge cutout for micro USB connector
    usb_height = 11;
    usb_depth = 8;
    translate([-1, (board_height+enlargement-usb_height)/2, -.5]) cube([usb_depth, usb_height, 7]);
}


module pulse_repeater(height, inner_diameter, thickness) {
    difference() {
        cylinder(h=height, d=inner_diameter+2*thickness);
        translate([0, 0, -.1]) cylinder(h=height+.2, d=inner_diameter);
    }
}


module case_top(board_width, board_height, board_radius) {
    enlargement=5;
    case_depth=9;
    depth=2;
                                                                           
    union(){
        difference() {
            case_part(board_width, board_height, board_radius, case_depth, case_enlargement=enlargement);
            usb_connector(board_height, enlargement);
            // main cutout
            translate([2, 2, -depth])
                case_part(board_width, board_height, board_radius, case_depth, case_enlargement=1);
            
            // punch hole for USER
            translate([8.5, 14, 2.8]) cylinder(r=1, h=6);

            // punch hole for FLASH
            translate([8.5, board_height+enlargement-14, 2.8]) cylinder(r=1, h=6);

            // view hole for LED1
            translate([5+enlargement/2, board_height+enlargement-9.5, 2.8]) cylinder(r=1.5, h=6);
            
            // view hole for LED2
            translate([41, 12.5+enlargement/2, 2.8]) cylinder(r=1.5, h=6);
            
            //RJ12 connector opening
            translate([0,0,-rj12_depth+.25]) rj12_connector(board_width, board_height, enlargement, depth);

            // Pulse repeater LED opening
            translate([board_width+2*depth-prl_inner_diameter/2-2*prl_thickness-7, 1+(prl_inner_diameter/2+2*prl_thickness)+depth+(board_height-rj12_height), 0])
                cylinder(d=prl_inner_diameter , h=prl_height+2*depth);


            //tiewrap cutout
            translate([(board_width-tiewrap_width)/2,-tiewrap_height,-1]) cube([tiewrap_width,tiewrap_height*2,20]);
            translate([(board_width-tiewrap_width)/2,board_height+enlargement-tiewrap_height,-1]) cube([tiewrap_width,tiewrap_height*2,20]);

        }
        // stands for esp8266 module
        translate([3+3+6+2, (board_height+enlargement)/2, 3]) cylinder(r=1.5, h=4);
        translate([47, 7.5, 3]) cylinder(r=1.5, h=5.5);
        translate([47, board_height+enlargement-7.5, 3]) cylinder(r=1.5, h=5.5);

        // mount for pulse repeater LED
        translate([board_width+2*depth-prl_inner_diameter/2-2*prl_thickness-7, 1+(prl_inner_diameter/2+2*prl_thickness)+depth+(board_height-rj12_height), 0])
            pulse_repeater(prl_height, prl_inner_diameter, prl_thickness);
    }

    difference() {
        difference() {
            union() {
                translate([2, 2, -3.5]) case_part(board_width, board_height, board_radius, case_depth, case_enlargement=1);
                translate([1.5, 1.5, -3]) case_part(board_width, board_height, board_radius, 1, case_enlargement=2);
                    }
                    translate([3, 3, -4]) case_part(board_width, board_height, board_radius, case_depth+3, case_enlargement=-1);
                     }
        // USB connector opening
        usb_connector(board_height, enlargement);
        //RJ12 connector opening
        translate([0,0,-rj12_depth+.25]) rj12_connector(board_width, board_height, enlargement, depth);
        //Jack connector opening
        translate([board_width-jack_width+4, (board_height+2*enlargement-rj12_height)/4, -jack_diameter_full/2]) jack();
        // edge cutout on front left corner (rectangular)
        translate([0, board_height+enlargement/2-board_radius, -4])
            cube([board_radius*1.8, board_radius*1.8, 20]);
        // edge cutout on front right corner (rectangular)
        translate([0, 0, -4])
            cube([board_radius*1.8, board_radius*1.5, 20]);
        // edge cutout on back left (rectangular)
        translate([board_width+3-board_radius, board_height+enlargement/2-board_radius, -4])
            cube([board_radius*1.8, board_radius*1.8, 20]);
        // edge cutout on back right (rectangular)
        translate([board_width+3-board_radius, 0, -4])
            cube([board_radius*1.8, board_radius*1.5, 20]);
        // remove part of the top ridge           
        translate([board_width+3-board_radius, 0, -3.99])
            cube([board_radius*1.8, board_height+board_radius, 2]);
        }
}

// Rendering the modules

translate([3, 4, 12.5]) color("lightblue") esp8266(esp8266_width, esp8266_height, esp8266_depth, esp8266_pinheader_depth);
addon_board(addon_width, addon_height, addon_depth, edge_radius);

translate([-2.5, -2.5, -3.5]) color("lightgreen") case_bottom(addon_width, addon_height, edge_radius);
translate([-2.5, -12.5, 5.5]) color("lightgreen")
    rotate([180, 0, 0])
        case_top(addon_width, addon_height, edge_radius);

//translate([-2.5, -2.5, 11.5+0]) color("lightgreen") case_top(addon_width, addon_height, edge_radius);