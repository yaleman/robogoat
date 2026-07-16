/*
  Narrow stair-capable tracked robot chassis
  ------------------------------------------
  Original parametric design inspired by the general layout of RCTestFlight's
  printed Snow Tank, but not derived from its STL geometry.

  Default target:
    overall width:       ~340 mm
    overall length:      ~505 mm
    track width:          55 mm
    track contact length: 390 mm
    sprocket pitch dia:  ~105 mm

  Designed around a 256 x 256 mm printer bed. Long frame rails and floor panels
  are split into printable halves.

  IMPORTANT:
    This is a mechanical layout / first prototype, not a validated drivetrain.
    The track hinge geometry, sprocket engagement, axle support and gearbox
    should be test-printed and load-tested before committing to a full build.

  Export parts by changing `part` below.
*/

$fn = 64;

// ---------- part selector ----------
part = "assembly";
// assembly, track_link, sprocket, idler, road_wheel,
// rail_front, rail_rear, crossmember, floor_front, floor_rear,
// motor_plate, gearbox_plate, dimensions

exploded = 0;          // 0 for normal assembly, 1 for mildly exploded
show_tracks = true;
show_motor_placeholders = true;
show_floor = true;

// ---------- primary envelope ----------
overall_width = 340;
track_width = 55;
track_gap = 8;
chassis_width = overall_width - 2 * (track_width + track_gap); // 214 mm

track_pitch = 30;
straight_link_count = 13;
wheelbase = track_pitch * straight_link_count;                 // 390 mm
sprocket_teeth = 11;
sprocket_pitch_radius = track_pitch / (2 * sin(180 / sprocket_teeth)); // chord-correct chain pitch radius

track_body_thickness = 8;
grouser_height = 4;
hinge_outer_d = 9;
hinge_pin_d = 3.2;
track_clearance = 0.35;

axle_z = 72;
track_path_radius = sprocket_pitch_radius;
track_bottom_z = axle_z - track_path_radius;
track_top_z = axle_z + track_path_radius;

rail_length = 450;
rail_height = 86;
rail_thickness = 10;
rail_bottom_z = 42;
rail_split_overlap = 20;

floor_thickness = 4;
floor_z = 48;
floor_half_length = 230;

crossmember_x = 28;
crossmember_z = 24;
crossmember_wall = 3;

main_axle_d = 8.2;
bearing_od = 22.2;    // 608 bearing slip-fit starting point; tune for material
bearing_depth = 7.2;
road_axle_d = 5.2;

road_wheel_radius = 35;
road_wheel_width = 14;
road_wheel_z = 57;
road_wheel_x = [-135, -45, 45, 135];

sprocket_body_radius = sprocket_pitch_radius - 9;
sprocket_width = 16;
sprocket_tooth_tangent = 11;
sprocket_tooth_radial = 13;
sprocket_tooth_width = 15;

motor_d = 42;
motor_length = 48;
motor_shaft_d = 8;

// ---------- helpers ----------
module rounded_rect_2d(size=[10,10], r=2) {
    offset(r=r)
        offset(delta=-r)
            square(size, center=true);
}

module rounded_box(size=[10,10,10], r=2, center=true) {
    translate(center ? [0,0,-size[2]/2] : [size[0]/2,size[1]/2,0])
        linear_extrude(height=size[2])
            rounded_rect_2d([size[0],size[1]], r);
}

module cyl_y(h, r, center=true) {
    rotate([90,0,0]) cylinder(h=h, r=r, center=center);
}

module bolt_circle_y(bcd=25, hole_d=3.3, count=4, depth=20, angle_offset=45) {
    for (a = [0 : 360/count : 359])
        translate([(bcd/2)*cos(a+angle_offset), 0, (bcd/2)*sin(a+angle_offset)])
            cyl_y(depth, hole_d/2, true);
}

// ---------- track link ----------
module track_link(detailed=true) {
    body_x = track_pitch - hinge_outer_d - 1.0;
    outer_knuckle_len = (track_width - 18) / 2;
    centre_knuckle_len = 18 - 2*track_clearance;
    barrel_r = hinge_outer_d/2;

