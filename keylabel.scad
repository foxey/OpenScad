$fn=36*4;

module keylabel(){
    difference(){
        cylinder(d=25.5,h=3.2);
        translate([0,-25.5/2+2.4+5.5,-.2])
            cylinder(d=4.9,h=3);
        translate([0,0,.4]) {
            cylinder(d=23.5,h=2.2);
            cylinder(d=23.0,h=3);
        }
        translate([-15,25.5/2-3.5,0])
            cube([30,30,30]);

    }
}

keylabel();
