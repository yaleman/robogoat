/*
  Narrow stair-capable tracked robot chassis
  ------------------------------------------
  Original parametric design inspired by the general layout of RCTestFlight's
  printed Snow Tank, but not derived from its STL geometry.

  Default target:
    overall width:       ~340 mm
    overall length:      ~526 mm
    track width:          55 mm
    track contact length: 390 mm
    sprocket pitch dia:  ~105 mm

  Designed around a 256 x 256 mm printer bed. Long frame rails and floor panels
  are split into printable halves.

  IMPORTANT:
    This is a mechanical layout / first prototype, not a validated drivetrain.
    The imported track and cog geometry has passed the CAD collision fixtures,
    but must still be test-printed and load-tested before a full build.

  Export parts by changing `part` below.
*/

use <track_links.scad>

$fn = 45;

// ---------- part selector ----------
part = "assembly";
// assembly, track_link, sprocket, front_cog, front_cog_assembly,
// front_cog_mount, shoulder_bolt, bearing_608, support_idler,
// christie_arm, vertical_spring, spring_upper_fork,
// suspension_unit, suspension_unit_raised,
// rail_front, rail_rear, crossmember, floor_front, floor_rear,
// motor_plate, gearbox_plate, drive_collision, front_cog_collision,
// front_cog_hardware_collision,
// support_idler_collision, suspension_clearance_collision,
// spring_pivot_clearance_collision, dimensions

exploded = 0;          // 0 for normal assembly, 1 for mildly exploded
show_tracks = true;
show_motor_placeholders = true;
show_floor = true;

// ---------- assembly colours ----------
// These affect previews and review renders only; exported STL geometry is
// unchanged.
colour_frame = "#4B5563";
colour_mount = "#303846";
colour_track = "#C89B2C";
colour_drive_cog = "#C44536";
colour_front_cog = "#6D5BD0";
colour_road_wheel = "#388C8C";
colour_suspension_arm = "#E0A11A";
colour_spring = "#35A854";
colour_bearing = "#2878D0";
colour_fastener = "#17191C";
colour_steel = "#AEB5BE";
colour_motor = "#555D68";

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

// Printable link and drive-cog dimensions are defined in track_links.scad.

running_gear_drop = 15;
nominal_axle_z = 72;
axle_z = nominal_axle_z - running_gear_drop;
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

// ---------- front undriven cog and axle ----------
// One 608 bearing is pressed into the outer half of each front cog. The
// shoulder screw enters from outside the track and threads into a captive M6
// nut in the stationary inboard bracket.
bearing_608_id = 8;
bearing_608_od = 22;
bearing_608_width = 7;
bearing_od = 22.2;    // 608 bearing seat starting point; tune for material
bearing_depth = bearing_608_width;

front_cog_relief_d = 12.4;
front_axle_shoulder_d = 7.95;
front_axle_shoulder_length = 10;
front_axle_thread_d = 6;
front_axle_thread_length = 11.25;
front_axle_head_d = 13;
front_axle_head_height = 5.5;
front_axle_hex_key_af = 4;
front_axle_washer_thickness = 0.5;
front_axle_washer_od = 12;
front_axle_spacer_od = 11.5;
front_axle_spacer_bore_d = 8.15;
front_axle_spacer_length =
    front_axle_shoulder_length
    - bearing_608_width
    - front_axle_washer_thickness;

front_mount_gap = track_gap + track_width/2 - rail_thickness/2;
front_mount_flange_radius = 20;
front_mount_flange_thickness = 6;
front_mount_transition_radius = 14;
front_mount_nose_d = 11.2;
front_mount_spigot_d = 21.8;
front_mount_spigot_depth = 3;
front_mount_bolt_bcd = 32;
front_mount_bolt_d = 4.4;
front_mount_rail_boss_radius = 22;
front_mount_thread_clearance_d = 6.4;
front_mount_nut_af = 10.4;
front_mount_nut_thickness = 5.2;
front_mount_nut_offset = 10.75;

assert(
    front_axle_spacer_length > 0,
    "The shoulder must cover the washer, 608 bearing, and inner spacer"
);
assert(
    front_axle_shoulder_d < bearing_608_id,
    "The shoulder screw must pass through the 608 bearing"
);
assert(
    front_mount_nose_d < front_cog_relief_d,
    "The stationary front mount must clear the rotating cog relief"
);

support_idler_axle_d = 5.2;
support_idler_radius = 35;
support_idler_width = 14;
support_idler_x = [-110, 0, 110];
// Nominal tangent contact with the wheel-side face of the lower track run.
support_idler_z = track_bottom_z + support_idler_radius;

// ---------- Christie suspension ----------
// The arm is horizontal at nominal ride height. Wheel motion upward rotates the
// arm about its hull pivot and raises the spring pickup, compressing the spring.
suspension_arm_length = 55;
suspension_arm_width = 8;
suspension_arm_height = 12;
suspension_arm_boss_radius = 9;
suspension_pivot_d = 6.2;
suspension_pickup_ratio = 0.60;
suspension_pickup_d = 4.2;
suspension_pivot_x = [
    for (wheel_x = support_idler_x)
        wheel_x - suspension_arm_length
];
suspension_spring_x = [
    for (pivot_x = suspension_pivot_x)
        pivot_x + suspension_arm_length*suspension_pickup_ratio
];

