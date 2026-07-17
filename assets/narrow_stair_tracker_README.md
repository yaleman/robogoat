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

## Assembly colour legend

The OpenSCAD preview uses component colours to make the mechanism easier to
read. Colours do not affect exported STL geometry:

- frame and rails: dark grey
- front-cog brackets and spring forks: charcoal
- track links: ochre
- rear driven cogs: red
- front undriven cogs: purple
- road wheels: teal
- suspension arms: amber
- springs and spring bodies: green
- 608 bearings: blue
- bolts, shafts, pins, and nuts: black
- washers, spacers, and motor shafts: steel grey

All values are grouped in the `assembly colours` section near the top of
`narrow_stair_tracker.scad`.

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
- the same tooth and pitch geometry at both ends of each track, so the
  undriven front wheel also positively guides the links
- 37 actual detailed links on each side of the assembly

The rear driven cog remains the original `cog_reference()` geometry. The new
front cog is a separate printable part with the same teeth plus a 608 bearing
seat and stationary-hardware relief. A rear cog printed before this revision is
still usable; do not use it as the front bearing cog.

## Front cog, bearing, and shoulder-bolt axle

Each undriven front cog uses one 608-series bearing and one M6 shoulder screw:

- bearing: 8 mm ID, 22 mm OD, 7 mm wide
- printed bearing seat: 22.2 mm diameter x 7 mm deep as a starting fit
- shoulder screw: 7.95 mm measured shoulder diameter, 10 mm shoulder length,
  M6 x 1.0 thread
- modelled ISO 7379 head envelope: 13 mm diameter x 5.5 mm high with a 4 mm
  hex key
- modelled thread envelope: 11.25 mm long; confirm this against the delivered
  screw before printing the bracket
- shoulder stack: 0.5 mm inner-race washer + 7 mm bearing + 2.5 mm inner-race
  spacer = 10 mm

The bearing presses into the outer face. A 12.4 mm central relief in the inner
half of the cog clears the 11.2 mm stationary bracket nose and the 11.5 mm
inner-race spacer. The shoulder ends exactly at the bracket nose, so the M6
thread is not used as the bearing surface. The screw engages a top-loading
captive M6 nut in the bracket.

The bracket locates in the former front rail bearing hole with a 21.8 mm
spigot. Four M4 fasteners on a 32 mm bolt circle retain its 40 mm-diameter
flange against a new 44 mm-diameter rail boss. The tapered bracket body carries
the axle load back across the 30.5 mm track-to-rail gap.

## Christie road-wheel suspension

Each track now has three 70 mm-diameter support idlers at longitudinal positions
-110, 0, and +110 mm. Every idler is centred across the 55 mm track width. Their
axles sit at z = 38.758 mm, placing the wheel tangent at z = 3.758 mm against
the wheel-side face of the straight lower track run.

The complete running-gear pod is 15 mm lower than the original layout. This
includes both end-wheel axes, the track loop, all three road wheels, the arms,
springs, and upper spring forks. Moving the complete pitch path keeps the 30 mm
link spacing and the sprocket-to-track relationship unchanged while increasing
the track's downward reach relative to the chassis.

Each road wheel is carried by an independent Christie-style suspension unit:

- 55 mm horizontal trailing/bellcrank arm
- 6.2 mm hull-pivot bore in the rail's lower structural web
- wheel axle at the arm tip
- vertical spring pickup 60% of the way from pivot to wheel axle
- integral lower spring eyelet pinned beside the arm pickup
- integral upper spring eyelet captured by a double-shear fork
- 4 mm removable pivot pins in 4.4 mm eyelet and fork bores
- 56.242 mm nominal eyelet-centre spacing
- 14 mm-wide vertical fork gusset carrying spring load back to the rail
- two M4 fork-bracket bolts on 13.5 mm vertical centres
- 18 mm-wide full-height rail column behind each upper spring mount
- 12 mm-radius dropped rail lug around every lowered arm pivot

When a wheel rises, its arm rotates upward about the hull pivot. The intermediate
pickup rises by 60% of the wheel's small-angle travel and compresses the vertical
spring. Both spring ends pivot about transverse pins, allowing the spring/damper
body to tilt as the arm pickup follows its arc. The neutral model keeps the three
wheels tangent to the straight lower track run.

The `suspension_unit_raised` selector demonstrates 12 degrees of upward arm
rotation: 11.435 mm wheel lift, 6.856 mm spring compression, and 0.837 degrees of
spring tilt. The spring remains connected between the moving lower eyelet and
fixed upper eyelet throughout that state.

The arms sit immediately inboard of the wheels. The springs sit between the arms
and hull rails. Nominal static clearances are 3 mm arm-to-wheel, 1 mm
arm-to-hub, 0.5 mm lower-eyelet-to-arm, 1.5 mm spring-cap-to-rail, 7 mm
spring-cap-to-wheel, and 2.242 mm between the upper mount and top track. The
15 mm pod drop does not reduce that top-track clearance because the upper mount
and complete track path move together.

The coil and central guide in the model are an **envelope and motion reference**,
not a printable load-bearing spring. Use a real steel compression spring with a
proper guide or damper, retained seats, and bump stops selected from the final
vehicle mass and required wheel travel.

The loop is generated from link-centre positions around the pitch circle. The
reported adjacent-centre spacing is 30.000 to 30.077 mm; the small maximum
variation occurs at a straight-to-wrap transition.

Six diagnostic selectors are available:

- `drive_collision`: cog against the seven links around the rear drive wrap
- `front_cog_collision`: bearing cog against the eight links around the front
  wrap
- `front_cog_hardware_collision`: rotating front cog against its stationary
  bracket, bearing, washer, spacer, shoulder screw, and captive nut
