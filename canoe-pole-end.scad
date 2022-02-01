$fn=72*1.5;
D_OUT=22;
D_IN=19.5;
WALL=2;
HEIGHT=16;
ARC=10;

module cap(extend=0){
    difference(){
        cylinder(d=D_OUT+2*WALL, h=HEIGHT);
        cylinder(d=D_OUT, h=HEIGHT);
    }
    difference(){
        cylinder(d=D_IN, h=HEIGHT+extend);
        cylinder(d=D_IN-WALL*2, h=HEIGHT+extend);
    }
    cylinder(d=D_OUT+2*WALL, h=WALL);
}

module sector(radius, angles, fn = 24) {
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [r * cos(a), r * sin(a)]
        ],
        [[r * cos(angles[1]), r * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

module arc(size){
    rotate_extrude(angle=360){
        translate([-D_OUT/2-WALL-size,-WALL,0]){
            union(){
                translate([0,-size,0]){
                    difference(){
                        square(size,false);
                        sector(size, [0,90], 72);
                    }
                }
                square([D_OUT/2+WALL+size,WALL]);
            }
        }
    }
}

module cutout_arc(size){
    translate([0,0,HEIGHT]){
        difference(){
            arc(ARC);
            translate([0,0,-WALL]) cylinder(d=D_OUT+2*WALL,h=WALL);
        }
    }
}

union(){
    cutout_arc(ARC);
    cap();
}

//translate([50,0,0]) cap(5);