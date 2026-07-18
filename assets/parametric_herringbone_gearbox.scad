/*
Parametric 40:1 herringbone gearbox for a tracked robot.

Dependency:
  chrisspen/gears, with gears.scad beside this file:
  https://github.com/chrisspen/gears

Default train:
  18:54  = 3:1
  18:72  = 4:1
  18:72  = 4:1
  48:40  = 0.833:1
  internal total = 40:1

The tracked chassis adds a 20:48 external final-drive pair, producing an
overall reduction of 96:1 without a belt or jackshaft stage.

Construction:
  - All gears print flat with their shaft axes vertical.
  - Motor pinion fits a nominal 3.175 mm D-shaft.
  - Four 8 mm D-shafts run in 688 bearings pressed into both side plates.
  - Compound shafts use two separate keyed gears on the same steel shaft.
  - Eight M4 standoffs clamp the housing plates together.
  - The compact layout fits one plate on the shared X1C print envelope.
  - A dimensioned 540 motor reference is included in the drive-unit preview.

This is a printable prototype, not a certified transmission. Begin testing with
an ESC current limit and a gentle throttle ramp.
*/

include <gears.scad>
include <printer_config.scad>


// Visualisation and rendering.
show_bearings = true;
show_shafts = true;
show_internal_spacers = true;
show_plates = true;
explode = 0;
$fn = $preview ? 48 : 96;

// OpenSCAD Customizer entry point.
part = "assembly"; // [assembly,assembly_alternate,drive_unit,drive_unit_mirrored,drive_unit_alternate,motor_540,front_plate,rear_plate,front_plate_alternate,rear_plate_alternate,motor_pinion,gear_a0,gear_a1,gear_b1,gear_b2,gear_c2,gear_c3,output_gear,final_drive_pinion,final_drive_axle_gear,internal_gear_collision,housing_standoff_gear_collision,shaft_other_gear_collision,spacer_set,housing_spacer,gear_set,print_layout]

// ---------- Gear train ----------
gear_module = 1.25;
pressure_angle = 20;
helix_angle = 30;             // chrisspen/gears recommends 30-45 degrees.
gear_width = 9;
gear_layer_gap = 0.8;         // Use printed/metal shims between adjacent gears.
gear_layer_margin = 0.5;
mesh_extra_distance = 0.20;   // Extra centre distance for FDM backlash.

// Each stage is driver_teeth[i] -> driven_teeth[i].
driver_teeth = [18, 18, 18, 48];
driven_teeth = [54, 72, 72, 40];

// Compact external final drive used by the tracked chassis. The 0.2 mm extra
// centre distance provides initial FDM backlash without changing tooth form.
final_drive_module = 0.8;
final_drive_pinion_teeth = 20;
final_drive_axle_teeth = 48;
final_drive_width = 6;
final_drive_mesh_extra = 0.2;

// Direction from each axis to the next, in the XY plane. The wide, angled
// 48:40 final mesh keeps the output shaft clear of the preceding 72-tooth
// gear while leaving the lower plate edge aligned with the baseplate.
stage_angles = [345, 0, 0, 300];
// The alternate plate keeps the compound shafts high but places its motor
// lower and farther forward. In the mirrored chassis installation this keeps
// the two 540 cans and their rear terminals clear of one another.
alternate_stage_angles = [45, 0, 0, 300];

// Put a tooth from each driver on the shaft-centre line and a gap from the
// driven gear opposite it. This prevents the preview from placing tooth tips
// directly into each other while retaining independently printable gears.
function mesh_phases(angles) = [
    angles[0], (angles[0]+180+180/driven_teeth[0])%360,
    angles[1], (angles[1]+180+180/driven_teeth[1])%360,
    angles[2], (angles[2]+180+180/driven_teeth[2])%360,
    angles[3], (angles[3]+180+180/driven_teeth[3])%360
];
gear_phase = mesh_phases(stage_angles);

// ---------- Bearings and shafts ----------
bearing_id = 8;
bearing_od = 16;
bearing_width = 5;
bearing_pocket_d = 16.15;     // Tune with a bearing-fit coupon.
shaft_bore_d = 8.20;
shaft_d_flat_depth = 0.65;
motor_shaft_bore_d = 3.25;
motor_d_flat_depth = 0.35;
set_screw_pilot_d = 2.5;      // Drill/tap M3 after printing if required.
shaft_spacer_od = 12;
shaft_spacer_bore_d = 8.35;

