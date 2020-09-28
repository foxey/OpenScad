// ESP32 Addon Case
// (c) 2020 Michiel Fokke <michiel@fokke.org>
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode

$fn = 50;

// Font defintion
font = "Open Sans: style=Bold";
font_size = 2;

// Definition of mil (1/1000 inch) in mm (used by Eagle)
mil = 1/39.3701;

// Dimensions of the addon board
addon_width = 2556*mil;
addon_height = 1406*mil;
addon_depth = 1.5;
edge_radius = 200*mil;

// Dimensions of the ESP32 prototyping board
esp32_width = 51.5;
esp32_height = 28.5;
esp32_depth = 1.5;
esp32_pinheader_depth = 2.5;

module esp32(width, height, depth, pinheader_depth) {
    difference() {
        cube([width, height, depth]);
        translate([2.5, 2.5, -depth]) cylinder(r=1.5, h=4*depth);
        translate([2.5, height-2.5,-depth]) cylinder(r=1.5, h=4*depth);
        translate([width-2.5, 2.5, -depth]) cylinder(r=1.5, h=4*depth);
        translate([width-2.5, height-2.5, -depth]) cylinder(r=1.5, h=4*depth);
        // next 4 cutouts are not fully accurate!
        translate([0, 0, -depth]) rotate([0, 0, -45]) cube([3, 3, 8], true);
        translate([width, 0, -depth]) rotate([0, 0, 45]) cube([3, 3, 8], true);
        translate([width, height, -depth]) rotate([0, 0, -45]) cube([3, 3, 8], true);
        translate([0, height, -depth]) rotate([0, 0, -45]) cube([3, 3, 8], true);
    }
    translate([9, 0, -pinheader_depth]) cube([39, 2.5, pinheader_depth]);
    translate([9, height-2.5, -pinheader_depth]) cube([39, 2.5, pinheader_depth]);
    translate([27, (height-16)/2, depth]) cube([17.5, 16, 3]);
    translate([0, (height-8)/2, depth]) cube([5.5, 8, 2.5]);
    translate([1.5, 4.5, depth]) cube([3.8, 3, 2]);
    translate([1.5, height-3-4.5, depth]) cube([3.8, 3, 2]);
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
        translate([2350*mil, 1200*mil, -depth]) cylinder(r=1.5, h=4*depth);
        }
    translate([6, 4, depth]) cube([39, 2.5, 8.5]);
    translate([6,4+2.5+23, depth]) cube([39, 2.5, 8.5]);
    translate([width-3.5, (height-11)/2, depth]) rotate([0, 0, 90]) cube([11, 2.5, 8.5]);

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

module case_bottom(board_width, board_height, board_radius) {
    enlargement=5;
    case_depth=15;
    depth=2;
    difference() {
        case_part(board_width+3, board_height, board_radius, case_depth, case_enlargement=enlargement);
        // main cutout
        translate([2, 2, depth]) case_part(board_width+3, board_height, board_radius, case_depth, case_enlargement=1);
        // click closing edge
        //translate([2-.25, 2.5-.25, 13]) case_bottom_part(board_width+3, board_height, board_radius, 3, case_enlargement=1.50);
        translate([2-.5, 2-.5, 11]) case_part(board_width+3, board_height, board_radius, 2, case_enlargement=2);
     }
    // rests without screw holes
    translate([100*mil+3+2.5, 200*mil+2.5, 0]) cylinder(r=1.5, h=4);
    translate([100*mil+3+2.5, 1200*mil+2.5, 0]) cylinder(r=1.5, h=4);
    // rests with screw holes
    translate([2350*mil+3+2.5, 200*mil+2.5, 0]) cylinder(r=1.4, h=6);
    translate([2350*mil+3+2.5, 1200*mil+2.5, 0]) cylinder(r=1.4, h=6);
    translate([2350*mil+3+2.5, 200*mil+2.5, 0]) cylinder(r=4, h=4);
    translate([2350*mil+3+2.5, 1200*mil+2.5, 0]) cylinder(r=4, h=4);

}

