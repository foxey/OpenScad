$fa = 2;
$fs = 0.25;
TOL = .1;
flap_depth = 4;

module m3nut(height, rotate=0) {
    $fn=6;
    rotate([0,0,rotate]) cylinder(d=6.2,h=height);
}

module flap(width)
{
	rotate([90, 0, 0])
	union() {
		translate([3.5, -7.5, 0])
			cube([4 + flap_depth, 15, width]);
		translate([0, -7.5, 0])
			cube([7.5 + flap_depth, 4, width]);

		translate([0, 3.5, 0])
			cube([7.5 + flap_depth, 4, width]);

		difference()
		{
			cylinder(h = width, d = 15);

			translate([0, 0, (-1)])
				cylinder(h = width + 2, d = 6);
		}
	}
}

module mount() {
	union()	{
		width = 3;
		translate([0, width, 0]) flap(width);
		translate([0, 2*width + 3.5, 0]) flap(width);
	}
}

module plate() {
	difference() {
		height = 32;
		depth = 15;
		union() {
			hull() {
				translate([-4.75, 0, 0]) cylinder(h = 3, r = 1);
				translate([4.75, 0, 0]) cylinder(h = 3, r = 1);
				translate([0, height, 0]) cylinder(h = 3, r = 10.5);
			}
			translate([0, height, 0]) cylinder(h = depth, r = 10.5);
			translate([0, height + 10.5, depth/2]) rotate([90, 0, 0]) cylinder(h = 6 + 2*TOL, d = 6);;
		}
		translate([0, height, -TOL]) cylinder(h = depth + 2*TOL, r = 5.5);
		translate([0, height + 10.5 - 5 + 2.5, depth/2]) rotate([90, 0, 0]) m3nut(5);
		translate([0, height + 10.5 + TOL, depth/2]) rotate([90, 0, 0]) cylinder(h = 6 + 2*TOL, d = 3.5);;
	}
}


translate([3 + 3.5/2, 15/2 - 1, 7.5 + flap_depth])
	rotate([0, 90, 90])
		mount();
plate();