- `support_idler_collision`: three lower support idlers against the 13 links in
  the straight lower run, with a 0.01 mm allowance that excludes the shared
  tangent edge and reports only volumetric penetration
- `suspension_clearance_collision`: the arms and springs against the tracks,
  road wheels, end wheels, and hull rail
- `spring_pivot_clearance_collision`: spring eyelets and body against the arm
  and upper fork, excluding their intended pins

All six are expected to render as an empty object. A non-empty result means
that one of the checked components has solid interference beyond the documented
tangent allowance.

## X1C printability

The default parts are split so their nominal XY footprints fit within a
256 x 256 mm bed:

- Rail half: approximately 235 x 102 mm when laid flat
- Floor half: 230 x 208 mm
- Crossmember: 214 x 28 mm
- Rear and front cogs: under 120 mm diameter
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
- `front_cog`
- `front_cog_assembly`
- `front_cog_mount`
- `shoulder_bolt`
- `bearing_608`
- `support_idler`
- `christie_arm`
- `vertical_spring`
- `spring_upper_fork`
- `suspension_unit`
- `suspension_unit_raised`
- `rail_front`
- `rail_rear`
- `crossmember`
- `floor_front`
- `floor_rear`
- `motor_plate`
- `gearbox_plate`
- `drive_collision`
- `front_cog_collision`
- `front_cog_hardware_collision`
- `support_idler_collision`
- `suspension_clearance_collision`
- `spring_pivot_clearance_collision`
- `dimensions`

Render with F6, then export the selected part as STL.

## Important prototype checks

Do these before printing a complete set:

1. Print two track links and test the hinge with the intended 3 mm pin material.
2. Print one rear cog and six to eight links, then verify pitch and tooth
   engagement around half the cog in both directions.
3. Tune the link clearances in `track_links.scad` and `bearing_od` in the chassis
   model for the actual filament and printer profile.
4. Print one front cog and mount bracket. Press in one actual 608 bearing and
   verify that the cog turns without the stationary 2.5 mm spacer or 11.2 mm
   bracket nose rubbing the 12.4 mm cog relief.
5. Assemble the specified shoulder screw, 0.5 mm inner-race washer, bearing,
   2.5 mm metal spacer, and captive M6 nut. Confirm the shoulder ends at the
   bracket nose before tightening; do not clamp through the printed cog or the
   bearing shields.
6. Fit the bracket spigot to the front rail and install all four M4 flange
   fasteners. Check the 44 mm rail boss and tapered bracket for flex before
   fitting the track.
7. Build one complete track pod and turn it by hand under load before installing
   motors.
8. Print one arm and mock the spring envelope before producing all six units;
   verify the hub, rail, upper-track, and fastener clearances on the assembled
   track pod.
9. Test one lower and upper pivot with the intended 4 mm pins, washers/bushings,
   and retainers. Confirm free rotation without visible eyelet or fork slop.
10. Fit both M4 upper-mount bolts with washers and locknuts, then load one fork in
   the wheel-travel direction. Inspect the fork gusset, rail column, dropped
   pivot lug, and layer lines for cracking or permanent movement.
11. Weigh the completed robot and calculate the spring rate, preload, damping,
   bump stop, and maximum arm angle before powered stair testing.

## Materials

A sensible first build would use:

- Track links: PA6-CF, PAHT-CF, or tough PETG/ASA for cheap iteration
- Rear cog, front cog, and idlers: PA-CF or PC; avoid ordinary PLA for loaded
  final parts
- Front cog bracket: PA-CF for the prototype, with a metal bracket preferred
  if the printed nose or captive-nut pocket shows movement
- Suspension arms and upper mounts: PA-CF or machined metal after prototype fit
- Suspension springs and pivot/axle pins: steel hardware, not printed substitutes
- Frame rails and floor: ASA, PC, or PA-CF
- Optional traction pads: separate TPU inserts or bonded TPU strips
- Hinge pins: 3 mm stainless rod or cut-down machine screws
- Rear drive axles: 8 mm steel
- Front axles: 7.95 x 10 mm shoulder, M6 x 1.0 grade 12.9 shoulder screws
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
- Replaced the fixed spring seats with integral eyelets at both ends, a lower
  arm cross-pin, and an upper double-shear fork and pin.
- Added a raised-wheel kinematic selector that rotates the arm and automatically
  compresses and tilts the spring between its two pivot centres.
- Replaced the former wheel-axle rail holes with lower arm-pivot bores and added
  upper spring-mount cross-bolt holes.
- Lowered the complete track and suspension pod by 15 mm while retaining the
  original link pitch and suspension travel geometry.
- Added dropped rail lugs around the lower arm pivots.
- Reinforced each upper spring mount with a 14 mm vertical gusset, twin M4
  cross-bolts, and an 18 mm full-height rail column.
- Replaced both smooth front idlers with tooth-matched front cogs so both ends
  positively guide the track links.
- Added one outer 608 bearing seat and an inner stationary-hardware relief to
  each front cog without changing the already printable rear drive cog.
- Modelled the 7.95 x 10 mm shoulder screw, M6 thread, inner-race washer, 2.5 mm
  spacer, 608 bearing, and captive M6 nut as a complete front axle stack.
- Added a tapered front-cog bracket with a captive-nut slot, 21.8 mm rail
  spigot, four M4 flange fasteners, and a reinforced 44 mm rail boss.
- Added front cog/track and front cog/hardware collision fixtures.
- Replaced the single orange running-gear colour with a component-based preview
  palette for tracks, cogs, road wheels, suspension, springs, bearings,
  fasteners, mounts, and frame parts.
- Clamped rounded-rectangle corner radii to valid geometry so narrow rail and
  plate features render consistently in current OpenSCAD builds.
- Updated the assembly dimensions and prototype instructions to match the new
  track system.