    difference() {
        union() {
            // Main pad body
            translate([0,0,track_body_thickness/2])
                cube([body_x, track_width, track_body_thickness], center=true);

            // Grouser. Narrow enough not to foul the hinge barrels.
            translate([0,0,track_body_thickness + grouser_height/2])
                cube([track_pitch*0.58, track_width*0.86, grouser_height], center=true);

            if (detailed) {
                // Front: two outer knuckles
                for (sy = [-1,1])
                    translate([track_pitch/2,
                               sy*(track_width/2 - outer_knuckle_len/2),
                               barrel_r])
                        cyl_y(outer_knuckle_len, barrel_r, true);

                // Rear: central knuckle
                translate([-track_pitch/2, 0, barrel_r])
                    cyl_y(centre_knuckle_len, barrel_r, true);
            }
        }

        if (detailed) {
            // Hinge pin bores
            for (x = [-track_pitch/2, track_pitch/2])
                translate([x,0,barrel_r])
                    cyl_y(track_width + 2, hinge_pin_d/2, true);

            // Central drive pocket for sprocket tooth
            translate([0,0,-0.1])
                cube([sprocket_tooth_tangent + 1.2,
                      sprocket_tooth_width + 1.2,
                      track_body_thickness + 0.4], center=true);
        }
    }
}

module simple_track_link() {
    // Assembly-only envelope centred on the hinge path. The printable link above
    // carries the actual hinge barrels and outward-facing grouser.
    cube([track_pitch-1.0,
          track_width,
          track_body_thickness + grouser_height], center=true);
}

// Place simplified links around a capsule path in the X/Z plane.
module track_loop(y=0) {
    arc_links = round(PI * track_path_radius / track_pitch);

    // lower straight
    for (i = [0 : straight_link_count-1])
        translate([-wheelbase/2 + track_pitch/2 + i*track_pitch,
                   y,
                   track_bottom_z])
            simple_track_link();

    // upper straight
    for (i = [0 : straight_link_count-1])
        translate([wheelbase/2 - track_pitch/2 - i*track_pitch,
                   y,
                   track_top_z])
            rotate([0,180,0]) simple_track_link();

    // front arc, x positive
    for (i = [0 : arc_links-1]) {
        a = -90 + (i + 0.5) * 180 / arc_links;
        translate([wheelbase/2 + track_path_radius*cos(a),
                   y,
                   axle_z + track_path_radius*sin(a)])
            rotate([0,-a-90,0]) simple_track_link();
    }

    // rear arc, x negative
    for (i = [0 : arc_links-1]) {
        a = 90 + (i + 0.5) * 180 / arc_links;
        translate([-wheelbase/2 + track_path_radius*cos(a),
                   y,
                   axle_z + track_path_radius*sin(a)])
            rotate([0,-a-90,0]) simple_track_link();
    }
}

// ---------- wheels ----------
module lightening_holes_y(radius=25, hole_r=5, count=6, depth=30) {
    for (a=[0:360/count:359])
        translate([radius*cos(a),0,radius*sin(a)])
            cyl_y(depth, hole_r, true);
}

module sprocket() {
    difference() {
        union() {
            cyl_y(sprocket_width, sprocket_body_radius, true);
            cyl_y(sprocket_width + 4, 15, true);

            // Radial drive lugs. These engage the central pockets in track links.
            for (a=[0:360/sprocket_teeth:359])
                translate([sprocket_pitch_radius*cos(a),
                           0,
                           sprocket_pitch_radius*sin(a)])
                    rotate([0,-a,0])
                        cube([sprocket_tooth_radial,
                              sprocket_tooth_width,
                              sprocket_tooth_tangent], center=true);
        }

        cyl_y(sprocket_width + 8, main_axle_d/2, true);
        lightening_holes_y(sprocket_body_radius*0.58, 6, 6, sprocket_width+5);

        // Hex-like clamp recess around axle; intended for a separate hub insert.
        rotate([90,0,0])
            cylinder(h=4.2, r=8.3, center=true, $fn=6);
    }
}

