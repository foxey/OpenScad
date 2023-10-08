
$fn=64;
difference(){
    union() {
        cylinder(d1=12, d2=17, h=4);
        translate([0, 0, 4]) cylinder(d=15.4, h=4);
    }
    union() {
        d=8.4;
        translate([0,0,-.1])cylinder(d=d, h=4.2);
        translate([0, 0, 4]) cylinder(d1=d, d2=13, h=4.2);
    }
}