// Configurable Settings
th = 1;

h_terminal_neg = 5;
h_terminal_pos = 1.5;
// FYI:
// h_AA_battery = 50.5;
// r_AA_battery = 14.5/2;
// r_18650_battery = 18/2;
// h_18650_battery = 65;
h_battery = 50.5;
r_battery = 14.5/2;
w_wire_canister = 2;
_h_cap_canister = 20;
h_cap_plug = 10;

r_led_star = 16/2;
r_led_lens = 18/2;
h_led_lens_support_wall = 1;

l_rocker_switch = 20+1;  // +1 for waterproofing silicone sheet .5mm thick
w_rocker_switch = 13+1;
h_rocker_switch = 12.25;

// Derived settings
ri_canister = r_battery + .3;
ro_canister = ri_canister + th;
h_canister = h_battery + h_terminal_neg + h_terminal_pos;
h_canister_extension = w_wire_canister+th+h_cap_plug;

final_height = h_canister_extension*2-th*2+h_canister;

ro_cap_canister = ro_canister+th;
ri_cap_canister = ro_canister+.2;
h_cap_canister = min(h_canister/2, _h_cap_canister);

xyz_between_leds = [
0,-(ro_canister+w_wire_canister),final_height/2];
z_between_leds = max(th, h_canister-4*r_led_lens-2*th);

h_led_cutout = abs(xyz_between_leds[1]);
z_led_cutout = (h_canister_extension-th)+h_led_cutout+1;

module AAx2_canister() { // make me
  difference(){
    // build outer shell
    hull($fn=150) {
      for (sn=[-1,1])
        translate([sn*ri_canister, 0, 0])
          cylinder(r=ro_canister, h=h_canister);
    }
    // cut out space for batteries
    for (sn=[-1,1])
      translate([sn*ri_canister, 0, -.05])
        cylinder(r=ri_canister, h=h_canister+.1, $fn=100);
    // cut out middle section
    translate([-r_battery/2, -r_battery/2, -.05])
      cube([r_battery, r_battery, h_canister+.1]);
    // cutout space for wires
    for (sn2=[0,1]) for (sn=[0, 1]) {
      translate([0, 0, sn2*(h_canister)])

        rotate([0, sn2*180, 0])
        rotate([0, sn*180, 0])
        translate([
            ri_canister/2,
            ri_canister,
            -(2*sn-1)*.5*(w_wire_canister-.1)])
        rotate([0, 90, 90+atan((ri_canister*.5-w_wire_canister) / ro_canister)])
        cube([
            .1+w_wire_canister,
            w_wire_canister,
            sqrt(pow(ro_canister,2) + pow(ri_canister,2))
            ], center=true);
      translate([-ri_canister/2,
          ro_canister-w_wire_canister+.1,
          sn*(h_canister-w_wire_canister)+(2*sn -1)*.1])
        cube([ri_canister, w_wire_canister, w_wire_canister+.1]);
    }
  }
}


module AAx2_canister_cap(h=h_cap_canister) { // make me
  difference(){
    hull() {
      translate([+ri_cap_canister, 0, 0])
        cylinder(r=ro_cap_canister, h=h);
      translate([-ri_cap_canister, 0, 0])
        cylinder(r=ro_cap_canister, h=h);
    }
    hull($fn=150) {
      translate([+ri_canister, 0, th])
        cylinder(r=ri_cap_canister, h=h);
      translate([-ri_canister, 0, th])
        cylinder(r=ri_cap_canister, h=h);
    }
  }

}


module _cap(smaller_by, r, h=h_cap_plug) {
  hull($fn=150) {
    translate([+ri_canister, 0, 0])
      cylinder(r2=r, r1=r-smaller_by, h=h);
    translate([-ri_canister, 0, 0])
      cylinder(r2=r, r1=r-smaller_by, h=h);
  }
}
module AAx2_cap_plug(smaller_by=.5) {  // make me
  _cap(smaller_by, r=ri_cap_canister);
  // little hands-friendly handle
  translate([0, 0, h_cap_plug])
    minkowski() {
      scale([2.5, 1, 1])cylinder(r2=ri_cap_canister-2, r1=ri_cap_canister/2, h=10);
      rotate([90, 0, 0])cylinder(r=2,h=1, $fn=30);
    }
}


module _cap_rocker(h){
  union(){
    _cap(smaller_by=.5, r=ro_cap_canister, h=h);
    difference(){
      _v1_curved_outer_shell();
      translate([-2*ro_cap_canister,ro_cap_canister-10,0])
        cube([4*ro_cap_canister, 10, final_height]);
      translate([0, 0, h+final_height/2])
        cube([4*ro_cap_canister, 3*ro_cap_canister, final_height], center=true);
    }
  }
}


module AAx2_cap_rocker_switch(){  // make me
  h=max(h_cap_plug,h_rocker_switch);
  difference(){
    scale([1+2*th/(4*ro_cap_canister), 1+2*th/(2*ro_cap_canister), 1])_cap_rocker(h);
    translate([0,0,max(0,h_rocker_switch-h_cap_plug)]) _cap_rocker(h);
    // cut out space for rocker switch
    translate([0,0,h/2])
      cube([l_rocker_switch, w_rocker_switch, h+1], center=true);//h_cap_plug+1], center=true);
  }
}


module battery_terminal_insert() {  // make me
  difference(){
    hull(){
      translate([-ri_canister,0,0])cylinder(r=ri_canister,h=.5);
      translate([ri_canister,0,0])cylinder(r=ri_canister,h=.5);
    }
    translate([2*ri_canister-3,-3/2,-.25])
      cube([3,3,1]);
    translate([0,ri_canister-3,-.25])
      cube([ri_canister,3+.1,1]);
  }
}


