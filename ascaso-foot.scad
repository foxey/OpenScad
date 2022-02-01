$fn=128;
difference(){
    union(){
        cylinder(d=40,h=4);
        translate([0,0,4]) cylinder(d1=40,d2=24,h=24);
     }
    translate([0,0,17]) cylinder(d=20,h=12);
}
translate([0,0,17]) cylinder(d1=6.5,d2=5,h=4); 