suspension_arm_inboard_offset =
    support_idler_width/2 + suspension_arm_width/2 + 3;
suspension_spring_inboard_offset = 7.5;

spring_mean_radius = 6;
spring_wire_d = 2.4;
spring_turns = 7;
spring_cap_radius = 7.5;
spring_cap_thickness = 3;
spring_guide_d = 4;
spring_eyelet_outer_radius = 6;
spring_eyelet_width = 6;
spring_eyelet_neck_height = 8;
spring_pivot_pin_d = 4;
spring_pivot_bore_d = 4.4;
spring_lower_pivot_z = support_idler_z;
spring_upper_pivot_z = 110 - running_gear_drop;
spring_height = spring_upper_pivot_z - spring_lower_pivot_z;
spring_mount_width = 18;
spring_mount_thickness = 5;
spring_fork_outer_radius = 7;
spring_fork_ear_thickness = 3;
spring_fork_clearance = 0.5;
spring_fork_pin_overhang = 1;
spring_mount_rib_width = 14;
spring_mount_rib_clearance = 0.5;
spring_mount_rib_bottom_z =
    spring_upper_pivot_z - spring_fork_outer_radius + 1;
spring_mount_lower_bolt_z = spring_upper_pivot_z - 3;
spring_rail_rib_width = 18;
suspension_pivot_lug_radius = 12;
spring_mount_bottom_z =
    spring_upper_pivot_z + spring_fork_outer_radius + 1;
spring_mount_z = spring_mount_bottom_z + spring_mount_thickness/2;

assert(spring_height > 30, "Vertical spring is too short");
assert(
    spring_pivot_bore_d > spring_pivot_pin_d,
    "Spring pivot bore must clear the pivot pin"
);
assert(
    suspension_pickup_ratio > 0 && suspension_pickup_ratio < 1,
    "Spring pickup must lie between the suspension pivot and wheel axle"
);

sprocket_width = 14;

motor_d = 42;
motor_length = 48;
motor_shaft_d = 8;

// ---------- helpers ----------
module rounded_rect_2d(size=[10,10], r=2) {
    effective_r = min(r, min(size)/2 - 0.01);

    assert(effective_r > 0, "Rounded rectangle is too small for its radius");

    offset(r=effective_r)
        offset(delta=-effective_r)
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

module hex_prism_y(h, across_flats, center=true) {
    rotate([90,0,0])
        cylinder(
            h=h,
            r=across_flats/(2*cos(30)),
            center=center,
            $fn=6
        );
}

module bolt_circle_y(bcd=25, hole_d=3.3, count=4, depth=20, angle_offset=45) {
    for (a = [0 : 360/count : 359])
        translate([(bcd/2)*cos(a+angle_offset), 0, (bcd/2)*sin(a+angle_offset)])
            cyl_y(depth, hole_d/2, true);
}

// ---------- track loop ----------
// An 11-tooth cog and two 13-link straight runs require 37 links per side.
// Link centres, rather than hinge pins, follow the tooth pitch circle because
// each cog tooth engages the drive window at the centre of a link.
function track_link_centres() =
    let(
        tooth_angle = 360 / sprocket_teeth,
        bottom = [
            for (i = [0 : straight_link_count-1])
                [-wheelbase/2 + track_pitch/2 + i*track_pitch, track_bottom_z]
        ],
        front = [
            for (i = [0 : ceil(sprocket_teeth/2)-1])
                [
                    wheelbase/2 + track_path_radius*cos(-90 + tooth_angle/2 + i*tooth_angle),
                    axle_z + track_path_radius*sin(-90 + tooth_angle/2 + i*tooth_angle)
                ]
        ],
        top = [
            for (i = [0 : straight_link_count-1])
                [wheelbase/2 - track_pitch - i*track_pitch, track_top_z]
        ],
        rear = [
            for (i = [1 : floor(sprocket_teeth/2)])
                [
                    -wheelbase/2 + track_path_radius*cos(90 + i*tooth_angle),
                    axle_z + track_path_radius*sin(90 + i*tooth_angle)
                ]
        ]
    )
    concat(bottom, front, top, rear);

function point_distance(a, b) =
    sqrt(pow(b[0]-a[0], 2) + pow(b[1]-a[1], 2));

function track_link_spacings() =
    let(centres = track_link_centres())
    [
        for (i = [0 : len(centres)-1])
            point_distance(centres[i], centres[(i+1) % len(centres)])
    ];

module positioned_track_link(index, y=0) {
    centres = track_link_centres();
    previous = centres[(index-1+len(centres)) % len(centres)];
    current = centres[index];
    next = centres[(index+1) % len(centres)];
    dx = next[0] - previous[0];
    dz = next[1] - previous[1];
    link_angle = atan2(dz, dx);

    translate([current[0], y, current[1]])
        rotate([0, -link_angle, 0])
            rotate([180, 0, 0])
                track_link();
}

module track_loop(y=0) {
    centres = track_link_centres();