module _extension(holes=true) {
  difference(){
    hull($fn=150) {
      translate([+ri_canister, 0, 0])
        cylinder(r=ro_cap_canister, h=h_canister_extension);
      translate([-ri_canister, 0, 0])
        cylinder(r=ro_cap_canister, h=h_canister_extension);
    }
    hull($fn=150) {
      translate([+ri_canister, 0, -.1])
        cylinder(r=ro_canister, h=h_canister_extension+.2);
      translate([-ri_canister, 0, -.1])
        cylinder(r=ro_canister, h=h_canister_extension+.2);
    }

    if(holes) {
      // wire holes through to the outside for pcb (need to waterproof)
      _extension_wire_holes_cutout();

    }
  }
}


module _extension_wire_holes_cutout() {
  for(sn=[-1,1])
    translate([sn*ri_canister/2-sn*w_wire_canister/2,
        -ro_canister-w_wire_canister/2, h_canister_extension-th+w_wire_canister/2]) {
      // vertical
      cylinder(r=w_wire_canister/2, h=w_wire_canister+r_led_lens, $fn=25);
      // horizontal
      translate([0, w_wire_canister/2+.1, 0]) rotate([90, 0, 0])
        cylinder(r=w_wire_canister/2, h=w_wire_canister+.1, $fn=25);
      // angled (for easier insertion and to remove the L shape)
      translate([0, w_wire_canister/2+.1, 0]) rotate([90-45, 0, 0])
        cylinder(r=w_wire_canister/2, h=w_wire_canister, $fn=25);
      /* } */
}
}


module _led_cutout() {
  /* z = h_cap_plug+w_wire_canister; */
  rotate([90,0,0]) {
    translate([0,0,w_wire_canister+th])
      cylinder(r=r_led_lens, h=h_led_cutout+h_led_lens_support_wall, $fn=100);
    cylinder(r=r_led_star, h=h_led_cutout, $fn=100);
  }
}


/* AAx2_canister_cap(); */
module AAx2_canister_shell(version=1) {  // make me

  /* h_electronics = h_canister+h_cap_plug; */
  /* AAx2_canister_cap(h=h_electronics); */
  translate([0, 0, h_canister_extension-th])
    AAx2_canister();
  // extend the top of canister with a "shell" that the plug can fit in
  translate([0, 0, h_canister+2*h_canister_extension-2*th])rotate([180, 0, 0])
    _extension(holes=false);
  // extend the bottom of the canister but don't add holes
  rotate([180, 180, 0]) _extension(holes=true);
  if (version == 1){
    /* translate([0,th,0]) */
    _v1();
  }
}


module _v1_curved_outer_shell() {
  union(){
    translate(xyz_between_leds)
      hull(){
        cube([th*2+w_wire_canister*2, th*2+w_wire_canister*2, z_between_leds],
            center=true);
        translate([0, w_wire_canister+th/2, 0])
          cube([ro_canister*3, th, z_between_leds], center=true);
      }
    translate([0, ro_canister/-2, final_height/2])
      scale([2, 1, 1])cylinder(r=ro_canister, h=final_height, center=true, $fn=100);
  }
}


module _v1() {
  // add curved space where I'll attach led strip
  rotate([0, 0, 180]) {
    difference(){
      union(){
        _v1_curved_outer_shell();
        // also add extra support for the led's glass lens
        for (sn=[0,1])
          translate([0, -ro_canister, sn*final_height - (2*sn-1)*z_led_cutout])
            rotate([90,0,0])
            cylinder(
                r=r_led_lens+th,
                h=w_wire_canister+th+h_led_lens_support_wall, $fn=100);
      }
      translate([0, 0, h_canister-1])hull(){AAx2_canister();}
      translate([0, 0, 0])hull(){AAx2_canister();}
      translate([0, 0, -h_canister+1])hull(){AAx2_canister();}

      // cutout the top led hole (and give wire holes leading to it)
      _extension_wire_holes_cutout();

      // cutout spaces for the led star and led lens
      for (sn=[0,1])
        translate([0, -ro_canister, sn*final_height - (2*sn-1)*z_led_cutout])
          _led_cutout();

      // a space between the 2 led holes where wires can travel
      translate(xyz_between_leds)
        cube([w_wire_canister*2, w_wire_canister*2, z_between_leds],
            center=true);
    }
  }
}

// TODO: v2 using boost converter and 12v led tape
// mounts for circuit board
/* module _v2() { */
/* x=20; */
/* y=10; */
/* z=40; */
// mimic the circuit board
// TODO: dimensions!
/* translate([x/2, ro_canister, h_canister-w_wire_canister-th]) { */
/* rotate([0, 180, 0])%cube([x, y,z]); */
// put circuit board encasing
/* } */
/* } */


// Visualize the modules below

// Simplest version
/* translate([100, 0, 0]) { */
/* translate([0, ro_canister*2 + 10, 0]) { */
/* AAx2_canister_cap(); */
/* translate([0, ro_cap_canister*2+10, 0]) */
/* AAx2_canister(); */
/* } */
/* } */

// Complex version
/* translate([0, -ro_cap_canister*2-10, 0])     */
/*   [> translate([0,0,-11]) <]                 */
/*   rotate([0,0,180])AAx2_cap_rocker_switch(); */

/*   AAx2_canister_shell(version=1);            */

/* translate([0,ro_cap_canister*3,0])           */
/*   battery_terminal_insert();                 */

/* translate([0, ro_cap_canister*6, 0])         */
/*   AAx2_cap_plug();                           */