module case_top(board_width, board_height, board_radius) {
    enlargement=5;
    case_depth=9;
    depth=2;
    union(){
        difference() {
            case_part(board_width+3, board_height, board_radius, case_depth, case_enlargement=enlargement);
            // main cutout
            translate([2, 2, -depth])
                case_part(board_width+3, board_height, board_radius, case_depth, case_enlargement=1);
            // edge cutout for temp sensor (rectangular)
            translate([board_width-3, (board_height+enlargement-15.75)/2, 0]) cube([8.25, 15.75, 20]);
           // edge cutout for micro USB connector
            translate([-5, (board_height+enlargement-8)/2, -.5]) cube([15, 8, 7]);
            // punch hole for BOOT
            translate([7, 12, 4]) cylinder(r=0.75, h=6);
            // label for BOOT
            translate([9, 16, 8.8]) rotate([0, 0, 270])
            linear_extrude(height = 1) {
                text(text = "BOOT", font = font, size = font_size);
            }
            // punch hole for EN
            translate([7, board_height+enlargement-12, 4]) cylinder(r=0.75, h=6);
            // label for EN
            translate([9, 30.5, 8.8]) rotate([0, 0, 270])
            linear_extrude(height = 1) {
                text(text = "EN", font = font, size = font_size);
            }

            // view hole for LED1
            translate([25, 17, 2.8]) cylinder(r=1.5, h=6);
            // label for LED1 
            translate([24, 14, 8.8]) rotate([0, 0, 270])
            linear_extrude(height = 1) {
                text(text = "LED", font = font, size = font_size);
            }
            
            // view hole for LED2
            translate([25, board_height+enlargement-17, 2.8]) cylinder(r=1.5, h=6);
            // label for LED2
            translate([24, 36.5, 8.8]) rotate([0, 0, 270])
            linear_extrude(height = 1) {
                text(text = "POWER", font = font, size = font_size);
            }

            // label for module title
            translate([45, 28.5, 8.8]) rotate([0, 0, 270])
            linear_extrude(height = 1) {
                text(text = "ESP32", font = font, size = 2*font_size);
            }

        }
        // stands for ESP32 module
        translate([6, 7.5, 3]) cylinder(r=1.5, h=5.5);
        translate([6, board_height+enlargement-7.5, 3]) cylinder(r=1.5, h=5.5);
        translate([52, 7.5, 3]) cylinder(r=1.5, h=5.5);
        translate([52, board_height+enlargement-7.5, 3]) cylinder(r=1.5, h=5.5);
    }

    difference() {
        difference() {
            union() {
                translate([2, 2, -3.5]) case_part(board_width+3, board_height, board_radius, case_depth, case_enlargement=1);
                translate([1.5, 1.5, -3]) case_part(board_width+3, board_height, board_radius, 1, case_enlargement=2);
            }
            translate([3, 3, -4]) case_part(board_width+3, board_height, board_radius, case_depth+3, case_enlargement=-1);
        }
        // cutout for ESP board
        translate([2, (board_height+enlargement-28)/2, -5]) cube([15, 28, 17]);        
        translate([0, (board_height+enlargement-28)/2, -5]) cube([15, 28, 8]);
        // edge cutout on left corner (rectangular)
        translate([board_width+3-board_radius, board_height-board_radius, -4])
            cube([board_radius*1.8, board_radius*1.8, 20]);
        // edge cutout on right corner (rectangular)
        translate([board_width+3-board_radius, 0, -4])
            cube([board_radius*1.8, board_radius*1.8, 20]);
    }
}

// Rendering the modules

//translate([-3, 4, 12.5]) color("lightblue") esp32(esp32_width, esp32_height, esp32_depth, esp32_pinheader_depth);
//addon_board(addon_width, addon_height, addon_depth, edge_radius);
//    translate([2350*mil, 0, -addon_depth]) cube([50,50,30]);
//    translate([0, 0, -addon_depth]) cube([100*mil,50,30]);

translate([-5.5, -2.5, -3.5]) color("lightgreen") case_bottom(addon_width, addon_height, edge_radius);
translate([-5.5, -12.5, 5.5]) color("lightgreen") rotate([180, 0, 0]) case_top(addon_width, addon_height, edge_radius);