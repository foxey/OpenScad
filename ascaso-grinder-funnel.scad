$fn=192;

//Outer diameter that fits in the piston
D1=59;
//Angle of bottom part
A=(72-59)/20;
//Wall width at the top
H1=.5;
//Wall width in the middle
H2=1;
//Wall width at the bottom
H3=2;

module bottom(height) {
    difference(){
        D2=D1+A*height;
        cylinder(d1=D2, d2=D1,h=height);
        cylinder(d1=(D2-2*H3), d2=(D1-2*H2),h=height);
    }
}

module top(height) {
    difference(){
        cylinder(d=D1,h=height);
        cylinder(d1=(D1-2*H2), d2=(D1-2*H1),h=height);
    }
}

module funnel(bottom_height, top_height) {
    union(){
        bottom(bottom_height);
        translate([0,0,bottom_height]) top(top_height);
    }
}

funnel(25,10);