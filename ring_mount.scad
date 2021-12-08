// Ring doorbell mount
// - Makes the doorbell plumb when mounted on 5.7° siding
// - Angles the doorbell forward 45°, for mounting on the side wall next to the front door
// - Uses the existing doorbell's mounting holes

siding_angle = 5.7; // degrees
view_angle = 45; // degrees

show_bell = false; // optionally show the dummy Ring doorbell body for debugging
wall = 0.05; // inches, wall thickness

$fn = 500; // use fine gradations on curved surfaces
epsilon = 0.01; // handy fudge factor for ensuring through-holes

thickener = 0.7; // fudge factors for getting the right amount of body thickness
thickener_fudge = 0.6;

// Measurements
ring_height = 3.89; // inches
ring_width = 1.72;
ring_depth = 0.7;
ring_back_radius = 0.14;
ring_screw_diameter = 0.1;
ring_screw_length = 0.26;
ring_screw_edge_offset = 0.121;
ring_screw_body_width = ring_screw_diameter + (wall * 2);
ring_screw_body_length = ring_screw_length * 1.3;
frame_height = ring_height + (2 * wall);
frame_width = ring_width + (2 * wall);
frame_wire_hole_diameter = 1;
frame_screw_spacing = 3.545;
frame_screw_diameter = 0.14;
frame_screw_body_width = frame_screw_diameter + (wall * 4);
frame_screw_body_length = 0.1;
frame_screw_access_diameter = frame_screw_diameter + (wall * 1.6);

// The mounting and wiring holes aren't centered
frame_hole_x_offset = .02;
frame_hole_y_offset = -0.11;

module bell() {
    translate([wall, ring_back_radius-ring_depth, wall]) {
      cube(size= [ring_width, ring_depth - ring_back_radius, ring_height]);
      translate([ring_back_radius, ring_depth - (ring_back_radius + epsilon), 0])
        cube(size= [ring_width - (2 * ring_back_radius), ring_back_radius + epsilon, ring_height]);
      translate([ring_back_radius, ring_depth - ring_back_radius, 0])
        cylinder(r=ring_back_radius, h=ring_height);
      translate([ring_width - ring_back_radius, ring_depth - ring_back_radius, 0])
        cylinder(r=ring_back_radius, h=ring_height);
    }
}

module screw_hole() {
  rotate([-90, 0, 0])
    translate([0, 0, -epsilon])
      cylinder(d=ring_screw_diameter, h=ring_screw_body_length + (2 * epsilon));
}

module screw_mount() {
  difference() {
    union() {
      rotate([-90, 0, 0])
        cylinder(d=ring_screw_body_width, h=ring_screw_body_length);
      translate([-(ring_screw_body_width / 2), 0, -ring_screw_edge_offset])
        cube([ring_screw_body_width, ring_screw_body_length, ring_screw_edge_offset]);
    }

    screw_hole();
  }
}

module screw_holes() {
  translate([frame_width / 2, ring_back_radius, ring_screw_edge_offset + wall])
    screw_hole();
  translate([frame_width / 2, ring_back_radius, frame_height - (ring_screw_edge_offset + wall)])
    rotate([0, 180, 0])
      screw_hole();
}

module front_frame() {
  difference() {
    union() {
      // outer box & front wall
      translate([-thickener, 0, 0]) {
        rotate_extrude(angle = view_angle) {
          translate([thickener, 0, 0]) {
            square([wall, frame_height]);
            square([frame_width, wall]);
            translate([0, frame_height - wall, 0])
              square([frame_width, wall]);
          }
          translate([thickener + frame_width - wall, 0, 0])
            square([wall, frame_height]);
        };
      };

      // panel behind ring
      difference() {
        cube([(frame_width - wall) + epsilon, wall + ring_back_radius,  frame_height - epsilon]);

        translate([frame_width / 2, wall + ring_back_radius + epsilon, frame_height * 0.17])
          rotate([90, 0, 0])
            scale([0.7, 0.3])
              cylinder(d=frame_width, h=wall+(2*epsilon));

        translate([frame_width / 2, wall + ring_back_radius + epsilon, frame_height * 0.375])
          rotate([90, 0, 0])
            scale([0.7, 0.4])
              cylinder(d=frame_width, h=wall+(2*epsilon));


        translate([frame_width / 2, wall + ring_back_radius + epsilon, frame_height * 0.6])
          rotate([90, 0, 0])
            scale([0.7, 0.4])
              cylinder(d=frame_width, h=wall+(2*epsilon));

        translate([frame_width / 2, wall + ring_back_radius + epsilon, frame_height * 0.83])
          rotate([90, 0, 0])
            scale([0.7, 0.4])
              cylinder(d=frame_width, h=wall+(2*epsilon));
      }

      // ring attach screws
      translate([frame_width / 2, ring_back_radius, ring_screw_edge_offset + wall])
        screw_mount();
      translate([frame_width / 2, ring_back_radius, frame_height - (ring_screw_edge_offset + wall)])
        rotate([0, 180, 0])
          screw_mount();
    }

    bell();
    screw_holes();
  }
}