// ---------- Housing ----------
plate_thickness = 5;
plate_margin = 8;
plate_corner_radius = 12;
plate_bolt_d = 4.4;           // M4 clearance.
plate_standoff_od = 10;
plate_edge_hole_inset = 10;

// 540 motor dimensions supplied for the chassis integration. The pilot and
// fastener holes include printable clearance over the nominal metal features.
motor_body_d = 35.8;
motor_body_length = 50;
motor_shaft_length = 18;
motor_shaft_d = 3.175;
motor_pilot_d = 13;
motor_pilot_length = 4.5;
motor_pilot_hole_d = 13.4;
motor_bolt_spacing = 25;
motor_bolt_hole_d = 3.4;
motor_mesh_adjustment = 1.5;  // Slots allow +/- this along the first mesh.
output_mount_bcd = 32;
output_mount_hole_d = 4.4;

// ---------- Derived dimensions ----------
function stage_ratio(i) = driven_teeth[i] / driver_teeth[i];
function product(v, i=0) = i >= len(v) ? 1 : v[i] * product(v, i+1);
stage_ratios = [for (i=[0:len(driver_teeth)-1]) stage_ratio(i)];
total_ratio = product(stage_ratios);

function gear_outer_radius(teeth) = gear_module * (teeth + 2) / 2;
function centre_distance(i) = gear_module * (driver_teeth[i] + driven_teeth[i]) / 2 + mesh_extra_distance;
function step_vector(i, angles=stage_angles) = [
    centre_distance(i) * cos(angles[i]),
    centre_distance(i) * sin(angles[i])
];
function add2(a, b) = [a[0] + b[0], a[1] + b[1]];
function subtract2(a, b) = [a[0] - b[0], a[1] - b[1]];
function build_axis_positions(angles=stage_angles, i=0, p=[0,0], acc=[[0,0]]) =
    i >= len(angles)
        ? acc
        : let(n = add2(p, step_vector(i, angles)))
          build_axis_positions(angles, i+1, n, concat(acc, [n]));

axis_positions = build_axis_positions(stage_angles); // motor, A, B, C, output
alternate_axis_positions = build_axis_positions(alternate_stage_angles);
primary_motor_from_output = subtract2(axis_positions[0], axis_positions[4]);
alternate_motor_from_output = subtract2(
    alternate_axis_positions[0],
    alternate_axis_positions[4]
);
function motor_layout_axis_separation() = norm(subtract2(
    primary_motor_from_output,
    alternate_motor_from_output
));
function motor_layout_radial_clearance() =
    motor_layout_axis_separation() - motor_body_d;
axis_radii = [
    gear_outer_radius(driver_teeth[0]),
    max([gear_outer_radius(driven_teeth[0]), gear_outer_radius(driver_teeth[1])]),
    max([gear_outer_radius(driven_teeth[1]), gear_outer_radius(driver_teeth[2])]),
    max([gear_outer_radius(driven_teeth[2]), gear_outer_radius(driver_teeth[3])]),
    gear_outer_radius(driven_teeth[3])
];

function layout_min(positions, coordinate) = min([
    for (i=[0:len(positions)-1])
        positions[i][coordinate]-axis_radii[i]
]) - plate_margin;
function layout_max(positions, coordinate) = max([
    for (i=[0:len(positions)-1])
        positions[i][coordinate]+axis_radii[i]
]) + plate_margin;

plate_min_x = layout_min(axis_positions, 0);
plate_max_x = layout_max(axis_positions, 0);
plate_min_y = layout_min(axis_positions, 1);
plate_max_y = layout_max(axis_positions, 1);
plate_size_x = plate_max_x - plate_min_x;
plate_size_y = plate_max_y - plate_min_y;
alternate_plate_min_x = layout_min(alternate_axis_positions, 0);
alternate_plate_max_x = layout_max(alternate_axis_positions, 0);
alternate_plate_min_y = layout_min(alternate_axis_positions, 1);
alternate_plate_max_y = layout_max(alternate_axis_positions, 1);
alternate_plate_size_x = alternate_plate_max_x-alternate_plate_min_x;
alternate_plate_size_y = alternate_plate_max_y-alternate_plate_min_y;

function gearbox_output_to_plate_bottom(alternate=false) =
    (alternate ? alternate_axis_positions[4][1] : axis_positions[4][1])
    - (alternate ? alternate_plate_min_y : plate_min_y);
