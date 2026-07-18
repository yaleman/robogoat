# Parametric herringbone gearbox

This OpenSCAD design generates a compact four-stage **40:1** internal gearbox
and a separate 20:48 final-drive pair:

| Stage | Teeth | Ratio |
|---|---:|---:|
| 1 | 18 → 54 | 3:1 |
| 2 | 18 → 72 | 4:1 |
| 3 | 18 → 72 | 4:1 |
| 4 | 48 → 40 | 0.833:1 |
| **Internal total** |  | **40:1** |
| External final drive | 20 → 48 | 2.4:1 |
| **Installed total** |  | **96:1** |

The integrated motor envelope is based on the supplied 540 drawing: 35.8 mm
body diameter, 50 mm body length, 18 mm shaft projection, 3.175 mm shaft,
13 mm pilot, and two M3 holes on 25 mm centres. Motor speed and voltage are not
assumed; calculate track-axle speed from the actual motor's loaded RPM divided
by 96.

The wide, angled 48:40 internal output stage keeps the output shaft clear of
the preceding 72-tooth gear by 4.95 mm in the model. A module 0.8, 20:48
herringbone pair then drives
the rear cog axle over a 27.4 mm centre distance without a belt or intermediate
jackshaft.

## Dependency

Place `gears.scad` from `chrisspen/gears` beside the design:

```text
gearbox/
├── gears.scad
└── parametric_herringbone_gearbox.scad
```

Repository: `https://github.com/chrisspen/gears`

The dependency declares a Creative Commons Attribution-NonCommercial-ShareAlike licence in its source header. Check it before redistributing a combined bundle or using it commercially.

## Construction

Each herringbone gear is a separate flat-printed part. Shafts A, B and C each
carry two gears, creating the three compound stages. The 1.25 module gears are
9 mm wide. Two housing layouts share the same gears and axial stack but move
the motor axes apart in the chassis: the primary plates are approximately
238.9 x 136.3 mm and the alternate plates are approximately 227.2 x 136.3 mm.
Both fit the shared 250 x 250 mm usable X1C envelope.

When installed as the left primary and mirrored right alternate drive units,
the two motor axes are approximately 45.2 mm apart in the chassis X/Z plane.
That leaves about 9.4 mm radial clearance between the 35.8 mm motor-can
envelopes. The chassis installation offsets them axially as described in the
chassis build notes.

All four gearbox shafts rotate in 688 bearings mounted in the two housing plates.

## Parts per gearbox

Print:

- 1 front plate
- 1 rear plate
- 1 motor pinion
- 7 shaft gears
- 1 final-drive pinion
- 1 final-drive axle gear
- 1 internal spacer set
- 8 housing standoffs

Buy:

- 8 × 688 bearings, 8 × 16 × 5 mm
- 4 × 8 mm steel shafts, preferably D-shaft or smooth shaft with a filed flat
- shaft collars or retaining rings for both outside ends of each shaft
- M4 through-bolts and nuts for the eight housing standoffs
- thin 1 mm shims/washers if the printed middle spacers are unpleasant

## Exporting parts

Change `part` near the top of the SCAD file:

```scad
part = "front_plate";
```

Available values:

```text
assembly
assembly_alternate
drive_unit
drive_unit_mirrored
drive_unit_alternate
motor_540
front_plate
rear_plate
front_plate_alternate
rear_plate_alternate
motor_pinion
gear_a0
gear_a1
gear_b1
gear_b2
gear_c2
gear_c3
output_gear
final_drive_pinion
final_drive_axle_gear
internal_gear_collision
housing_standoff_gear_collision
shaft_other_gear_collision
spacer_set
housing_spacer
gear_set
print_layout
```

Export each selected item as STL. Print eight copies of `housing_spacer`.

The left chassis side uses the primary front and rear plates. The right chassis
side uses mirrored copies of the alternate plates. All gears, spacers,
bearings, shafts, and standoffs are common between the two layouts.

`gear_set` lays out all gears, but it may not fit your preferred arrangement.
The two plates must be exported separately. Each fits the configured X1C
usable area, but the combined print layout is intentionally not treated as a
single-bed production arrangement.

## Fit tuning

Print a bearing-fit coupon and one 18-tooth gear before committing to the complete set.

Important parameters:

```scad
bearing_pocket_d = 16.15;
shaft_bore_d = 8.20;
mesh_extra_distance = 0.20;
```

Typical changes:

- bearing too loose: reduce `bearing_pocket_d`
- bearing too tight: increase `bearing_pocket_d`
- gear mesh too tight: increase `mesh_extra_distance` by 0.05–0.10 mm
- gear mesh too loose: reduce it in small increments

The library already has tooth-flank clearance, but FDM herringbone gears are not where you demonstrate ideological opposition to backlash.

## Motor mount

Defaults match the supplied 540 motor face with printable clearance:

```scad
motor_bolt_spacing = 25;
motor_bolt_hole_d = 3.4;
motor_pilot_hole_d = 13.4;
```

Measure the actual motor before printing the front plate. With the compact
stack, the motor pinion occupies z = 5.5 to 14.5 mm behind the motor mounting
face, within the drawing's 18 mm shaft projection.

## Gear and shaft retention

The 8 mm gears have D-shaped bores and 2.5 mm radial pilot holes. Options:

1. Use commercial 8 mm D-shaft.
2. File a flat on 8 mm precision rod.
3. Drill and tap the pilot hole M3 for a grub screw.
4. Use both, because reversing tracked drivetrains are not kind to optimistic friction fits.

The motor pinion uses the same arrangement for a nominal 3.175 mm motor shaft.

## Printing

Suggested X1C starting point:

- gears: PA6-GF, PA6-CF, PA12-CF or wear-resistant nylon
- plates: ASA, ABS-GF, PA6-GF or PC
- hardened 0.4 or 0.6 mm nozzle
- 0.16–0.20 mm layers
- 6–8 walls
- 40–60% infill for plates
- high infill or modifier regions around gear bores

Print gears flat with the shaft axis vertical. Dry nylon properly.

## Assembly

1. Press four 688 bearings into each plate.
2. Fit the front plate, housing standoffs and motor.
3. Insert the four shafts through the front bearings.
4. Add front spacers, gears and middle spacers in axial layer order.
5. Align the keyed gears to the modelled mesh phases so tooth tips do not meet
   tooth tips.
6. Fit rear spacers and the rear plate.
7. Add external shaft collars without crushing the bearing races.

The dependency requires equal module and opposite helix-angle signs for meshing pairs; the design does that automatically.

## Use with tracks

The integrated chassis places the plate bottoms at z = 50.15 mm, 0.15 mm above
the 50 mm baseplate-top datum. The output axis is at z = 84.4 mm and its
20-tooth final-drive pinion meshes with the 48-tooth gear on the established
z = 57 mm rear cog axle. The axle runs in a rail-mounted 608 bearing, so track
tension is not carried by the gearbox's 688 output bearings.

The `internal_gear_collision` selector checks all four meshes in both housing
layouts. `housing_standoff_gear_collision` checks every housing support against
every gear, and `shaft_other_gear_collision` checks each 8 mm shaft against all
gears not mounted on that shaft. All three are expected to render empty. These
validate the modelled static geometry; physical backlash, shaft runout, bearing
fit, and loaded tooth deflection still require test prints.

Start with a low current limit and gentle acceleration. Printed gears should be treated as service parts, not ancestral heirlooms.
