$fn=80;
DEPTH=36;
WIDTH=18;
HEIGHT=2;

angle=atan(HEIGHT/DEPTH);

module full_wedge(height) {
    rotate([90,0,0]) {
        linear_extrude(height=WIDTH) {
            polygon(points=[[0,0],[DEPTH,0],[0,height]]);
        }
    }
}

full_wedge(HEIGHT);