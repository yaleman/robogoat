# Narrow stair tracker — OpenSCAD prototype

This is an original, parametric tracked chassis inspired by the general layout
of RCTestFlight's Snow Tank. It is **not** a scaled copy of the original STL
geometry.

## Default dimensions

- Overall width: approximately **340 mm**
- Track width: **55 mm** per side
- Chassis width between track pods: **214 mm**
- Track contact length / wheelbase: **390 mm**
- Approximate overall length: **526 mm**
- Sprocket pitch diameter: approximately **106.5 mm**
- Track links: **37 per side**

The 340 mm overall width is almost exactly two-thirds of the roughly 508 mm
width previously discussed for the larger Snowcat-style platform.

## Track and cog integration

The chassis imports `track_link()` and `cog_reference()` from
`track_links.scad`; the standalone link file is the source of truth for their
printable geometry. The old simplified rectangular assembly links and the old
straight-sided sprocket teeth have been removed.

The integrated system uses:

- identical 55 mm-wide links joined by 3 mm metal pins
- 30 mm hinge and cog pitch
- a central 10 x 16 mm through-window in every link
- an 11-tooth cog with chord-correct pitch geometry
- tapered, symmetric tooth faces so the cog can enter and leave the window in
  either direction
- 37 actual detailed links on each side of the assembly

## Christie road-wheel suspension

Each track now has three 70 mm-diameter support idlers at longitudinal positions
-110, 0, and +110 mm. Every idler is centred across the 55 mm track width. Their
axles sit at z = 53.758 mm, placing the wheel tangent at z = 18.758 mm against
the wheel-side face of the straight lower track run.

Each road wheel is carried by an independent Christie-style suspension unit:

- 55 mm horizontal trailing/bellcrank arm
- 6.2 mm hull-pivot bore in the rail's lower structural web
- wheel axle at the arm tip
- vertical spring pickup 60% of the way from pivot to wheel axle
- cross-pin and lower clevis connecting the offset pickup to the spring seat
- 56.242 mm nominal vertical spring envelope
- upper spring bracket cross-bolted through the rail's upper structural web

When a wheel rises, its arm rotates upward about the hull pivot. The intermediate
pickup rises by 60% of the wheel's small-angle travel and compresses the vertical
spring. The neutral model keeps the three wheels tangent to the straight lower
track run.

The arms sit immediately inboard of the wheels. The springs sit between the arms
and hull rails. Nominal static clearances are 3 mm arm-to-wheel, 1 mm
arm-to-hub, 1.5 mm spring-cap-to-rail, 4 mm spring-cap-to-wheel, and 3.242 mm
between the upper mount and top track.

The coil and central guide in the model are an **envelope and motion reference**,
not a printable load-bearing spring. Use a real steel compression spring with a
proper guide or damper, retained seats, and bump stops selected from the final
vehicle mass and required wheel travel.

The loop is generated from link-centre positions around the pitch circle. The
reported adjacent-centre spacing is 30.000 to 30.077 mm; the small maximum
variation occurs at a straight-to-wrap transition.

Four diagnostic selectors are available:

- `drive_collision`: cog against the seven links around the rear drive wrap
- `idler_collision`: idler against the eight links around the front wrap
- `support_idler_collision`: three lower support idlers against the 13 links in
  the straight lower run, with a 0.01 mm allowance that excludes the shared
  tangent edge and reports only volumetric penetration
- `suspension_clearance_collision`: the arms and springs against the tracks,
  road wheels, end wheels, and hull rail

All four are expected to render as an empty object. A non-empty result means
that one of the checked components has solid interference beyond the documented
tangent allowance.

## X1C printability

The default parts are split so their nominal XY footprints fit within a
256 x 256 mm bed:

- Rail half: approximately 235 x 86 mm when laid flat
- Floor half: 230 x 208 mm
- Crossmember: 214 x 28 mm
- Sprocket/idler: under 120 mm diameter
- Track link: 40 x 55 mm including hinge barrels

Reorient rail, gearbox, and motor plates flat before slicing.

## Exporting parts

Edit the `part` variable near the top of `narrow_stair_tracker.scad`:

```scad
part = "track_link";
```

Available values:

- `assembly`
- `track_link`
- `sprocket`
- `idler`
- `support_idler`
- `christie_arm`
- `spring_clevis`
- `vertical_spring`
- `suspension_unit`
- `rail_front`
- `rail_rear`
- `crossmember`
- `floor_front`
- `floor_rear`
- `motor_plate`
- `gearbox_plate`
- `drive_collision`
- `idler_collision`
- `support_idler_collision`
- `suspension_clearance_collision`
- `dimensions`

Render with F6, then export the selected part as STL.

## Important prototype checks

Do these before printing a complete set:

1. Print two track links and test the hinge with the intended 3 mm pin material.
2. Print one sprocket and six to eight links, then verify pitch and tooth
   engagement around half the sprocket in both directions.
3. Tune the link clearances in `track_links.scad` and `bearing_od` in the chassis
   model for the actual filament and printer profile.
4. Build one complete track pod and turn it by hand under load before installing
   motors.
5. Add a real axle and pin-retention method plus metal bearing spacers. The model
   only provides nominal bores.
6. Print one arm and mock the spring envelope before producing all six units;
   verify the hub, rail, upper-track, and fastener clearances on the assembled
   track pod.
7. Weigh the completed robot and calculate the spring rate, preload, damping,
   bump stop, and maximum arm angle before powered stair testing.

## Materials

A sensible first build would use:

- Track links: PA6-CF, PAHT-CF, or tough PETG/ASA for cheap iteration
- Sprocket and idlers: PA-CF or PC; avoid ordinary PLA for loaded final parts
- Suspension arms and upper mounts: PA-CF or machined metal after prototype fit
- Suspension springs and pivot/axle pins: steel hardware, not printed substitutes
- Frame rails and floor: ASA, PC, or PA-CF
- Optional traction pads: separate TPU inserts or bonded TPU strips
- Hinge pins: 3 mm stainless rod or cut-down machine screws
- Main axles: 8 mm steel
- Bearings: 608-series as a starting point, subject to final shaft design

## Drivetrain status

The model includes a generic 42 mm brushless motor plate and gearbox side plate,
but **does not contain a validated reduction gearbox**. A low-KV outrunner still
needs substantial reduction for controlled stair climbing. Treat the motor and
gearbox geometry as an interface placeholder, not a finished transmission.

For the next iteration, choose the actual motor, battery voltage, desired track
speed, and reduction method first. Those determine shaft spacing, gearbox size,
and whether the rear sprocket axle can remain where it is.

## Changes in this revision

- Replaced the disconnected original link geometry with the printable pinned
  link from `track_links.scad`.
- Replaced the chassis sprocket with the matching tapered-tooth reference cog.
- Rebuilt the displayed loop using the real detailed link geometry.
- Corrected the loop to 37 links per side and aligned its wrap to the 11-tooth
  pitch circle.
- Added pitch-spacing output and separate drive-cog and idler collision fixtures.
- Replaced the four road wheels with three track-centred lower-run support idlers
  per side and moved their axle height to nominal track contact.
- Mounted each road wheel on a horizontal Christie arm with an inboard vertical
  spring, guide, upper rail bracket, pivot shaft, wheel axle, and spring cross-pin.
- Replaced the former wheel-axle rail holes with lower arm-pivot bores and added
  upper spring-mount cross-bolt holes.
- Updated the assembly dimensions and prototype instructions to match the new
  track system.
