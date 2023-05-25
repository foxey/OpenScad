$fn=32;
difference() {
    cylinder($fn=6, h=19, d=26);
    translate([0,0,-1]) cylinder(h=21, d=3);
}