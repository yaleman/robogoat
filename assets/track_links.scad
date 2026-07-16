/*
  Standalone pinned track links
  -----------------------------
  One identical link is repeated to form a track. The front end has two outer
  knuckles and the rear end has one centre knuckle. Adjacent links share a
  3 mm steel pin or M3 fastener.

  Print orientation: tread up, flat inner pad face on the build plate.
*/

$fn = 72;

// link, straight_pair, bent_pair, six_link_plate, cog_reference,
// cog_engagement, dimensions, straight_collision, bend_collision,
// cog_collision, pin_reference
part = "link";

// ---------- primary parameters ----------
track_width = 55;
pitch = 30;
pad_thickness = 7;

barrel_od = 10;
hinge_z = barrel_od / 2;

pin_d = 3;
pin_bore_d = 3.4;
pin_end_overhang = 2;

centre_knuckle_length = 17;
knuckle_clearance = 0.5;
outer_knuckle_length =
    (track_width - centre_knuckle_length - 2 * knuckle_clearance) / 2;

core_end_clearance = 0.3;
core_body_length = pitch - barrel_od - 2 * core_end_clearance;
connector_overlap = 1;
connector_length =
    pitch / 2 - core_body_length / 2 + connector_overlap;

grouser_height = 3.5;
grouser_width = track_width - 4;
grouser_length = 5;
grouser_spacing = 15;
grouser_overlap = 0.4;

// A cog tooth enters this opening from the wheel side. Keeping it open through
// the tread prevents the radial collision that a blind pocket would create.
drive_window_tangent = 10;
drive_window_width = 16;

reference_tooth_tangent_root = 8;
reference_tooth_tangent_tip = 5;
reference_tooth_width = 14;
reference_tooth_radial = 10;
reference_tooth_inset = 3.5;
reference_cog_body_inset = 7.5;

// A pinned link bends this much around an 11-tooth pitch circle.
design_sprocket_teeth = 11;
design_bend_angle = 360 / design_sprocket_teeth;

assert(pin_bore_d > pin_d, "Pin bore must be larger than the pin");
assert(barrel_od > pin_bore_d + 4, "Hinge barrel wall is too thin");
assert(outer_knuckle_length > 0, "Knuckle lengths must be positive");
assert(connector_overlap > 0, "Connector overlap must be positive");
assert(
    drive_window_tangent > reference_tooth_tangent_root &&
    drive_window_width > reference_tooth_width,
    "The drive window must clear the reference cog tooth"
);
assert(
    reference_tooth_tangent_root > reference_tooth_tangent_tip,
    "Cog tooth tip must be narrower than its root"
);

// ---------- geometry ----------
module barrel(x, y, length) {
    translate([x, y, hinge_z])
        rotate([90, 0, 0])
            cylinder(h=length, d=barrel_od, center=true);
}

module pin_bore(x) {
    translate([x, 0, hinge_z])
        rotate([90, 0, 0])
            cylinder(h=track_width + 2, d=pin_bore_d, center=true);
}

module tread_ribs() {
    for (x = [-grouser_spacing / 2, grouser_spacing / 2])
        translate([
            x,
            0,
            pad_thickness + grouser_height / 2 - grouser_overlap / 2
        ])
            cube([
                grouser_length,
                grouser_width,
                grouser_height + grouser_overlap
            ], center=true);
}

module connector(x, y, width) {
    translate([x, y, pad_thickness / 2])
        cube([connector_length, width, pad_thickness], center=true);
}

module track_link() {
    outer_y = track_width / 2 - outer_knuckle_length / 2;

    difference() {
        union() {
            // Wheel-side face sits at z=0 for support-free printing.
            translate([0, 0, pad_thickness / 2])
                cube([core_body_length, track_width, pad_thickness], center=true);

            tread_ribs();

            // Front: two female outer knuckles.
            for (side = [-1, 1]) {
                barrel(
                    pitch / 2,
                    side * outer_y,
                    outer_knuckle_length
                );
                connector(
                    core_body_length / 2 - connector_overlap + connector_length / 2,
                    side * outer_y,
                    outer_knuckle_length
                );
            }

            // Rear: one male centre knuckle.
            barrel(-pitch / 2, 0, centre_knuckle_length);
            connector(
                -core_body_length / 2 + connector_overlap - connector_length / 2,
                0,
                centre_knuckle_length
            );
        }

        // Cut through the complete width so every knuckle is coaxial.
        pin_bore(-pitch / 2);
        pin_bore(pitch / 2);

        // Through-window for a cog tooth. It is deliberately not a blind
        // pocket: the future tooth may pass through without hitting a roof.
        translate([0, 0, (pad_thickness + grouser_height) / 2])
            cube([
                drive_window_tangent,
                drive_window_width,
                pad_thickness + grouser_height + 2
            ], center=true);
    }
}

module pin_reference() {
    color("silver")
        rotate([90, 0, 0])
            cylinder(
                h=track_width + 2 * pin_end_overhang,
                d=pin_d,
                center=true
            );
}

module second_link(angle=0) {
    shared_axis = [pitch / 2, 0, hinge_z];

    translate(shared_axis)
        rotate([0, -angle, 0])
            translate(-shared_axis)
                translate([pitch, 0, 0])
                    track_link();
}

