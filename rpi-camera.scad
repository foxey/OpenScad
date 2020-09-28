// Raspberry Pi Camera - OpenSCAD
//
// https://github.com/larsch/openscad-modules/blob/master/rpi-camera.scad
//
// License: CC BY-SA 2.0
// https://creativecommons.org/licenses/by-sa/2.0/legalcode
//
// This case was designed for the Rasperry Pi 1 Model B, because that
// the one i had lying around for this project. I power it via the pin
// header 5V pin using a DC-DC buck converter and an external 9V DC
// power supply. The camera ribbon cable is slighly skewed inside the
// case, because I wanted the case to be small and it doesn't line up
// well.

fn_mounts = 16;
fn_camera = 32;

pcb_height = 1;

wall_thickness = 2;

pcb_guide_diameter = 1.5;
pcb_guide_height = pcb_height+.5;
camera_height = 3.25;
lens_hole_diameter = 8.5;

module rpi_camera() {
     color("darkblue")
	  difference() {
          cube([24,25,1]);
          translate([2,2,-1]) cylinder(d=2,h=3,$fn=fn_mounts);
          translate([2,23,-1]) cylinder(d=2,h=3,$fn=fn_mounts);
          translate([14.5,2,-1]) cylinder(d=2,h=3,$fn=fn_mounts);
          translate([14.5,23,-1]) cylinder(d=2,h=3,$fn=fn_mounts);
     }
     color("DimGray") union() {
          translate([10.25,8.5,1]) cube([8,8,3.25]);
          translate([10.25+4,12.5,1+3.25]) cylinder(d=7.5,h=1,$fn=fn_camera);
          translate([10.25+4,12.5,1+3.25+0.7]) cylinder(d=5.5,h=0.7,$fn=fn_camera);
     }
     color("orange") translate([1.75,8.625,1]) cube([8.5,7.75,1.5]);
     color("brown") translate([24-5.75,2.75,-2.75]) cube([4.5,19.5,2.75]);
     color("black") translate([22.75,2,-2.75]) cube([1.25,21,2.75]);
     color("grey") translate([24,4.25,-1]) cube([10,16.5,0.1]);
}

module pcb_guide(diameter, height) {
    translate([0, 0, -height])
        cylinder(d=diameter,h=3,$fn=fn_mounts);
    translate([0, 0, 0])
        cylinder(d=diameter*2,h=camera_height,$fn=fn_mounts);
}

module prism(l, w, h){
       polyhedron(
               points=[[0,0,0], [l,0,0], [l,w,0], [0,w,0], [0,w,h], [l,w,h]],
               faces=[[0,1,2,3],[5,4,3,2],[0,4,5,1],[0,3,4],[5,2,1]]
               );  
       }
   
module pcb_clip(width, height, thickness) {
    union() {
    cube([thickness, width, height]);
    wedge=1.6*thickness;
    rotate([0, 0, 90]) translate([0,-wedge,0]) prism(width,wedge,1.5*wedge);
    }
}

module rpi_camera_mount() {
    color("lightblue") {
        thickness = 1;
        translate([-thickness, -thickness, camera_height]) {
            difference() {
                cube([24+2*thickness,25+2*thickness,wall_thickness]);
                translate([10.25+4+thickness,12.5+thickness,-4])
                    cylinder(d=lens_hole_diameter,h=10,$fn=fn_camera);
            }
        }
        translate([2,2,0]) pcb_guide(pcb_guide_diameter, pcb_guide_height);
        translate([2,23,0]) pcb_guide(pcb_guide_diameter, pcb_guide_height);
        translate([14.5,2,0]) pcb_guide(pcb_guide_diameter, pcb_guide_height);
        translate([14.5,23,0]) pcb_guide(pcb_guide_diameter, pcb_guide_height);
        translate([23,12.5,0]) cylinder(d=2*pcb_guide_diameter, camera_height, $fn=fn_mounts);
         height = camera_height+pcb_height+1;
        translate([10.5, -thickness, camera_height-height]) rotate([0, 0, 90])
            pcb_clip(5, height, thickness);
        translate([10.5-5, 25+thickness, camera_height-height]) rotate([0,0,-90])
            pcb_clip(5, height, thickness);
        translate([25, -thickness, camera_height-height]) rotate([0, 0, 90])
            pcb_clip(5, height, thickness);
        translate([25-5, 25+thickness, camera_height-height]) rotate([0,0,-90])
            pcb_clip(5, height, thickness);
        translate([-1, 10, camera_height-height])
            pcb_clip(5, height, thickness);

    }

}

{
//  translate([0,0,-pcb_height]) rpi_camera();
    translate([0,0,01*(camera_height+pcb_height)])
        rotate([180,0,0])
        rpi_camera_mount();


}