    for (i = [0 : len(centres)-1])
        positioned_track_link(i, y);
}

// ---------- wheels ----------
module lightening_holes_y(radius=25, hole_r=5, count=6, depth=30) {
    for (a=[0:360/count:359])
        translate([radius*cos(a),0,radius*sin(a)])
            cyl_y(depth, hole_r, true);
}

module sprocket(phase=0) {
    rotate([0, -phase, 0]) cog_reference();
}

module front_cog(side_sign=1) {
    // The outer 7 mm pocket accepts one 608 bearing. The smaller inner relief
    // clears the stationary spacer and bracket nose while leaving an annular
    // shoulder behind the bearing's outer race.
    difference() {
        sprocket();

        translate([
            0,
            side_sign*(sprocket_width-bearing_depth)/2,
            0
        ])
            cyl_y(bearing_depth + 0.02, bearing_od/2, true);

        translate([
            0,
            -side_sign*(sprocket_width-bearing_depth)/2,
            0
        ])
            cyl_y(
                sprocket_width-bearing_depth + 0.02,
                front_cog_relief_d/2,
                true
            );
    }
}

module bearing_608_reference() {
    color(colour_bearing)
        difference() {
            cyl_y(bearing_608_width, bearing_608_od/2, true);
            cyl_y(bearing_608_width + 1, bearing_608_id/2, true);
        }
}

module axle_washer_reference() {
    difference() {
        cyl_y(front_axle_washer_thickness, front_axle_washer_od/2, true);
        cyl_y(
            front_axle_washer_thickness + 1,
            front_axle_spacer_bore_d/2,
            true
        );
    }
}

module inner_race_spacer_reference() {
    difference() {
        cyl_y(front_axle_spacer_length, front_axle_spacer_od/2, true);
        cyl_y(
            front_axle_spacer_length + 1,
            front_axle_spacer_bore_d/2,
            true
        );
    }
}

module shoulder_bolt_reference(side_sign=1) {
    // The under-head plane is y=0. Positive side_sign places the head toward
    // +Y and sends the shoulder/thread toward the chassis.
    color(colour_fastener) {
        difference() {
            translate([0, side_sign*front_axle_head_height/2, 0])
                cyl_y(
                    front_axle_head_height,
                    front_axle_head_d/2,
                    true
                );

            translate([0, side_sign*(front_axle_head_height-1.5), 0])
                hex_prism_y(
                    3.2,
                    front_axle_hex_key_af,
                    true
                );
        }

        translate([0, -side_sign*front_axle_shoulder_length/2, 0])
            cyl_y(
                front_axle_shoulder_length,
                front_axle_shoulder_d/2,
                true
            );

        translate([
            0,
            -side_sign*(
                front_axle_shoulder_length
                + front_axle_thread_length/2
            ),
            0
        ])
            cyl_y(
                front_axle_thread_length,
                front_axle_thread_d/2,
                true
            );
    }
}

module m6_nut_reference() {
    color(colour_fastener)
        difference() {
            hex_prism_y(
                front_mount_nut_thickness,
                front_mount_nut_af - 0.4,
                true
            );
            cyl_y(
                front_mount_nut_thickness + 1,
                front_axle_thread_d/2,
                true
            );
        }
}

module front_cog_mount(side_sign=1) {
    rail_face_y = -side_sign*front_mount_gap;
    flange_y = -side_sign*(
        front_mount_gap-front_mount_flange_thickness/2
    );
    transition_inner_y = -side_sign*(sprocket_width/2 + 1);
    transition_outer_y = -side_sign*(
        front_mount_gap-front_mount_flange_thickness
    );
    nose_tip_y = -side_sign*front_axle_spacer_length;
    nose_length = abs(transition_inner_y-nose_tip_y);
    nose_y = (transition_inner_y+nose_tip_y)/2;
    spigot_y = -side_sign*(
        front_mount_gap+front_mount_spigot_depth/2
    );
    nut_y = -side_sign*front_mount_nut_offset;

