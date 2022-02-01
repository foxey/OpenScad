$fn=128+64;
difference() {
    cylinder(d=50,h=18);
    translate([0,0,-1]) cylinder(d=45,h=20);
    translate([0,0,9.3]) cylinder(d1=0,d2=50,h=9);
}