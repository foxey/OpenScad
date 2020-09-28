$fn=60;
difference() {
    union() {
        cylinder(d=30,h=15);
        cylinder(d=34,h=1.5);
        translate([0,0,14]) cylinder(d=34,h=1.5);
    }
    translate([0,0,-1]) cylinder(d=21,h=20);
    translate([-25,0,-1]) cube([50,50,50]);
}