    difference() {
        union() {
            translate([0, flange_y, 0])
                cyl_y(
                    front_mount_flange_thickness,
                    front_mount_flange_radius,
                    true
                );

            hull() {
                translate([0, transition_outer_y, 0])
                    cyl_y(1, front_mount_transition_radius, true);
                translate([0, transition_inner_y, 0])
                    cyl_y(1, front_mount_transition_radius, true);
            }

            translate([0, nose_y, 0])
                cyl_y(nose_length, front_mount_nose_d/2, true);

            // This spigot locates in the former front rail bearing pocket.
            translate([0, spigot_y, 0])
                cyl_y(
                    front_mount_spigot_depth,
                    front_mount_spigot_d/2,
                    true
                );
        }

        // Clearance for the M6 thread between the shoulder and captive nut.
        translate([0, rail_face_y/2, 0])
            cyl_y(
                abs(rail_face_y) + 10,
                front_mount_thread_clearance_d/2,
                true
            );

        translate([0, flange_y, 0])
            bolt_circle_y(
                front_mount_bolt_bcd,
                front_mount_bolt_d,
                4,
                front_mount_flange_thickness
                + front_mount_spigot_depth
                + 4,
                45
            );

        // Top-loading captive-nut pocket. The rail-side flange prevents the
        // nut from escaping once the bracket is installed.
        translate([0, nut_y, 0])
            hex_prism_y(
                front_mount_nut_thickness + 0.4,
                front_mount_nut_af,
                true
            );
        translate([0, nut_y, front_mount_transition_radius/2])
            cube([
                front_mount_nut_af,
                front_mount_nut_thickness + 0.4,
                front_mount_transition_radius
            ], center=true);
    }
}

module front_axle_hardware(side_sign=1) {
    bearing_y = side_sign*(sprocket_width/2-bearing_608_width/2);
    washer_y = side_sign*(
        sprocket_width/2+front_axle_washer_thickness/2
    );
    spacer_y = -side_sign*front_axle_spacer_length/2;
    under_head_y = side_sign*(
        sprocket_width/2+front_axle_washer_thickness
    );
    nut_y = -side_sign*front_mount_nut_offset;

    translate([0, bearing_y, 0]) bearing_608_reference();

    color(colour_steel) {
        translate([0, washer_y, 0]) axle_washer_reference();
        translate([0, spacer_y, 0]) inner_race_spacer_reference();
    }

    translate([0, under_head_y, 0])
        shoulder_bolt_reference(side_sign);
    translate([0, nut_y, 0]) m6_nut_reference();
}

module front_cog_assembly(side_sign=1) {
    color(colour_front_cog) front_cog(side_sign);
    color(colour_mount) front_cog_mount(side_sign);
    front_axle_hardware(side_sign);
}

module support_idler() {
    difference() {
        union() {
            cyl_y(support_idler_width, support_idler_radius, true);
            cyl_y(support_idler_width + 4, 10, true);
        }
        cyl_y(support_idler_width + 8, support_idler_axle_d/2, true);
        lightening_holes_y(
            support_idler_radius*0.56,
            4.5,
            6,
            support_idler_width+5
        );
    }
}

module christie_arm() {
    pickup_x = suspension_arm_length*suspension_pickup_ratio;

    difference() {
        union() {
            hull() {
                cyl_y(
                    suspension_arm_width,
                    suspension_arm_height/2,
                    true
                );
                translate([suspension_arm_length, 0, 0])
                    cyl_y(
                        suspension_arm_width,
                        suspension_arm_height/2,
                        true
                    );
            }
            cyl_y(
                suspension_arm_width,
                suspension_arm_boss_radius,
                true
            );
            translate([suspension_arm_length, 0, 0])
                cyl_y(
                    suspension_arm_width,
                    suspension_arm_boss_radius,
                    true
                );
        }

        cyl_y(
            suspension_arm_width+2,
            suspension_pivot_d/2,
            true
        );
        translate([suspension_arm_length, 0, 0])
            cyl_y(
                suspension_arm_width+2,
                support_idler_axle_d/2,
                true
            );
        translate([pickup_x, 0, 0])
            cyl_y(
                suspension_arm_width+2,
                suspension_pickup_d/2,
                true
            );
    }
}

module coil_spring(height) {
    linear_extrude(
        height=height,
        twist=spring_turns*360,
        slices=spring_turns*10,
        convexity=10
    )
        translate([spring_mean_radius, 0])
            circle(d=spring_wire_d, $fn=12);
}

module spring_eyelet(connect_up=true) {
    neck_height = spring_eyelet_neck_height;
    neck_z = connect_up ? neck_height/2 : -neck_height/2;

    difference() {
        union() {
            cyl_y(
                spring_eyelet_width,
                spring_eyelet_outer_radius,
                true
            );
            translate([0, 0, neck_z])
                cube([
                    2*spring_eyelet_outer_radius,
                    spring_eyelet_width,
                    neck_height
                ], center=true);
        }
        cyl_y(
            spring_eyelet_width+2,
            spring_pivot_bore_d/2,
            true
        );
    }
}

module vertical_spring(height=spring_height) {
    body_overlap = 1;
    body_start = spring_eyelet_neck_height-body_overlap;
    body_end = height-spring_eyelet_neck_height+body_overlap;
    lower_cap_z = body_start;
    upper_cap_z = body_end-spring_cap_thickness;
    coil_start = lower_cap_z+spring_cap_thickness;
    coil_height = upper_cap_z-coil_start;

    assert(coil_height > 0, "Spring eyelets and caps exceed spring height");

    spring_eyelet(true);
    translate([0, 0, height])
        spring_eyelet(false);

