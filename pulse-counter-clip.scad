$fn=64;
PC_DEPTH = 16; //pusle-counter-depth
PC_DEPTH_BOTTOM = .1;
PC_DEPTH_TOP = PC_DEPTH - 5;
PC_HEIGHT = 18;
PC_HEIGHT_BOTTOM = 15.5;
PC_WIDTH = 62;
PC_RADIUS = 1.5;
PCB_HEIGHT = 14.5;
PCB_HEIGHT_MIN = 13;
PCB_LED_DEPTH = 13;
WALL_THICKNESS = 1.5;
CLIP_DEPTH = 1;
CLIP_HEIGHT = 2;
CLIP_NOTCH_HEIGHT = 1;
CLIP_NOTCH_WIDTH = 10;
LED_NOTCH_WIDTH = 13.5;
LED_VIEWPORT_DEPTH = 1;
LED_VIEWPORT_WIDTH = 3;
LED_CLIP_BOTTOM_NOTCH_WIDTH=14.5;
CLIP_BOTTOM_NOTCH_WIDTH = 6.6;
CLIP_BOTTOM_NOTCH_HEIGHT = 2.2;
CLIP_BOTTOM_NOTCH_DEPTH = 3.5;
LED_LED_VIEWPORT_HEIGHT = 21;
BASE_HEIGHT = PC_HEIGHT + 1 + 2*CLIP_HEIGHT;
BASE_WIDTH = 32;
BASE_DEPTH = 2;
LED_X = 7;
LED_RADIUS = 5/2;
JACK_D = 6;
SCREW_D = 2;

clip_width=CLIP_NOTCH_WIDTH+2*CLIP_HEIGHT;
side_wall_thickness = (PC_HEIGHT-PCB_HEIGHT_MIN)/2;
width_tolerance=1;
depth_tolerance=.1;


module base(){
    cube([BASE_WIDTH,BASE_HEIGHT,BASE_DEPTH]);
}


module cutout(){
    cutout_width=BASE_WIDTH-2*LED_X-CLIP_HEIGHT;
    translate([BASE_WIDTH-cutout_width-CLIP_HEIGHT,2*CLIP_HEIGHT,-1])
        cube([cutout_width,BASE_HEIGHT-CLIP_HEIGHT*4,BASE_DEPTH+2]);
}


module cutout_small_top(){
    cutout_width=2*LED_X-2*CLIP_HEIGHT;
    cutout_height=LED_X-CLIP_HEIGHT+1.25;
    translate([CLIP_HEIGHT,BASE_HEIGHT-CLIP_HEIGHT-cutout_height,-1])
        cube([cutout_width,cutout_height,BASE_DEPTH+2]);
}


module cutout_small_bottom(){
    cutout_width=2*LED_X-2*CLIP_HEIGHT;
    cutout_height=LED_X-CLIP_HEIGHT-1.25;
    translate([CLIP_HEIGHT,CLIP_HEIGHT,-1])
        cube([cutout_width,cutout_height,BASE_DEPTH+2]);
}


module hole(x, y, h){
    translate([x+LED_X, y, 0]){
        translate([0,0,-.1]) cylinder(r=LED_RADIUS,h);
    }
}


module clip_base(){
    cube([clip_width,CLIP_HEIGHT,8]);
    translate([(clip_width-CLIP_NOTCH_WIDTH)/2+width_tolerance, 0, 5+3*depth_tolerance])
        cube([CLIP_NOTCH_WIDTH-2*width_tolerance, CLIP_HEIGHT+1, CLIP_DEPTH-2*depth_tolerance]);
}


module clip(orientation){
    if (orientation=="front") {
        translate([20-CLIP_HEIGHT,0,BASE_DEPTH])
            clip_base();
    }
    if (orientation=="back") {
        translate([20-CLIP_HEIGHT+clip_width,BASE_HEIGHT,BASE_DEPTH])
            rotate([0,0,180])
                clip_base();
    }
}


module pulse_counter_clip() {
    union(){
        difference(){
            base();
            cutout();
            cutout_small_top();
            cutout_small_bottom();
            y = (BASE_HEIGHT)/2-1.25;
            h = BASE_DEPTH+2;
            hole(0, y, h);
        }
        clip("front");
        clip("back");
    }
}


module pulse_counter_solid_base_square() {
    cube([PC_WIDTH, PC_HEIGHT,PC_DEPTH]);
}


module roundedcube(x,y,z) {
    for (delta_x = [PC_RADIUS, x-PC_RADIUS]) {
        for (delta_y = [PC_RADIUS, y-PC_RADIUS]) {
            translate([delta_x, delta_y, 0])
                cylinder(r=PC_RADIUS, h=z);
        }
    }
}


module pulse_counter_solid_base() {
    hull() {
        translate([0, (PC_HEIGHT-PC_HEIGHT_BOTTOM)/2, 0])
            roundedcube(PC_WIDTH, PC_HEIGHT_BOTTOM, PC_DEPTH_BOTTOM);
        translate([0, 0, PC_DEPTH-PC_DEPTH_TOP])
            roundedcube(PC_WIDTH, PC_HEIGHT, PC_DEPTH_TOP);
    }
}


module pulse_counter_base(y) {
    union() {
        difference() {
            pulse_counter_solid_base();
            pbc_cutout_narrow();
            pbc_cutout_wide();
        }
        difference() {
            translate([LED_X + LED_LED_VIEWPORT_HEIGHT, PC_HEIGHT/2, 0]) {
                screw_stand();
            }
            pbc_cutout_wide();
        }
    }
}