function final_drive_centre_distance() =
    final_drive_module
    * (final_drive_pinion_teeth + final_drive_axle_teeth)/2
    + final_drive_mesh_extra;
function final_drive_ratio() =
    final_drive_axle_teeth/final_drive_pinion_teeth;
function gearbox_internal_ratio() = total_ratio;
function combined_drive_ratio() = total_ratio*final_drive_ratio();
function final_drive_pinion_outer_radius() =
    final_drive_module*(final_drive_pinion_teeth+2)/2;
function final_drive_axle_outer_radius() =
    final_drive_module*(final_drive_axle_teeth+2)/2;
function final_drive_gear_width() = final_drive_width;

assert(
    plate_size_x <= printer_usable_x
        && plate_size_y <= printer_usable_y,
    str("Primary gearbox plate exceeds the usable area of ", printer_name)
);
assert(
    alternate_plate_size_x <= printer_usable_x
        && alternate_plate_size_y <= printer_usable_y,
    str("Alternate gearbox plate exceeds the usable area of ", printer_name)
);

layer_pitch = gear_width + gear_layer_gap;
gear_stack_height = 4 * gear_width + 3 * gear_layer_gap;
inner_gap = 2 * gear_layer_margin + gear_stack_height;
gearbox_total_width = 2 * plate_thickness + inner_gap;

function layer_z(layer) = gear_layer_margin + layer * layer_pitch;
function front_spacer_length(first_layer) = layer_z(first_layer);
function between_spacer_length(first_layer, second_layer) = layer_z(second_layer) - (layer_z(first_layer) + gear_width);
function rear_spacer_length(last_layer) = inner_gap - (layer_z(last_layer) + gear_width);

// Useful console output.
echo(stage_ratios=stage_ratios);
echo(total_ratio=total_ratio);
echo(inner_gap=inner_gap, gearbox_total_width=gearbox_total_width);
echo(plate_size=[plate_size_x, plate_size_y]);
echo(alternate_plate_size=[
    alternate_plate_size_x,
    alternate_plate_size_y
]);
echo(motor_540_envelope_mm=[motor_body_d, motor_body_length]);
echo(motor_layout_axis_separation_mm=motor_layout_axis_separation());
echo(motor_layout_radial_clearance_mm=motor_layout_radial_clearance());
echo(output_to_plate_bottom_mm=gearbox_output_to_plate_bottom());
echo(final_drive_ratio=final_drive_ratio());
echo(combined_drive_ratio=combined_drive_ratio());
echo(final_drive_centre_distance_mm=final_drive_centre_distance());

// ---------- Basic shapes ----------
module rounded_rectangle_2d(x0, y0, sx, sy, r) {
    translate([x0 + r, y0 + r])
        offset(r=r)
            square([sx - 2*r, sy - 2*r]);
}

module capsule_2d(length, diameter) {
    hull() {
        translate([-length/2, 0]) circle(d=diameter);
        translate([ length/2, 0]) circle(d=diameter);
    }
}

module d_bore_2d(d, flat_depth) {
    intersection() {
        circle(d=d);
        // Retain the circle up to x = radius-flat_depth, producing one flat.
        translate([-d, -d])
            square([d + d/2 - flat_depth, 2*d]);
    }
}

module d_bore_3d(d, flat_depth, height) {
    linear_extrude(height=height)
        d_bore_2d(d, flat_depth);
}

module bearing_visual() {
    color("#2878D0")
        difference() {
            cylinder(d=bearing_od, h=bearing_width);
            translate([0,0,-0.1]) cylinder(d=bearing_id, h=bearing_width+0.2);
        }
}

module shaft_visual(length, d=8) {
    color("#17191C") cylinder(d=d, h=length);
}

// Motor mounting face is z=0. The shaft points into the gearbox along +Z and
// the 50 mm can extends away from the front plate along -Z.
module motor_540_reference() {
    color("#555D68")
        translate([0,0,-motor_body_length])
            cylinder(d=motor_body_d, h=motor_body_length);

    color("#AEB5BE") {
        cylinder(d=motor_pilot_d, h=motor_pilot_length);
        cylinder(d=motor_shaft_d, h=motor_shaft_length);
    }

    color("#17191C")
        for (y=[-motor_bolt_spacing/2, motor_bolt_spacing/2])
            translate([0,y,-1.5])
                cylinder(d=3, h=3);
}