    // Central guide represents the future telescoping damper/guide envelope.
    translate([0, 0, body_start])
        cylinder(
            h=body_end-body_start,
            d=spring_guide_d,
            center=false
        );
    translate([0, 0, lower_cap_z])
        cylinder(
            h=spring_cap_thickness,
            r=spring_cap_radius,
            center=false
        );
    translate([0, 0, upper_cap_z])
        cylinder(
            h=spring_cap_thickness,
            r=spring_cap_radius,
            center=false
        );
    translate([0, 0, coil_start])
        coil_spring(coil_height);
}

module spring_upper_fork(spring_x, spring_y, side_sign) {
    rail_y = side_sign*chassis_width/2;
    ear_offset =
        spring_eyelet_width/2
        + spring_fork_clearance
        + spring_fork_ear_thickness/2;
    mount_span =
        abs(spring_y-rail_y)
        + 2*ear_offset
        + spring_fork_ear_thickness;
    mount_y = (spring_y+rail_y)/2;
    ear_stem_height = spring_mount_bottom_z-spring_upper_pivot_z;
    near_ear_y = spring_y - side_sign*ear_offset;
    rib_outboard_y =
        near_ear_y
        - side_sign*(spring_fork_ear_thickness/2 + spring_mount_rib_clearance);
    rib_span = abs(rib_outboard_y-rail_y);
    rib_y = (rail_y+rib_outboard_y)/2;
    rib_height =
        spring_mount_z + spring_mount_thickness/2
        - spring_mount_rib_bottom_z;

    difference() {
        union() {
            translate([spring_x, mount_y, spring_mount_z])
                cube([
                    spring_mount_width,
                    mount_span,
                    spring_mount_thickness
                ], center=true);

            // Thick vertical gusset transfers the fork load into the rail-side
            // mounting face instead of leaving the top beam in pure bending.
            translate([
                spring_x,
                rib_y,
                spring_mount_rib_bottom_z + rib_height/2
            ])
                cube([
                    spring_mount_rib_width,
                    rib_span,
                    rib_height
                ], center=true);
        }

        // Two M4 cross-bolts prevent the bracket rotating on the rail rib.
        for (bolt_z = [spring_mount_lower_bolt_z, spring_mount_z])
            translate([spring_x, rail_y, bolt_z])
                cyl_y(mount_span+4, 2.2, true);
    }

    for (ear_side = [-1, 1]) {
        ear_y = spring_y + ear_side*ear_offset;

        difference() {
            union() {
                translate([
                    spring_x,
                    ear_y,
                    spring_upper_pivot_z
                ])
                    cyl_y(
                        spring_fork_ear_thickness,
                        spring_fork_outer_radius,
                        true
                    );
                translate([
                    spring_x,
                    ear_y,
                    spring_upper_pivot_z+ear_stem_height/2
                ])
                    cube([
                        2*spring_fork_outer_radius,
                        spring_fork_ear_thickness,
                        ear_stem_height
                    ], center=true);
            }

            translate([
                spring_x,
                ear_y,
                spring_upper_pivot_z
            ])
                cyl_y(
                    spring_fork_ear_thickness+2,
                    spring_pivot_bore_d/2,
                    true
                );
        }
    }
}

module christie_suspension_unit(wheel_x, y, side_sign, arm_angle=0) {
    pivot_x = wheel_x - suspension_arm_length;
    pickup_length = suspension_arm_length*suspension_pickup_ratio;
    upper_pivot_x = pivot_x + pickup_length;
    lower_pivot_x = pivot_x + pickup_length*cos(arm_angle);
    lower_pivot_z = support_idler_z + pickup_length*sin(arm_angle);
    moving_wheel_x = pivot_x + suspension_arm_length*cos(arm_angle);
    moving_wheel_z = support_idler_z + suspension_arm_length*sin(arm_angle);
    spring_dx = upper_pivot_x-lower_pivot_x;
    spring_dz = spring_upper_pivot_z-lower_pivot_z;
    moving_spring_height = sqrt(pow(spring_dx, 2)+pow(spring_dz, 2));
    spring_tilt = atan2(spring_dx, spring_dz);
    arm_y = y - side_sign*suspension_arm_inboard_offset;
    spring_y = arm_y - side_sign*suspension_spring_inboard_offset;
    rail_y = side_sign*chassis_width/2;

    color(colour_suspension_arm)
        translate([pivot_x, arm_y, support_idler_z])
            rotate([0, -arm_angle, 0])
                christie_arm();

    // Pivot shaft bridges the hull rail to the inboard face of the arm.
    color(colour_fastener)
        translate([
            pivot_x,
            (rail_y+arm_y)/2,
            support_idler_z
        ])
            cyl_y(
                abs(arm_y-rail_y)+suspension_arm_width,
                suspension_pivot_d/2-0.3,
                true
            );

    // Wheel axle bridges the arm and the complete road wheel hub.
    wheel_axle_end_y =
        y + side_sign*(support_idler_width/2 + 2);
    color(colour_fastener)
        translate([
            moving_wheel_x,
            (arm_y+wheel_axle_end_y)/2,
            moving_wheel_z
        ])
            cyl_y(
                abs(wheel_axle_end_y-arm_y),
                support_idler_axle_d/2-0.25,
                true
            );

    // Cross-pin carries the vertical spring load into the arm pickup.
    color(colour_fastener)
        translate([
            lower_pivot_x,
            (arm_y+spring_y)/2,
            lower_pivot_z
        ])
            cyl_y(
                abs(arm_y-spring_y)
                + suspension_arm_width/2
                + spring_eyelet_width/2
                + 2*spring_fork_pin_overhang,
                spring_pivot_pin_d/2,
                true
            );

