$fn=64;
CLIP_HEIGHT=3;
CLIP_NOTCH_WIDTH=10;
BASE_HEIGHT=19+2*CLIP_HEIGHT;
BASE_WIDTH=44;
BASE_DEPTH=10;
LED_X=7;
LED_RADIUS=6.5/2;

clip_width=CLIP_NOTCH_WIDTH+2*CLIP_HEIGHT;


module base(){
    cube([BASE_WIDTH,BASE_HEIGHT,BASE_DEPTH]);
}

module cutout(){
    cutout_width=BASE_WIDTH-2*LED_X-CLIP_HEIGHT;
    translate([BASE_WIDTH-cutout_width-CLIP_HEIGHT,CLIP_HEIGHT,-1])
    cube([cutout_width,BASE_HEIGHT-CLIP_HEIGHT*2,BASE_DEPTH+2]);
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

module led(){
    translate([LED_X,(BASE_HEIGHT)/2-1.25,0]){
        translate([0,0,1]) cylinder(r=LED_RADIUS,h=BASE_DEPTH);
        translate([0,0,-1]) cylinder(d=3.2,h=3);
    }
}

module clip_base(){
    width_tolerance=1;
    depth_tolerance=.1;
    cube([clip_width,CLIP_HEIGHT,8]);
    translate([(clip_width-CLIP_NOTCH_WIDTH)/2+width_tolerance,0,5+3*depth_tolerance])
        cube([CLIP_NOTCH_WIDTH-2*width_tolerance,CLIP_HEIGHT+1,1-2*depth_tolerance]);
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

union(){
    difference(){
        base();
        cutout();
        cutout_small_top();
        cutout_small_bottom();
        led();
    }
    clip("front");
    clip("back");
}