module notches(y_pc) {
    translate([0, -depth_tolerance, 0])
        cube([CLIP_NOTCH_WIDTH, CLIP_NOTCH_HEIGHT+depth_tolerance, 1]);
    translate([0, y_pc-CLIP_NOTCH_HEIGHT+depth_tolerance, 0])
        cube([CLIP_NOTCH_WIDTH, CLIP_NOTCH_HEIGHT+depth_tolerance, 1]);
}


module bottom_notch() {
    translate([0, 0, -depth_tolerance])
        cube([CLIP_BOTTOM_NOTCH_WIDTH, CLIP_BOTTOM_NOTCH_HEIGHT, CLIP_BOTTOM_NOTCH_DEPTH+2*depth_tolerance]);
}


module led_viewports(y_pc) {
    translate([0, -depth_tolerance, 0])
        cube([LED_VIEWPORT_WIDTH, side_wall_thickness+2*depth_tolerance, LED_VIEWPORT_DEPTH]);
    translate([0, y_pc-side_wall_thickness+depth_tolerance, 0])
        cube([3, side_wall_thickness+2*depth_tolerance, LED_VIEWPORT_DEPTH]);
}

module pbc_cutout_wide() {
    translate([WALL_THICKNESS, (PC_HEIGHT-PCB_HEIGHT)/2, PCB_LED_DEPTH])
        cube([PC_WIDTH-2*WALL_THICKNESS, PCB_HEIGHT, PC_DEPTH]);
}


module pbc_cutout_narrow() {
    translate([WALL_THICKNESS, (PC_HEIGHT-PCB_HEIGHT_MIN)/2, WALL_THICKNESS])
        cube([PC_WIDTH-2*WALL_THICKNESS, PCB_HEIGHT_MIN, PC_DEPTH]);
}


module jack() {
    rotate([0, 90, 0]) cylinder(d=JACK_D, h=2*WALL_THICKNESS, center=true);
}


module screw_stand() {
    difference() {
        cylinder(d=2.5*SCREW_D, h=PC_DEPTH);
        translate([0,0,-depth_tolerance])
            cylinder(d=SCREW_D, h=PC_DEPTH+2*depth_tolerance);
    }
}


module pulse_counter() {
    difference() {
        y_notch = (PC_HEIGHT - CLIP_BOTTOM_NOTCH_HEIGHT)/2;
        x_potmeter = 12.5;
        y_potmeter = PC_HEIGHT/2-LED_RADIUS;
        h = PC_DEPTH+2;
        pulse_counter_base(PC_HEIGHT);
        hole(0, PC_HEIGHT/2, h);
        hole(x_potmeter, y_potmeter, h);
        translate([LED_X + LED_NOTCH_WIDTH, 0, 0]) {
            translate([0, 0, 4.9])
                notches(PC_HEIGHT);
            translate([-.3, y_notch, 0])
                bottom_notch();
        }
        translate([LED_X+LED_LED_VIEWPORT_HEIGHT-LED_VIEWPORT_WIDTH/2, 0, PCB_LED_DEPTH-LED_VIEWPORT_DEPTH]) {
            led_viewports(PC_HEIGHT);
        }
        translate([PC_WIDTH-.1, PC_HEIGHT/2, JACK_D/2+2*WALL_THICKNESS]) jack();
    }
}


module pulse_counter_lid() {
    delta_x = WALL_THICKNESS + depth_tolerance;
    delta_y = (PC_HEIGHT-PCB_HEIGHT)/2 + depth_tolerance;
    led_pins_width = 2;
    x_potmeter = 12.5;
    y_potmeter = PC_HEIGHT/2-LED_RADIUS;
    potmeter_pins_width = 7;
    potmeter_pins_height = 5;
    translate([delta_x, delta_y, 0])
    difference() {
        cube([PC_WIDTH-2*delta_x, PCB_HEIGHT-2*depth_tolerance, WALL_THICKNESS]);
        translate([LED_X-delta_x-led_pins_width/2, (PC_HEIGHT-2*LED_RADIUS)/2-delta_y, 0])
            #cube([led_pins_width, 2*LED_RADIUS, 1]);
        translate([x_potmeter+LED_X-delta_x-potmeter_pins_width/2, y_potmeter-potmeter_pins_height/2-delta_y, 0])
            #cube([potmeter_pins_width, potmeter_pins_height, 1]);
        translate([LED_X+LED_LED_VIEWPORT_HEIGHT-delta_x, PC_HEIGHT/2-delta_y, -WALL_THICKNESS/2])
            cylinder(d=SCREW_D, h = 2*WALL_THICKNESS);
        translate([LED_X+LED_LED_VIEWPORT_HEIGHT-delta_x, PC_HEIGHT/2-delta_y, .5])
            cylinder(r=LED_RADIUS, h = 2*WALL_THICKNESS);
    }

}


//color("lightblue") pulse_counter_clip();
//translate([0, CLIP_HEIGHT+.5+depth_tolerance, BASE_DEPTH])
    pulse_counter();
translate([0, 0, PC_DEPTH+WALL_THICKNESS]) pulse_counter_lid();
//pulse_counter_solid_base();
//%pulse_counter_solid_base_square();