module link_pair(angle=0, show_pin=true) {
    color("darkorange") track_link();
    color("gold") second_link(angle);

    if (show_pin)
        translate([pitch / 2, 0, hinge_z]) pin_reference();
}

module six_link_plate() {
    x_step = 46;
    y_step = track_width + 7;

    for (row = [-0.5, 0.5])
        for (column = [-1, 0, 1])
            translate([column * x_step, row * y_step, 0])
                track_link();
}

module tapered_cog_tooth() {
    radial_half = reference_tooth_radial / 2;
    width_half = reference_tooth_width / 2;
    root_half = reference_tooth_tangent_root / 2;
    tip_half = reference_tooth_tangent_tip / 2;

    // Local X is radial, Y is across the track, and Z is tangential. The
    // narrower outer face gives symmetric lead-in and lead-out ramps, so the
    // same wheel geometry works in forward and reverse.
    polyhedron(
        points=[
            [-radial_half, -width_half, -root_half],
            [-radial_half,  width_half, -root_half],
            [-radial_half,  width_half,  root_half],
            [-radial_half, -width_half,  root_half],
            [ radial_half, -width_half, -tip_half],
            [ radial_half,  width_half, -tip_half],
            [ radial_half,  width_half,  tip_half],
            [ radial_half, -width_half,  tip_half]
        ],
        faces=[
            [0, 3, 2, 1],
            [4, 5, 6, 7],
            [0, 1, 5, 4],
            [3, 7, 6, 2],
            [0, 4, 7, 3],
            [1, 2, 6, 5]
        ],
        convexity=4
    );
}

module cog_reference() {
    pitch_radius = pitch / (2 * sin(180 / design_sprocket_teeth));
    tooth_centre_radius = pitch_radius - reference_tooth_inset;
    body_radius = pitch_radius - reference_cog_body_inset;

    difference() {
        union() {
            rotate([90, 0, 0])
                cylinder(h=reference_tooth_width, r=body_radius, center=true);

            // Offset the pattern so the engagement fixture has one tooth
            // exactly on its vertical centreline.
            for (step = [0 : design_sprocket_teeth - 1])
                let(angle = 90 + step * 360 / design_sprocket_teeth)
                translate([
                    tooth_centre_radius * cos(angle),
                    0,
                    tooth_centre_radius * sin(angle)
                ])
                    rotate([0, -angle, 0])
                        tapered_cog_tooth();
        }

        rotate([90, 0, 0])
            cylinder(h=reference_tooth_width + 2, d=8.2, center=true);
    }
}

module engaged_link() {
    pitch_radius = pitch / (2 * sin(180 / design_sprocket_teeth));

    translate([0, 0, pitch_radius - hinge_z])
        track_link();
}

module cog_engagement() {
    color("slategray") cog_reference();
    color("darkorange") engaged_link();
}

module straight_collision() {
    intersection() {
        track_link();
        second_link(0);
    }
}

module bend_collision(angle=design_bend_angle) {
    intersection() {
        track_link();
        second_link(angle);
    }
}

module cog_collision() {
    intersection() {
        cog_reference();
        engaged_link();
    }
}

module dimensions() {
    echo("track_width_mm", track_width);
    echo("pin_pitch_mm", pitch);
    echo("overall_link_length_mm", pitch + barrel_od);
    echo("pad_body_length_mm", core_body_length);
    echo("core_end_clearance_mm", core_end_clearance);
    echo("link_height_mm", pad_thickness + grouser_height);
    echo("pin_bore_mm", pin_bore_d);
    echo("pin_mm", pin_d);
    echo("diametral_pin_clearance_mm", pin_bore_d - pin_d);
    echo("knuckle_clearance_each_side_mm", knuckle_clearance);
    echo("barrel_wall_radial_mm", (barrel_od - pin_bore_d) / 2);
    echo("connector_overlap_mm", connector_overlap);
    echo("drive_window_mm", [drive_window_tangent, drive_window_width]);
    echo("reference_cog_tooth_mm", [
        reference_tooth_tangent_root,
        reference_tooth_tangent_tip,
        reference_tooth_width,
        reference_tooth_radial
    ]);
    echo("reference_tooth_flank_angle_deg",
         atan((reference_tooth_tangent_root - reference_tooth_tangent_tip) /
              (2 * reference_tooth_radial)));
    echo("reference_tooth_root_overlap_mm",
         body_radius_for_echo() -
         (pitch_radius_for_echo() - reference_tooth_inset - reference_tooth_radial / 2));
    echo("design_bend_angle_deg", design_bend_angle);
}

function pitch_radius_for_echo() =
    pitch / (2 * sin(180 / design_sprocket_teeth));
function body_radius_for_echo() =
    pitch_radius_for_echo() - reference_cog_body_inset;

// ---------- output ----------
if (part == "link") track_link();
else if (part == "straight_pair") link_pair(0, true);
else if (part == "bent_pair") link_pair(design_bend_angle, true);
else if (part == "six_link_plate") six_link_plate();
else if (part == "cog_reference") cog_reference();
else if (part == "cog_engagement") cog_engagement();
else if (part == "dimensions") dimensions();
else if (part == "straight_collision") straight_collision();
else if (part == "bend_collision") bend_collision();
else if (part == "cog_collision") cog_collision();
else if (part == "pin_reference") pin_reference();
else assert(false, str("Unknown part selector: ", part));
