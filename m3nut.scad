nutOuterDiameter = 12;
m3NutDiameter = 5.6;
m3NutHeight = 3;
m3BoltShaftDiameter = 3;
m3ShaftHeight = 4;

$fn=50;

module nut_cutout() {
    difference() {
        cylinder(d=nutOuterDiameter,h=m3NutHeight);
        cylinder(d=m3NutDiameter*2/sqrt(3),h=1.1*m3NutHeight,$fn=6);
    }
}

module bolt_shaft() {
    difference() {
        cylinder(d=nutOuterDiameter,h=m3ShaftHeight);
        cylinder(d=m3BoltShaftDiameter,h=1.1*m3ShaftHeight);
    }
}

difference() {
    union() {
        height = m3NutHeight+m3ShaftHeight;
        translate([height/2-m3NutHeight,0,6]) rotate([0,90,0]) nut_cutout();
        translate([-height/2,0,6]) rotate([0,90,0]) bolt_shaft();
    }
    translate([-nutOuterDiameter,-nutOuterDiameter,-4])
        cube([2*nutOuterDiameter,2*nutOuterDiameter,5]);
}