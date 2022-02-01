$fn=36*4;
OUTER_DIAMETER=26.5;

module keylabel(){
    difference(){
        cylinder(d=OUTER_DIAMETER,h=3.4);
        translate([0,-OUTER_DIAMETER/2+2.4+5.5,-.2])
            cylinder(d=4.9,h=3);
        translate([0,0,.6]) {
            cylinder(d=23.5,h=2.2);
            cylinder(d=23.0,h=3);
        }
        translate([-15,OUTER_DIAMETER/2-4,0])
            cube([30,30,30]);

    }
}

keylabel();