rotate([-90, 0, 0]) { // [-90, 0, 0] for printing
  frame_mount_x = (wall + (frame_width - frame_wire_hole_diameter)) + frame_hole_x_offset;

  translate([0, -wall, 0]) {
    difference() {
      union() {
        // front frame / sides / top / bottom
        translate([0, thickener * thickener_fudge, 0])
          rotate([siding_angle, 0, 0]) {
            translate([-thickener, wall, 0])
              rotate([0, 0, -view_angle])
                translate([thickener, 0, 0])
                  union() {
                    if (show_bell) %bell();
                    front_frame();
                  };

            rotate([180, 0, 0])
              translate([frame_width * 0.6, 0.5, 0])
                linear_extrude(0.02)
                  text("♥", size=0.6);

          }

        // upper frame screw body
        translate([0, 0, (frame_height / 2) + (frame_screw_spacing / 2) - frame_screw_body_width])
          cube([frame_width, wall, frame_height - frame_screw_spacing + wall]);
        translate([frame_mount_x, 0, (frame_height / 2) + (frame_screw_spacing / 2) + frame_hole_y_offset])
          rotate([90, 0, 0])
            cylinder(d=frame_screw_body_width, h=frame_screw_body_length);

        // lower frame screw body
        difference() {
          union() {
            translate([-0.1, 0, -epsilon])
              cube([frame_width + 0.05, wall, frame_screw_body_width * 1.25]);
            translate([frame_mount_x, 0, (frame_height / 2) - (frame_screw_spacing / 2) + frame_hole_y_offset])
              rotate([90, 0, 0])
                cylinder(d=frame_screw_body_width, h=frame_screw_body_length);
          }
          translate([(frame_width - frame_screw_body_width - wall) / 2, -(frame_screw_body_length + wall), -frame_screw_body_width])
             cube([frame_screw_body_width, wall * 4, frame_screw_body_width]);
        }
      }

      union() {
        // upper frame screw hole
        translate([frame_mount_x, wall + epsilon, (frame_height / 2) + (frame_screw_spacing / 2) + frame_hole_y_offset])
          rotate([90, 0, 0])
            cylinder(d=frame_screw_diameter, h=wall + frame_screw_body_length + (2 * epsilon));

        // upper frame screw access hole
        translate([frame_mount_x, -(frame_screw_body_length + (wall * 2)), (frame_height / 2) + (frame_screw_spacing / 2) + frame_hole_y_offset])
          rotate([90, 0, 0])
            cylinder(d=frame_screw_access_diameter, h=frame_width);

        // lower frame screw hole
        translate([frame_mount_x, wall + epsilon, (frame_height / 2) - (frame_screw_spacing / 2) + frame_hole_y_offset])
          rotate([90, 0, 0])
            cylinder(d=frame_screw_diameter, h=wall + frame_screw_body_length + (2 * epsilon));

        // lower frame screw access hole
        translate([frame_mount_x, -(frame_screw_body_length + (wall * 2)), (frame_height / 2) - (frame_screw_spacing / 2) + frame_hole_y_offset])
          rotate([90, 0, 0])
            cylinder(d=frame_screw_access_diameter, h=frame_width);

        // back wiring hole
        translate([frame_mount_x, wall + epsilon, (frame_height / 2) + frame_hole_y_offset])
          rotate([90, 0, 0])
            cylinder(d=frame_wire_hole_diameter, h=wall + (2 * epsilon));

        // back cutoff
        translate([-thickener, wall, -wall])
          cube([frame_width + thickener + wall, thickener * thickener_fudge, frame_height + wall]);
      }
    }
  }
}