module shaft_spacer(length) {
    if (length > 0.2)
        difference() {
            cylinder(d=shaft_spacer_od, h=length);
            translate([0,0,-0.1]) cylinder(d=shaft_spacer_bore_d, h=length+0.2);
        }
}

// ---------- Plate and housing ----------
function edge_standoff_points(min_x, max_x, min_y, max_y, positions) = [
    [min_x + plate_edge_hole_inset, min_y + plate_edge_hole_inset],
    [max_x - plate_edge_hole_inset, min_y + plate_edge_hole_inset],
    [min_x + plate_edge_hole_inset, max_y - plate_edge_hole_inset],
    [max_x - plate_edge_hole_inset, max_y - plate_edge_hole_inset],
    [(min_x + max_x)/2, min_y + plate_edge_hole_inset],
    // The geometric edge midpoint crosses the large B gear. Put this support
    // in the valley between the B and C gear envelopes instead, close enough
    // to the plate edge to preserve working clearance on both sides.
    [(positions[2][0] + positions[3][0])/2,
        max_y - 6],
    [min_x + plate_edge_hole_inset, (min_y + max_y)/2],
    // The geometric side midpoint crosses the large C gear. Move the support
    // beside the smaller output gear, outside its tooth envelope.
    [max_x - plate_edge_hole_inset, positions[4][1] + 24]
];

standoff_points = edge_standoff_points(
    plate_min_x,
    plate_max_x,
    plate_min_y,
    plate_max_y,
    axis_positions
);
alternate_standoff_points = edge_standoff_points(
    alternate_plate_min_x,
    alternate_plate_max_x,
    alternate_plate_min_y,
    alternate_plate_max_y,
    alternate_axis_positions
);

module plate_2d(front=true, alternate=false) {
    positions = alternate ? alternate_axis_positions : axis_positions;
    angles = alternate ? alternate_stage_angles : stage_angles;
    min_x = alternate ? alternate_plate_min_x : plate_min_x;
    max_x = alternate ? alternate_plate_max_x : plate_max_x;
    min_y = alternate ? alternate_plate_min_y : plate_min_y;
    max_y = alternate ? alternate_plate_max_y : plate_max_y;
    size_x = max_x-min_x;
    size_y = max_y-min_y;
    points = alternate ? alternate_standoff_points : standoff_points;

    difference() {
        rounded_rectangle_2d(
            min_x,
            min_y,
            size_x,
            size_y,
            plate_corner_radius
        );

        // M4 housing/standoff holes.
        for (p = points)
            translate(p) circle(d=plate_bolt_d);

        // One 688 bearing for each rotating 8 mm shaft A/B/C/output.
        for (i=[1:4])
            translate(positions[i]) circle(d=bearing_pocket_d);

        if (!front)
            translate(positions[4])
                for (angle=[45:90:315])
                    translate([
                        output_mount_bcd/2*cos(angle),
                        output_mount_bcd/2*sin(angle)
                    ]) circle(d=output_mount_hole_d);

        if (front) {
            // Motor boss and shaft clearance.
            translate(positions[0]) circle(d=motor_pilot_hole_d);

            // Two adjustable motor mounting slots.
            translate(positions[0])
                rotate(angles[0])
                    for (y=[-motor_bolt_spacing/2, motor_bolt_spacing/2])
                        translate([0,y])
                            capsule_2d(2*motor_mesh_adjustment, motor_bolt_hole_d);
        }
    }
}

module front_plate(alternate=false) {
    linear_extrude(height=plate_thickness)
        plate_2d(front=true, alternate=alternate);
}

module rear_plate(alternate=false) {
    linear_extrude(height=plate_thickness)
        plate_2d(front=false, alternate=alternate);
}

module housing_spacer() {
    difference() {
        cylinder(d=plate_standoff_od, h=inner_gap);
        translate([0,0,-0.1]) cylinder(d=plate_bolt_d, h=inner_gap+0.2);
    }
}

