# Narrow stair tracker — first-pass OpenSCAD model

This is an original, parametric tracked chassis inspired by the general layout of RCTestFlight's Snow Tank. It is **not** a scaled copy of the original STL geometry.

## Default dimensions

- Overall width: approximately **340 mm**
- Track width: **55 mm** per side
- Chassis width between track pods: **214 mm**
- Track contact length / wheelbase: **390 mm**
- Approximate overall length: **526 mm**
- Sprocket pitch diameter: approximately **106.5 mm**
- Track links: approximately **38 per side**

The 340 mm overall width is almost exactly two-thirds of the roughly 508 mm width previously discussed for the larger Snowcat-style platform.

## X1C printability

The default parts are split so their nominal XY footprints fit within a 256 × 256 mm bed:

- Rail half: approximately 235 × 86 mm when laid flat
- Floor half: 230 × 208 mm
- Crossmember: 214 × 28 mm
- Sprocket/idler: under 120 mm diameter
- Track link: 30 × 55 mm

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
- `road_wheel`
- `rail_front`
- `rail_rear`
- `crossmember`
- `floor_front`
- `floor_rear`
- `motor_plate`
- `gearbox_plate`
- `dimensions`

Render with F6, then export the selected part as STL.

## Important prototype checks

Do these before printing a complete set:

1. Print two track links and test the hinge with the intended 3 mm pin material.
2. Print one sprocket and six to eight links, then verify pitch and tooth engagement around half the sprocket.
3. Tune `track_clearance`, `hinge_pin_d`, and `bearing_od` for the actual filament and printer profile.
4. Build one complete track pod and turn it by hand under load before installing motors.
5. Add a real axle retention method and metal bearing spacers. The model only provides nominal bores.

## Materials

A sensible first build would use:

- Track links: PA6-CF, PAHT-CF, or tough PETG/ASA for cheap iteration
- Sprocket and idler: PA-CF or PC; avoid ordinary PLA for loaded final parts
- Frame rails and floor: ASA, PC, or PA-CF
- Optional traction pads: separate TPU inserts or bonded TPU strips
- Hinge pins: 3 mm stainless rod or cut-down machine screws
- Main axles: 8 mm steel
- Bearings: 608-series as a starting point, subject to final shaft design

## Drivetrain status

The model includes a generic 42 mm brushless motor plate and gearbox side plate, but **does not contain a validated reduction gearbox**. A low-KV outrunner still needs substantial reduction for controlled stair climbing. Treat the motor and gearbox geometry as an interface placeholder, not a finished transmission.

For the next iteration, choose the actual motor, battery voltage, desired track speed, and reduction method first. Those determine shaft spacing, gearbox size, and whether the rear sprocket axle can remain where it is.