    color(colour_spring)
        translate([lower_pivot_x, spring_y, lower_pivot_z])
            rotate([0, spring_tilt, 0])
                vertical_spring(moving_spring_height);

    color(colour_mount)
        spring_upper_fork(upper_pivot_x, spring_y, side_sign);

    upper_pin_length =
        spring_eyelet_width
        + 2*(
            spring_fork_clearance
            + spring_fork_ear_thickness
            + spring_fork_pin_overhang
        );
    color(colour_fastener)
        translate([upper_pivot_x, spring_y, spring_upper_pivot_z])
            cyl_y(
                upper_pin_length,
                spring_pivot_pin_d/2,
                true
            );

    color(colour_road_wheel)
        translate([moving_wheel_x, y, moving_wheel_z])
            rotate([0, -arm_angle, 0])
                support_idler();
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
        union() {
            translate([x_origin,0,0]) rail_blank(half_len);

            // Dropped bosses keep the lowered arm pivots tied into the lower
            // rail web instead of leaving their axes below the frame.
            for (pivot_x = suspension_pivot_x)
                if ((front && pivot_x >= -rail_split_overlap/2) ||
                    (!front && pivot_x <= rail_split_overlap/2))
                    hull() {
                        translate([
                            pivot_x,
                            0,
                            rail_bottom_z + suspension_pivot_lug_radius
                        ])
                            cyl_y(
                                rail_thickness,
                                suspension_pivot_lug_radius,
                                true
                            );
                        translate([pivot_x,0,support_idler_z])
                            cyl_y(
                                rail_thickness,
                                suspension_pivot_lug_radius,
                                true
                            );
                    }

            // A full-height solid column behind every upper fork gives both
            // mount bolts real material and ties the load into both rail webs.
            for (spring_x = suspension_spring_x)
                if ((front && spring_x >= -rail_split_overlap/2) ||
                    (!front && spring_x <= rail_split_overlap/2))
                    translate([
                        spring_x,
                        0,
                        rail_bottom_z + rail_height/2
                    ])
                        cube([
                            spring_rail_rib_width,
                            rail_thickness,
                            rail_height
                        ], center=true);

            // The front cog bracket bolts to a reinforced rail boss. The
            // former 608 pocket remains as a locating socket for its spigot.
            if (front)
                translate([wheelbase/2, 0, axle_z])
                    cyl_y(
                        rail_thickness,
                        front_mount_rail_boss_radius,
                        true
                    );
        }

        // Rear: drive-shaft bearing pocket. Front: bracket locating socket.
        end_x = x_sign * wheelbase/2;
        translate([end_x,0,axle_z])
            cyl_y(rail_thickness+2, bearing_od/2, true);

        if (front)
            translate([wheelbase/2, 0, axle_z])
                bolt_circle_y(
                    front_mount_bolt_bcd,
                    front_mount_bolt_d,
                    4,
                    rail_thickness + 2,
                    45
                );

        // Christie-arm pivot bores in the lower structural web.
        for (pivot_x = suspension_pivot_x)
            if ((front && pivot_x >= -rail_split_overlap/2) ||
                (!front && pivot_x <= rail_split_overlap/2))
                translate([pivot_x,0,support_idler_z])
                    cyl_y(
                        rail_thickness+2,
                        suspension_pivot_d/2,
                        true
                    );

        // Twin spring-mount cross-bolts through the vertical rail ribs.
        for (spring_x = suspension_spring_x)
            if ((front && spring_x >= -rail_split_overlap/2) ||
                (!front && spring_x <= rail_split_overlap/2))
                for (bolt_z = [spring_mount_lower_bolt_z, spring_mount_z])
                    translate([spring_x,0,bolt_z])
                        cyl_y(rail_thickness+2, 2.2, true);

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
    color(colour_motor)
        cyl_y(motor_length, motor_d/2, true);
    color(colour_steel)
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

module running_gear_side(y=0, side_sign=1) {
    // Rear drive cog and matching front free-spinning cog.
    color(colour_drive_cog)
        translate([-wheelbase/2,y,axle_z])
            sprocket();
    translate([wheelbase/2,y,axle_z])
        front_cog_assembly(side_sign);

    // Three independent horizontal-arm Christie suspension units. Each spring
    // acts vertically between its arm pickup and the hull's upper rail web.
    for (wheel_x = support_idler_x)
        christie_suspension_unit(wheel_x, y, side_sign);

    if (show_tracks)
        color(colour_track) track_loop(y);
}

module assembly() {
    track_centre_y = chassis_width/2 + track_gap + track_width/2;
    explode_y = exploded * 24;

    color(colour_frame) frame_assembly();

    running_gear_side( track_centre_y + explode_y,  1);
    running_gear_side(-track_centre_y - explode_y, -1);