// ---------- Printable gears ----------
module shaft_herringbone_gear(teeth, helix_sign, phase=0, bore_d=shaft_bore_d, flat_depth=shaft_d_flat_depth) {
    rotate([0,0,phase])
        difference() {
            herringbone_gear(
                modul=gear_module,
                tooth_number=teeth,
                width=gear_width,
                bore=bore_d,
                pressure_angle=pressure_angle,
                helix_angle=helix_sign * helix_angle,
                optimized=false
            );

            translate([0,0,-0.1])
                d_bore_3d(d=bore_d, flat_depth=flat_depth, height=gear_width+0.2);

            // Optional pilot for an M3 grub screw. It exits one side only.
            translate([0,0,gear_width/2])
                rotate([0,90,0])
                    cylinder(d=set_screw_pilot_d, h=gear_outer_radius(teeth)+1);
        }
}

module motor_pinion(phase=gear_phase[0]) {
    shaft_herringbone_gear(
        teeth=driver_teeth[0],
        helix_sign=1,
        phase=phase,
        bore_d=motor_shaft_bore_d,
        flat_depth=motor_d_flat_depth
    );
}

module gear_a0(phase=gear_phase[1]) { shaft_herringbone_gear(driven_teeth[0], -1, phase); }
module gear_a1(phase=gear_phase[2]) { shaft_herringbone_gear(driver_teeth[1],  1, phase); }
module gear_b1(phase=gear_phase[3]) { shaft_herringbone_gear(driven_teeth[1], -1, phase); }
module gear_b2(phase=gear_phase[4]) { shaft_herringbone_gear(driver_teeth[2],  1, phase); }
module gear_c2(phase=gear_phase[5]) { shaft_herringbone_gear(driven_teeth[2], -1, phase); }
module gear_c3(phase=gear_phase[6]) { shaft_herringbone_gear(driver_teeth[3],  1, phase); }
module output_gear(phase=gear_phase[7]) { shaft_herringbone_gear(driven_teeth[3], -1, phase); }

module centred_final_drive_gear(teeth, helix_sign, phase=0) {
    rotate([0,0,phase])
        translate([0,0,-final_drive_width/2])
            difference() {
                herringbone_gear(
                    modul=final_drive_module,
                    tooth_number=teeth,
                    width=final_drive_width,
                    bore=shaft_bore_d,
                    pressure_angle=pressure_angle,
                    helix_angle=helix_sign*helix_angle,
                    optimized=false
                );

                translate([0,0,-0.1])
                    d_bore_3d(
                        d=shaft_bore_d,
                        flat_depth=shaft_d_flat_depth,
                        height=final_drive_width+0.2
                    );
            }
}

module final_drive_pinion() {
    centred_final_drive_gear(final_drive_pinion_teeth, 1);
}

module final_drive_axle_gear() {
    centred_final_drive_gear(
        final_drive_axle_teeth,
        -1,
        180/final_drive_axle_teeth
    );
}

// ---------- Internal shaft spacers ----------
module spacer_a_front()  { shaft_spacer(front_spacer_length(0)); }
module spacer_a_middle() { shaft_spacer(between_spacer_length(0,1)); }
module spacer_a_rear()   { shaft_spacer(rear_spacer_length(1)); }

module spacer_b_front()  { shaft_spacer(front_spacer_length(1)); }
module spacer_b_middle() { shaft_spacer(between_spacer_length(1,2)); }
module spacer_b_rear()   { shaft_spacer(rear_spacer_length(2)); }

module spacer_c_front()  { shaft_spacer(front_spacer_length(2)); }
module spacer_c_middle() { shaft_spacer(between_spacer_length(2,3)); }
module spacer_c_rear()   { shaft_spacer(rear_spacer_length(3)); }

module spacer_d_front()  { shaft_spacer(front_spacer_length(3)); }
module spacer_d_rear()   { shaft_spacer(rear_spacer_length(3)); }

module spacer_set() {
    gap = shaft_spacer_od + 4;
    translate([0*gap,0,0]) spacer_a_front();
    translate([1*gap,0,0]) spacer_a_middle();
    translate([2*gap,0,0]) spacer_a_rear();
    translate([3*gap,0,0]) spacer_b_front();
    translate([4*gap,0,0]) spacer_b_middle();
    translate([5*gap,0,0]) spacer_b_rear();
    translate([6*gap,0,0]) spacer_c_front();
    translate([7*gap,0,0]) spacer_c_middle();
    translate([8*gap,0,0]) spacer_c_rear();
    translate([9*gap,0,0]) spacer_d_front();
    translate([10*gap,0,0]) spacer_d_rear();
}

