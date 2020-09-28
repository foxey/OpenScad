$fn=80;
HEIGHT=3;
SPLIT=.666;
difference() {
    union() {
        
        cylinder(d=18, h=SPLIT*HEIGHT);
        translate([0,0,SPLIT*HEIGHT])
            cylinder(d1=18,d2=14,h=(1-SPLIT)*HEIGHT);
    }
    cylinder(d1=3,d2=6.5,h=HEIGHT);
}