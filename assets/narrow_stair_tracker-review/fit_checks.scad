// Review-only fixtures built from the actual printable modules.
use <../narrow_stair_tracker.scad>

$fn = 64;
fixture = "link_pair";

track_pitch = 30;
hinge_outer_d = 9;
sprocket_teeth = 11;
sprocket_pitch_radius = track_pitch / (2 * sin(180 / sprocket_teeth));

module link_pair() {
    color("orange") track_link(true);
    color("gold") translate([track_pitch, 0, 0]) track_link(true);

    // Nominal 3 mm pin through the shared hinge axis.
    color("silver")
        translate([track_pitch / 2, 0, hinge_outer_d / 2])
            rotate([90, 0, 0])
                cylinder(h=60, d=3, center=true);
}

module engaged_link() {
    translate([0, 0, sprocket_pitch_radius - hinge_outer_d / 2])
        track_link(true);
}

module sprocket_fit() {
    color("slategray") sprocket();
    color("orange", 0.65) engaged_link();

    // Any geometry here is a hard collision at nominal pitch radius.
    translate([130, 0, 0])
        color("red")
            intersection() {
                sprocket();
                engaged_link();
            }
}

if (fixture == "link_pair") link_pair();
else if (fixture == "sprocket_fit") sprocket_fit();
else assert(false, str("Unknown fixture: ", fixture));
