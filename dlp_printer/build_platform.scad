include <shared_vars.scad>;


module build_platform() {
translate([0, y_offset_build_platform, z_offset_build_platform]) {
  cylinder(r=r_platform, h=thickness_platform);
  // shaft connecting top to bottom
  cylinder(r=r_platform_shaft, h=h_platform_shaft);
  translate([0, 0, h_platform_shaft + z_platform_mount/2]) {
    difference() {
    // top mount connecting to z axis
        cube(xyz_platform_mount, center=true);
      // screw holes
      for (sign = [-1, 1])
      translate([0, sign * dist_between_platform_mount_screws/2, 0])
        cylinder(r=m3_bolt_radius, h=z_platform_mount + 1, center=true);
    }
  }
}
}

module rod_to_extrusion_stabilizing_mount() {
  difference() {
    union() {
      for (angle=[0, 180]) {
      rotate([angle, 0, 0])
      hull() {
        // part that attaches to rod
        translate([r_rod_holder, 0, z_offset_rod_holder])
          cylinder(r=r_rod_holder, h=h_rod_holder, center=true);
        // part that attaches to extrusion
        cube([.01, 2*r_rod_holder, 2*xy_extrusion], center=true);
      }
    }
    }
    // cutout spot for the lm8uu bearings
    translate([r_rod_holder, 0, 0])
      cylinder(r=r_lm8uu, h=2*(z_offset_rod_holder + h_rod_holder + thickness), center=true);
    // screw holes
    rotate([0, 90, 0])for (sign=[-1, 1])translate([sign*10, 0, 0])
      cylinder(r=m5_bolt_radius, h=2*r_rod_holder, center=true);
  }
}

module _tmp_extrusion_mount() {
  difference() {
      // small extension to wrap around extrusion
      translate([-length_rod_holder_flaps/2, 0, 0])
         cube([length_rod_holder_flaps+2*thickness,
               xy_extrusion+2*thickness,
               xy_extrusion+2*thickness],
               center=true);
    // cutout for extrusion
    translate([-x_offset_rod_holder - length_rod_holder_flaps/2, 0, 0]) {
      cube([x_offset_rod_holder + length_rod_holder_flaps, h_rod_holder, h_rod_holder + 1], center=true);
      // screw holes
      cylinder(r=m5_bolt_radius, h=h_rod_holder+thickness*2+1, center=true);
    }
  }
}

//cube([xy_extrusion, 100, 2*xy_extrusion], center=true);
//translate([xy_extrusion, 0, 0])
  //cylinder(r=8/2, h=50, center=true);
//translate([10, 0, 0])
  //rod_to_extrusion_stabilizing_mount();
