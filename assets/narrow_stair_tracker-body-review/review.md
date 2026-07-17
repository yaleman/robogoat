# Four-module body review

## Outcome

The main chassis body is now four physically separate, printable structural
modules joined by bolted rail laps and splice plates. The previous rail split
was not retained because its front and rear halves occupied the same 20 mm
volume. The new complementary lap has a modelled 0.3 mm fit clearance.

The CAD is ready for an inexpensive four-part fit prototype. The joint system
has not been physically load-tested and is not yet validated for stair impacts.

## Checks completed

- The shared printer envelope lives in `assets/printer_config.scad` and is
  imported by `assets/narrow_stair_tracker.scad`.
- The configured X1C envelope is 256 x 256 x 256 mm with a 3 mm edge margin,
  giving an asserted 250 x 250 x 250 mm usable envelope.
- Each body selector automatically lays the outer rail face on the bed.
- The maximum body-module print envelope is approximately
  245 x 101.242 x 111.85 mm.
- Full top, left, bottom, right, and isometric renders were inspected for the
  assembled body, complete tracker, all four print-oriented body modules, and
  the positioned joiner set.
- The four body STLs and three splice-plate STLs export as manifold objects.
- All six body-module pair intersections are empty.
- The six existing drivetrain, track, suspension, and spring collision
  fixtures remain empty after the body split.
- Floor, rail-lap, and bulkhead holes use 4.4 mm M4 clearance bores.
- The four structural module colors expose the front/rear and left/right seams
  in the complete assembly views.

## Visible review findings

- The body top and bottom views show four distinct floor quadrants separated by
  narrow, consistent seams.
- The side views show a complementary half-thickness rail lap rather than two
  solids occupying the same space.
- The underside view shows four accessible floor splice plates away from the
  central seam crossing.
- The front and rear views show the two bulkhead splice plates and their four
  short fasteners.
- Every print-oriented module rests on the outside rail face. Its floor,
  transverse bulkhead, and rail-to-floor rib rise vertically from that face.
- Opposing module views retain all rail-lap, floor-plate, suspension, spring,
  and front-cog bracket holes.
- No disconnected solids, missing faces, mirrored-hole errors, or visible
  module-to-module penetration remain in the reviewed geometry.

## Remaining physical checks

1. Print the four body modules in inexpensive material and verify the 0.3 mm
   rail, floor, and bulkhead seams without forcing the parts together.
2. Confirm the 245 mm module axis fits the selected skirt or brim settings; the
   configured 3 mm edge margin is intentionally modest.
3. Drill or ream the 4.4 mm holes only if the chosen filament and profile close
   them below usable M4 clearance.
4. Assemble all 32 M4 fasteners with wide washers and locknuts, then check the
   chassis for twist on a flat surface.
5. Load opposite body corners and inspect rail laps, floor plates, bulkhead
   plates, and layer lines for movement or whitening.
6. Prefer aluminium splice plates for the final stair-impact chassis if the
   printed 4 mm plates flex or creep.
7. Confirm slicer support requirements for the chosen profile. The orientation
   avoids large horizontal floors, but local bolt-hole bridges and curved
   suspension bosses still require slicer inspection.

## Fit-to-purpose judgment

The four-way split is geometrically coherent and fits the configured printer
envelope with practical orientation. The load paths now cross each major seam
through multiple fasteners and dedicated plates, and the rail joint is
physically assemblable. The remaining uncertainty is structural rather than
geometric: printed layer adhesion, splice-plate stiffness, bolt preload, and
stair-impact fatigue require a complete body fit and load prototype.