    if (show_motor_placeholders) {
        // Placeholder only: actual gearbox/output arrangement is intentionally
        // left modular. Motors sit low and inboard near the rear sprockets.
        translate([-145, chassis_width/2-28, 82]) motor_placeholder();
        translate([-145,-chassis_width/2+28, 82]) motor_placeholder();
    }
}

module drive_collision() {
    intersection() {
        translate([-wheelbase/2, 0, axle_z])
            sprocket();
        union()
            // Bottom transition, upper transition, and five rear-wrap links.
            for (index = [0, 31, 32, 33, 34, 35, 36])
                positioned_track_link(index, 0);
    }
}

module front_cog_collision() {
    intersection() {
        translate([wheelbase/2, 0, axle_z])
            front_cog(1);
        union()
            // Bottom transition, six front-wrap links, and upper transition.
            for (index = [12, 13, 14, 15, 16, 17, 18, 19])
                positioned_track_link(index, 0);
    }
}

module front_cog_hardware_collision() {
    intersection() {
        front_cog(1);
        union() {
            front_cog_mount(1);
            front_axle_hardware(1);
        }
    }
}

module support_idler_collision() {
    tangent_allowance = 0.01;

    intersection() {
        union()
            for (idler_x = support_idler_x)
                // Ignore the zero-area edge created by exact mathematical
                // tangency so this fixture reports volumetric penetration.
                translate([
                    idler_x,
                    0,
                    support_idler_z + tangent_allowance
                ]) support_idler();
        union()
            // All 13 links in the straight lower run.
            for (index = [0 : straight_link_count-1])
                positioned_track_link(index, 0);
    }
}

module suspension_clearance_collision() {
    side_sign = 1;
    track_y = chassis_width/2 + track_gap + track_width/2;
    arm_y = track_y - suspension_arm_inboard_offset;
    spring_y = arm_y - suspension_spring_inboard_offset;
    rail_y = chassis_width/2;

    intersection() {
        // Moving suspension members, excluding their intentional joints.
        union()
            for (i = [0 : len(support_idler_x)-1]) {
                translate([
                    suspension_pivot_x[i],
                    arm_y,
                    support_idler_z
                ]) christie_arm();
                translate([
                    suspension_spring_x[i],
                    spring_y,
                    spring_lower_pivot_z
                ]) vertical_spring();
            }

        // Nearby fixed/mating geometry. A correct result has no volume.
        union() {
            translate([-wheelbase/2, track_y, axle_z]) sprocket();
            translate([wheelbase/2, track_y, axle_z])
                front_cog_assembly(side_sign);
            for (wheel_x = support_idler_x)
                translate([wheel_x, track_y, support_idler_z])
                    support_idler();
            translate([0, rail_y, 0]) {
                rail_half(true);
                rail_half(false);
            }
            track_loop(track_y);
        }
    }
}

module spring_pivot_clearance_collision() {
    side_sign = 1;
    wheel_x = support_idler_x[1];
    pivot_x = suspension_pivot_x[1];
    spring_x = suspension_spring_x[1];
    track_y = chassis_width/2 + track_gap + track_width/2;
    arm_y = track_y - suspension_arm_inboard_offset;
    spring_y = arm_y - suspension_spring_inboard_offset;

    intersection() {
        translate([
            spring_x,
            spring_y,
            spring_lower_pivot_z
        ]) vertical_spring();

        union() {
            translate([pivot_x, arm_y, support_idler_z])
                christie_arm();
            spring_upper_fork(spring_x, spring_y, side_sign);
        }
    }
}

module dimensions() {
    spacings = track_link_spacings();
    demo_angle = 12;
    pickup_length = suspension_arm_length*suspension_pickup_ratio;
    demo_spring_dx = pickup_length*(1-cos(demo_angle));
    demo_spring_dz =
        spring_height-pickup_length*sin(demo_angle);
    demo_spring_height =
        sqrt(pow(demo_spring_dx, 2)+pow(demo_spring_dz, 2));