// ---------- Assembly helpers ----------
module bearing_pair_at(p) {
    if (show_bearings) {
        translate([p[0], p[1], (plate_thickness-bearing_width)/2])
            bearing_visual();
        translate([p[0], p[1], plate_thickness+inner_gap+(plate_thickness-bearing_width)/2])
            bearing_visual();
    }
}

module place_gear(
    axis_index,
    layer,
    colour=[0.86,0.55,0.16],
    positions=axis_positions
) {
    color(colour)
        translate([
            positions[axis_index][0],
            positions[axis_index][1],
            plate_thickness + layer_z(layer)
        ]) children();
}

module spacer_segment_at(
    axis_index,
    z_inside,
    length,
    positions=axis_positions
) {
    if (show_internal_spacers && length > 0.2)
        color([0.75,0.75,0.72])
            translate([
                positions[axis_index][0],
                positions[axis_index][1],
                plate_thickness + z_inside
            ]) shaft_spacer(length);
}

module gearbox_assembly(alternate=false) {
    positions = alternate ? alternate_axis_positions : axis_positions;
    points = alternate ? alternate_standoff_points : standoff_points;
    phases = mesh_phases(
        alternate ? alternate_stage_angles : stage_angles
    );

    // Plates.
	plate_alpha = 0.7;
    if (show_plates) {
        color([0.20, 0.45, 0.75, plate_alpha]) front_plate(alternate);
        color([0.20, 0.45, 0.75, plate_alpha])
            translate([0,0,plate_thickness+inner_gap+explode])
                rear_plate(alternate);
    }

    // Housing standoffs.
    color([0.25,0.25,0.25])
        for (p=points)
            translate([p[0],p[1],plate_thickness]) housing_spacer();

    // Shafts and bearings.
    for (i=[1:4]) {
        bearing_pair_at(positions[i]);
        if (show_shafts)
            translate([
                positions[i][0],
                positions[i][1],
                0
            ]) shaft_visual(
                // The output extends past the rear plate into the dedicated
                // final-drive bay between the housing and chassis rail.
                i == 4 ? gearbox_total_width+6.5 : gearbox_total_width,
                d=bearing_id
            );
    }

    // Gear layers.
    place_gear(0, 0, [0.82,0.36,0.18], positions) motor_pinion(phases[0]);
    place_gear(1, 0, positions=positions) gear_a0(phases[1]);
    place_gear(1, 1, positions=positions) gear_a1(phases[2]);
    place_gear(2, 1, positions=positions) gear_b1(phases[3]);
    place_gear(2, 2, positions=positions) gear_b2(phases[4]);
    place_gear(3, 2, positions=positions) gear_c2(phases[5]);
    place_gear(3, 3, positions=positions) gear_c3(phases[6]);
    place_gear(4, 3, [0.82,0.36,0.18], positions) output_gear(phases[7]);

    // Spacer sleeves locate gears axially between the bearing inner faces.
    spacer_segment_at(1, 0, front_spacer_length(0), positions);
    spacer_segment_at(1, layer_z(0)+gear_width, between_spacer_length(0,1), positions);
    spacer_segment_at(1, layer_z(1)+gear_width, rear_spacer_length(1), positions);

    spacer_segment_at(2, 0, front_spacer_length(1), positions);
    spacer_segment_at(2, layer_z(1)+gear_width, between_spacer_length(1,2), positions);
    spacer_segment_at(2, layer_z(2)+gear_width, rear_spacer_length(2), positions);

    spacer_segment_at(3, 0, front_spacer_length(2), positions);
    spacer_segment_at(3, layer_z(2)+gear_width, between_spacer_length(2,3), positions);
    spacer_segment_at(3, layer_z(3)+gear_width, rear_spacer_length(3), positions);

    spacer_segment_at(4, 0, front_spacer_length(3), positions);
    spacer_segment_at(4, layer_z(3)+gear_width, rear_spacer_length(3), positions);
}

module internal_gear_collision_for_layout(alternate=false) {
    positions = alternate ? alternate_axis_positions : axis_positions;
    phases = mesh_phases(
        alternate ? alternate_stage_angles : stage_angles
    );

    union() {
        intersection() {
            place_gear(0,0,positions=positions) motor_pinion(phases[0]);
            place_gear(1,0,positions=positions) gear_a0(phases[1]);
        }
        intersection() {
            place_gear(1,1,positions=positions) gear_a1(phases[2]);
            place_gear(2,1,positions=positions) gear_b1(phases[3]);
        }
        intersection() {
            place_gear(2,2,positions=positions) gear_b2(phases[4]);
            place_gear(3,2,positions=positions) gear_c2(phases[5]);
        }
        intersection() {
            place_gear(3,3,positions=positions) gear_c3(phases[6]);
            place_gear(4,3,positions=positions) output_gear(phases[7]);
        }
    }
}

