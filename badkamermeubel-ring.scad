$fn=60;

module ring(){
    difference(){
        cylinder(d=9,h=2.5);
        cylinder(d=3,h=3.5);
    }
}

module slit(){
    translate([-1,0,0]) cube([2,10,4]);
}

difference(){
    ring();
    slit();
}