    echo("overall_width_mm", overall_width);
    echo("chassis_width_mm", chassis_width);
    echo("track_width_mm", track_width);
    echo("running_gear_drop_mm", running_gear_drop);
    echo("wheelbase_mm", wheelbase);
    echo("approx_overall_length_mm", wheelbase + 2*track_path_radius + track_pitch);
    echo("sprocket_pitch_diameter_mm", 2*sprocket_pitch_radius);
    echo("track_links_per_side", len(track_link_centres()));
    echo("track_link_spacing_range_mm", [min(spacings), max(spacings)]);
    echo("front_cog_bearing_mm", [
        bearing_608_id,
        bearing_608_od,
        bearing_608_width
    ]);
    echo("front_cog_bearing_seat_d_mm", bearing_od);
    echo("front_axle_shoulder_d_mm", front_axle_shoulder_d);
    echo("front_axle_shoulder_length_mm", front_axle_shoulder_length);
    echo("front_axle_thread_mm", [
        front_axle_thread_d,
        front_axle_thread_length
    ]);
    echo("front_axle_stack_mm", [
        front_axle_washer_thickness,
        bearing_608_width,
        front_axle_spacer_length
    ]);
    echo("front_mount_bolt_pattern_mm", [
        front_mount_bolt_bcd,
        front_mount_bolt_d
    ]);
    echo("support_idlers_per_side", len(support_idler_x));
    echo("support_idler_x_mm", support_idler_x);
    echo("support_idler_axle_z_mm", support_idler_z);
    echo("support_idler_nominal_contact_z_mm", support_idler_z-support_idler_radius);
    echo("suspension_arm_length_mm", suspension_arm_length);
    echo("suspension_pivot_x_mm", suspension_pivot_x);
    echo("suspension_spring_x_mm", suspension_spring_x);
    echo("suspension_spring_pivot_spacing_mm", spring_height);
    echo("suspension_spring_pivot_pin_d_mm", spring_pivot_pin_d);
    echo("suspension_spring_pivot_bore_d_mm", spring_pivot_bore_d);
    echo("suspension_mount_rib_width_mm", spring_mount_rib_width);
    echo("suspension_rail_rib_width_mm", spring_rail_rib_width);
    echo("suspension_mount_bolt_spacing_mm",
         spring_mount_z-spring_mount_lower_bolt_z);
    echo("suspension_pivot_lug_radius_mm", suspension_pivot_lug_radius);
    echo("suspension_spring_motion_ratio", suspension_pickup_ratio);
    echo("suspension_arm_to_wheel_clearance_mm",
         suspension_arm_inboard_offset
         - support_idler_width/2
         - suspension_arm_width/2);
    echo("suspension_arm_to_hub_clearance_mm",
         suspension_arm_inboard_offset
         - (support_idler_width+4)/2
         - suspension_arm_width/2);
    echo("suspension_spring_cap_to_rail_clearance_mm",
         track_gap + track_width/2
         - suspension_arm_inboard_offset
         - suspension_spring_inboard_offset
         - spring_cap_radius
         - rail_thickness/2);
    echo("suspension_spring_cap_to_wheel_clearance_mm",
         suspension_arm_inboard_offset
         + suspension_spring_inboard_offset
         - support_idler_width/2
         - spring_cap_radius);
    echo("suspension_lower_eyelet_to_arm_clearance_mm",
         suspension_spring_inboard_offset
         - suspension_arm_width/2
         - spring_eyelet_width/2);
    echo("suspension_demo_arm_angle_deg", demo_angle);
    echo("suspension_demo_wheel_lift_mm",
         suspension_arm_length*sin(demo_angle));
    echo("suspension_demo_spring_compression_mm",
         spring_height-demo_spring_height);
    echo("suspension_demo_spring_tilt_deg",
         atan2(demo_spring_dx, demo_spring_dz));
    echo("suspension_mount_to_top_track_clearance_mm",
         track_top_z-(spring_mount_z+spring_mount_thickness/2));
    echo("rail_half_length_mm", rail_length/2 + rail_split_overlap/2);
    echo("floor_half_size_mm", [floor_half_length,chassis_width-6]);
}

// ---------- output ----------
if (part == "assembly") assembly();
else if (part == "track_link") color(colour_track) track_link();
else if (part == "sprocket") color(colour_drive_cog) sprocket();
else if (part == "front_cog") color(colour_front_cog) front_cog(1);
else if (part == "front_cog_assembly") front_cog_assembly(1);
else if (part == "front_cog_mount")
    color(colour_mount) front_cog_mount(1);
else if (part == "shoulder_bolt") shoulder_bolt_reference(1);
else if (part == "bearing_608") bearing_608_reference();
else if (part == "support_idler")
    color(colour_road_wheel) support_idler();
else if (part == "christie_arm")
    color(colour_suspension_arm) christie_arm();
else if (part == "vertical_spring")
    color(colour_spring) vertical_spring();
else if (part == "spring_upper_fork")
    color(colour_mount)
        spring_upper_fork(
            0,
            overall_width/2-track_width/2
            - suspension_arm_inboard_offset
            - suspension_spring_inboard_offset,
            1
        );
else if (part == "suspension_unit")
    christie_suspension_unit(0, overall_width/2-track_width/2, 1);
else if (part == "suspension_unit_raised")
    christie_suspension_unit(
        0,
        overall_width/2-track_width/2,
        1,
        12
    );
else if (part == "rail_front") color(colour_frame) rail_half(true);
else if (part == "rail_rear") color(colour_frame) rail_half(false);
else if (part == "crossmember") color(colour_frame) crossmember();
else if (part == "floor_front") color(colour_frame) floor_half(true);
else if (part == "floor_rear") color(colour_frame) floor_half(false);
else if (part == "motor_plate") color(colour_mount) motor_plate();
else if (part == "gearbox_plate") color(colour_mount) gearbox_plate();
else if (part == "drive_collision") drive_collision();
else if (part == "front_cog_collision") front_cog_collision();
else if (part == "front_cog_hardware_collision")
    front_cog_hardware_collision();
else if (part == "support_idler_collision") support_idler_collision();
else if (part == "suspension_clearance_collision")
    suspension_clearance_collision();
else if (part == "spring_pivot_clearance_collision")
    spring_pivot_clearance_collision();
else if (part == "dimensions") dimensions();
else assert(false, str("Unknown part selector: ", part));