module internal_gear_collision() {
    internal_gear_collision_for_layout(false);
    translate([300,0,0]) internal_gear_collision_for_layout(true);
}

module gear_axis_for_layout(axis_index, alternate=false) {
    positions = alternate ? alternate_axis_positions : axis_positions;
    phases = mesh_phases(
        alternate ? alternate_stage_angles : stage_angles
    );

    if (axis_index == 0)
        place_gear(0,0,positions=positions) motor_pinion(phases[0]);
    else if (axis_index == 1) {
        place_gear(1,0,positions=positions) gear_a0(phases[1]);
        place_gear(1,1,positions=positions) gear_a1(phases[2]);
    } else if (axis_index == 2) {
        place_gear(2,1,positions=positions) gear_b1(phases[3]);
        place_gear(2,2,positions=positions) gear_b2(phases[4]);
    } else if (axis_index == 3) {
        place_gear(3,2,positions=positions) gear_c2(phases[5]);
        place_gear(3,3,positions=positions) gear_c3(phases[6]);
    } else if (axis_index == 4)
        place_gear(4,3,positions=positions) output_gear(phases[7]);
}

module all_gears_for_layout(alternate=false) {
    for (axis_index=[0:4])
        gear_axis_for_layout(axis_index, alternate);
}

module housing_standoff_gear_collision_for_layout(alternate=false) {
    points = alternate ? alternate_standoff_points : standoff_points;

    intersection() {
        union()
            for (p=points)
                translate([p[0],p[1],plate_thickness])
                    cylinder(d=plate_standoff_od, h=inner_gap);
        all_gears_for_layout(alternate);
    }
}

module housing_standoff_gear_collision() {
    housing_standoff_gear_collision_for_layout(false);
    translate([300,0,0])
        housing_standoff_gear_collision_for_layout(true);
}

module shaft_other_gear_collision_for_layout(alternate=false) {
    positions = alternate ? alternate_axis_positions : axis_positions;

    union()
        for (shaft_axis=[1:4])
            intersection() {
                translate([
                    positions[shaft_axis][0],
                    positions[shaft_axis][1],
                    0
                ]) cylinder(
                    d=bearing_id,
                    h=shaft_axis == 4
                        ? gearbox_total_width+6.5
                        : gearbox_total_width
                );
                union()
                    for (gear_axis=[0:4])
                        if (gear_axis != shaft_axis)
                            gear_axis_for_layout(gear_axis, alternate);
            }
}

module shaft_other_gear_collision() {
    shaft_other_gear_collision_for_layout(false);
    translate([300,0,0]) shaft_other_gear_collision_for_layout(true);
}

module gearbox_drive_unit(show_motor=true, alternate=false) {
    positions = alternate ? alternate_axis_positions : axis_positions;
    gearbox_assembly(alternate);
    if (show_motor)
        translate([
            positions[0][0],
            positions[0][1],
            0
        ]) motor_540_reference();
}

// The output shaft becomes the local origin for chassis placement. Mirroring
// the complete train produces the opposite-side plate layout while retaining
// the same output axis and reusable rotational gear parts.
module gearbox_drive_unit_output_origin(
    mirrored=false,
    show_motor=true,
    alternate=false
) {
    positions = alternate ? alternate_axis_positions : axis_positions;
    if (mirrored)
        mirror([0,1,0])
            translate([
                -positions[4][0],
                -positions[4][1],
                0
            ]) gearbox_drive_unit(show_motor, alternate);
    else
        translate([
            -positions[4][0],
            -positions[4][1],
            0
        ]) gearbox_drive_unit(show_motor, alternate);
}

// Smooth, slightly oversized solids for body-aperture and collision fixtures.
// This intentionally ignores teeth and small holes while preserving the true
// shaft positions and axial layer stack.
module gearbox_clearance_envelope(clearance=1, alternate=false) {
    positions = alternate ? alternate_axis_positions : axis_positions;
    points = alternate ? alternate_standoff_points : standoff_points;
    min_x = alternate ? alternate_plate_min_x : plate_min_x;
    min_y = alternate ? alternate_plate_min_y : plate_min_y;
    size_x = alternate ? alternate_plate_size_x : plate_size_x;
    size_y = alternate ? alternate_plate_size_y : plate_size_y;