module idler() {
    difference() {
        union() {
            cyl_y(sprocket_width, sprocket_body_radius + 2, true);
            cyl_y(sprocket_width + 4, 13, true);
        }
        cyl_y(sprocket_width + 8, main_axle_d/2, true);
        lightening_holes_y((sprocket_body_radius+2)*0.58, 5.5, 6, sprocket_width+5);
    }
}

module road_wheel() {
    difference() {
        union() {
            cyl_y(road_wheel_width, road_wheel_radius, true);
            cyl_y(road_wheel_width + 4, 10, true);
        }
        cyl_y(road_wheel_width + 8, road_axle_d/2, true);
        lightening_holes_y(road_wheel_radius*0.56, 4.5, 6, road_wheel_width+5);
    }
}

// ---------- frame ----------
module rail_blank(length=230) {
    difference() {
        translate([0,0,rail_bottom_z + rail_height/2])
            rounded_box([length, rail_thickness, rail_height], 5, true);

        // Large central relief; leaves a perimeter web.
        translate([0,0,rail_bottom_z + rail_height/2 + 3])
            rounded_box([length-28, rail_thickness+2, rail_height-28], 8, true);
    }
}

module rail_half(front=true) {
    half_len = rail_length/2 + rail_split_overlap/2;
    x_sign = front ? 1 : -1;
    x_origin = x_sign * (rail_length/4 - rail_split_overlap/4);

    difference() {
        translate([x_origin,0,0]) rail_blank(half_len);

        // Main sprocket/idler bearing pocket at the relevant outer end.
        end_x = x_sign * wheelbase/2;
        translate([end_x,0,axle_z])
            cyl_y(rail_thickness+2, bearing_od/2, true);

        // Four road-wheel axle bores that fall within this half.
        for (rx = road_wheel_x)
            if ((front && rx >= -rail_split_overlap/2) ||
                (!front && rx <= rail_split_overlap/2))
                translate([rx,0,road_wheel_z])
                    cyl_y(rail_thickness+2, road_axle_d/2, true);

        // Crossmember bolt holes
        for (cx = [-150, 0, 150])
            if ((front && cx >= -rail_split_overlap/2) ||
                (!front && cx <= rail_split_overlap/2))
                for (zv=[58,92])
                    translate([cx,0,zv])
                        cyl_y(rail_thickness+2, 2.2, true);

        // Splice bolt holes through overlap
        for (sx=[-7,7])
            for (sz=[58,92])
                translate([sx,0,sz])
                    cyl_y(rail_thickness+2, 2.2, true);
    }
}

module crossmember() {
    // Printable hollow beam; length is chassis_width and fits the X1C bed.
    difference() {
        cube([crossmember_x, chassis_width, crossmember_z], center=true);
        cube([crossmember_x-2*crossmember_wall,
              chassis_width-2*crossmember_wall,
              crossmember_z-2*crossmember_wall], center=true);

        // M4 side fastener clearance
        for (sy=[-1,1])
            for (zv=[-6,6])
                translate([0,sy*(chassis_width/2-5),zv])
                    rotate([90,0,0]) cylinder(h=12,r=2.2,center=true);
    }
}

module floor_half(front=true) {
    x_sign = front ? 1 : -1;
    x_origin = x_sign*(floor_half_length/2 - 10);
    difference() {
        translate([x_origin,0,floor_z])
            rounded_box([floor_half_length, chassis_width-6, floor_thickness], 5, true);

        // Weight reduction / cable access slots
        for (xv=[-70,0,70])
            translate([x_origin+xv,0,floor_z])
                rounded_box([38,chassis_width-42,floor_thickness+2], 7, true);

        // Splice holes near centre
        for (yv=[-70,70])
            for (xv=[-8,8])
                translate([xv,yv,floor_z])
                    cylinder(h=floor_thickness+2,r=2.2,center=true);
    }
}

module motor_plate() {
    plate = 86;
    difference() {
        rounded_box([plate, 6, plate], 5, true);
        cyl_y(10, 10, true);
        bolt_circle_y(25, 3.6, 4, 10, 45);
        bolt_circle_y(30, 3.6, 4, 10, 0);

        // Four M4 plate mounting holes
        for (x=[-34,34])
            for (z=[-34,34])
                translate([x,0,z]) cyl_y(10,2.2,true);
    }
}