    for (z=[-clearance, plate_thickness+inner_gap-clearance])
        translate([0,0,z])
            linear_extrude(height=plate_thickness+2*clearance)
                offset(delta=clearance)
                    rounded_rectangle_2d(
                        min_x,
                        min_y,
                        size_x,
                        size_y,
                        plate_corner_radius
                    );

    for (i=[0:4])
        translate([
            positions[i][0],
            positions[i][1],
            -clearance
        ]) cylinder(
            r=axis_radii[i]+clearance,
            h=gearbox_total_width+2*clearance
        );

    for (p=points)
        translate([p[0],p[1],-clearance])
            cylinder(
                d=plate_standoff_od+2*clearance,
                h=gearbox_total_width+2*clearance
            );

    translate([
        positions[0][0],
        positions[0][1],
        -motor_body_length-clearance
    ]) cylinder(
        d=motor_body_d+2*clearance,
        h=motor_body_length+2*clearance
    );
}

module gearbox_clearance_output_origin(
    mirrored=false,
    clearance=1,
    alternate=false
) {
    positions = alternate ? alternate_axis_positions : axis_positions;
    if (mirrored)
        mirror([0,1,0])
            translate([
                -positions[4][0],
                -positions[4][1],
                0
            ]) gearbox_clearance_envelope(clearance, alternate);
    else
        translate([
            -positions[4][0],
            -positions[4][1],
            0
        ]) gearbox_clearance_envelope(clearance, alternate);
}

module gear_set() {
    gap = 8;
    x0 = 0;
    translate([x0,0,0]) motor_pinion();
    translate([35,0,0]) gear_a0();
    translate([105,0,0]) gear_a1();
    translate([145,0,0]) gear_b1();
    translate([235,0,0]) gear_b2();
    translate([275,0,0]) gear_c2();
    translate([365,0,0]) gear_c3();
    translate([430,0,0]) output_gear();
}

module print_layout() {
    // Inspection only: the two plates together exceed one X1C bed.
    translate([-plate_min_x, -plate_min_y, 0]) front_plate();
    translate([plate_size_x + 12 - plate_min_x, -plate_min_y, 0]) rear_plate();

    translate([0, plate_size_y + 20, 0]) gear_set();
    translate([0, plate_size_y + 120, 0]) spacer_set();
}

// ---------- Render selected part ----------
if (part == "assembly") {
    gearbox_assembly();
} else if (part == "assembly_alternate") {
    gearbox_assembly(true);
} else if (part == "drive_unit") {
    gearbox_drive_unit_output_origin(false, true);
} else if (part == "drive_unit_mirrored") {
    gearbox_drive_unit_output_origin(true, true);
} else if (part == "drive_unit_alternate") {
    gearbox_drive_unit_output_origin(true, true, true);
} else if (part == "motor_540") {
    motor_540_reference();
} else if (part == "front_plate") {
    front_plate();
} else if (part == "rear_plate") {
    rear_plate();
} else if (part == "front_plate_alternate") {
    front_plate(true);
} else if (part == "rear_plate_alternate") {
    rear_plate(true);
} else if (part == "motor_pinion") {
    motor_pinion();
} else if (part == "gear_a0") {
    gear_a0();
} else if (part == "gear_a1") {
    gear_a1();
} else if (part == "gear_b1") {
    gear_b1();
} else if (part == "gear_b2") {
    gear_b2();
} else if (part == "gear_c2") {
    gear_c2();
} else if (part == "gear_c3") {
    gear_c3();
} else if (part == "output_gear") {
    output_gear();
} else if (part == "final_drive_pinion") {
    final_drive_pinion();
} else if (part == "final_drive_axle_gear") {
    final_drive_axle_gear();
} else if (part == "internal_gear_collision") {
    internal_gear_collision();
} else if (part == "housing_standoff_gear_collision") {
    housing_standoff_gear_collision();
} else if (part == "shaft_other_gear_collision") {
    shaft_other_gear_collision();
} else if (part == "spacer_set") {
    spacer_set();
} else if (part == "housing_spacer") {
    housing_spacer();
} else if (part == "gear_set") {
    gear_set();
} else if (part == "print_layout") {
    print_layout();
}