module gearbox_plate() {
    // Generic side plate for a future reduction gearbox. Three shaft centres are
    // deliberately slotted so reduction geometry can be changed without
    // reprinting the entire rail.
    plate_x = 150;
    plate_z = 100;
    difference() {
        rounded_box([plate_x,6,plate_z],5,true);

        // Output bearing / sprocket shaft
        translate([55,0,18]) cyl_y(10,bearing_od/2,true);

        // Intermediate shaft slot
        hull() {
            translate([5,0,-12]) cyl_y(10,5.2,true);
            translate([25,0,-12]) cyl_y(10,5.2,true);
        }

        // Motor shaft / nose clearance slot
        hull() {
            translate([-55,0,-25]) cyl_y(10,10,true);
            translate([-35,0,-25]) cyl_y(10,10,true);
        }

        for (x=[-62,62])
            for (z=[-38,38])
                translate([x,0,z]) cyl_y(10,2.2,true);
    }
}

module motor_placeholder() {
    color("dimgray")
        cyl_y(motor_length, motor_d/2, true);
    color("silver")
        cyl_y(motor_length+18, motor_shaft_d/2, true);
}

module frame_assembly() {
    rail_y = chassis_width/2;

    // inner structural rails, split at the middle
    for (sy=[-1,1]) {
        translate([0,sy*rail_y,0]) {
            rail_half(true);
            rail_half(false);
        }
    }

    // Crossmembers
    for (cx=[-150,0,150])
        translate([cx,0,76]) crossmember();

    if (show_floor) {
        floor_half(true);
        floor_half(false);
    }
}

module running_gear_side(y=0, mirror_side=false) {
    // rear drive sprocket, front idler
    translate([-wheelbase/2,y,axle_z]) sprocket();
    translate([ wheelbase/2,y,axle_z]) idler();

    for (rx=road_wheel_x)
        translate([rx,y,road_wheel_z]) road_wheel();

    if (show_tracks)
        track_loop(y);
}

module assembly() {
    track_centre_y = chassis_width/2 + track_gap + track_width/2;
    explode_y = exploded * 24;

    color("slategray") frame_assembly();

    color("orange") {
        running_gear_side( track_centre_y + explode_y, false);
        running_gear_side(-track_centre_y - explode_y, true);
    }

    if (show_motor_placeholders) {
        // Placeholder only: actual gearbox/output arrangement is intentionally
        // left modular. Motors sit low and inboard near the rear sprockets.
        translate([-145, chassis_width/2-28, 82]) motor_placeholder();
        translate([-145,-chassis_width/2+28, 82]) motor_placeholder();
    }
}

module dimensions() {
    echo("overall_width_mm", overall_width);
    echo("chassis_width_mm", chassis_width);
    echo("track_width_mm", track_width);
    echo("wheelbase_mm", wheelbase);
    echo("approx_overall_length_mm", wheelbase + 2*track_path_radius + track_pitch);
    echo("sprocket_pitch_diameter_mm", 2*sprocket_pitch_radius);
    echo("approx_track_links_per_side",
         2*straight_link_count + 2*round(PI*track_path_radius/track_pitch));
    echo("rail_half_length_mm", rail_length/2 + rail_split_overlap/2);
    echo("floor_half_size_mm", [floor_half_length,chassis_width-6]);
}

// ---------- output ----------
if (part == "assembly") assembly();
else if (part == "track_link") track_link(true);
else if (part == "sprocket") sprocket();
else if (part == "idler") idler();
else if (part == "road_wheel") road_wheel();
else if (part == "rail_front") rail_half(true);
else if (part == "rail_rear") rail_half(false);
else if (part == "crossmember") crossmember();
else if (part == "floor_front") floor_half(true);
else if (part == "floor_rear") floor_half(false);
else if (part == "motor_plate") motor_plate();
else if (part == "gearbox_plate") gearbox_plate();
else if (part == "dimensions") dimensions();
else assert(false, str("Unknown part selector: ", part));
