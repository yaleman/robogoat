# Narrow stair tracker review

## Outcome

Both smooth front idlers have been replaced by tooth-matched, free-spinning
front cogs. Each front cog uses one 608 bearing and the specified 7.95 mm x
10 mm shoulder screw, with a stationary spacer and captive M6 nut in a new
rail-mounted bracket. The rear drive cog geometry is unchanged, so the cog
printed before this revision remains usable at the driven end.

The model is ready for a single-side physical fit prototype. It is not yet
validated for stair-impact loads.

## Checks completed

- The full assembly and all new selectors compile in OpenSCAD 2026.06.12.
- Full top, left, bottom, right, and isometric renders were generated and
  inspected for the complete tracked assembly, front cog assembly, printable
  front cog, printable mount bracket, and modified front rail.
- Both front wheels use the same 11-tooth, 30 mm-pitch, tapered-tooth geometry
  as the rear cog. The printed rear cog geometry was not changed.
- The front cog/track collision fixture is empty for all eight links around the
  front wrap.
- The front cog/stationary-hardware collision fixture is empty.
- The rear cog/link, support-idler/track, suspension-clearance, and
  spring-pivot-clearance fixtures remain empty.
- The 608 reference dimensions are 8 mm ID x 22 mm OD x 7 mm wide. The printed
  seat is 22.2 mm diameter x 7 mm deep as a starting fit.
- The modelled shoulder is 7.95 mm diameter x 10 mm long. Its stack is exactly
  0.5 mm inner-race washer + 7 mm bearing + 2.5 mm spacer = 10 mm.
- The shoulder ends at the stationary bracket nose. Only the M6 thread enters
  the bracket and captive nut; the thread is not used as a bearing surface.
- The front cog has a 12.4 mm stationary-hardware relief around an 11.2 mm
  bracket nose and 11.5 mm spacer.
- The bracket spans the 30.5 mm track-to-rail gap with a tapered 28 mm-diameter
  body and a 40 mm-diameter rail flange.
- The bracket's 21.8 mm locating spigot fits the rail's existing 22.2 mm front
  socket. Four 4.4 mm clearance holes on a 32 mm bolt circle align with the
  modified rail.
- The front rail has a 44 mm-diameter solid boss around the locating socket and
  four bracket fasteners.
- Visual review initially exposed the bracket holes being cut at the model
  origin rather than through its flange. Their cut position was corrected and
  all five bracket views were regenerated before the final render pass.
- The printable `front_cog` STL exports as a manifold object with 383 vertices
  and 754 facets.
- The printable `front_cog_mount` STL exports as a manifold object with 951
  vertices and 1,922 facets.
- Existing dimensions remain unchanged: 340 mm overall width, 390 mm
  wheelbase, 37 links per side, three 70 mm Christie road wheels per side, and
  the 15 mm running-gear drop.

## Visible review findings

- Left/right assembly views show a toothed cog at both ends of each track and a
  shoulder-bolt head only on each undriven front cog.
- Front-cog opposing views show the outer 608 pocket and the smaller inner
  stationary-hardware relief on opposite faces.
- Bracket opposing views show all four through-holes, the central M6 clearance
  bore, the rail spigot, and the top-loading captive-nut slot.
- Front-rail opposing views show the matching four-hole pattern and reinforced
  boss without removing the existing locating socket.
- No disconnected solids, missing holes, left/right mirroring errors, or
  visible rotating/stationary overlaps remain in the reviewed selectors.

## Remaining physical checks

1. Measure the delivered shoulder screw. The 7.95 mm shoulder diameter, 10 mm
   shoulder length, and M6 x 1.0 thread are user-specified; the 13 x 5.5 mm head
   and 11.25 mm thread length are ISO 7379 reference envelopes and must be
   confirmed against the actual product.
2. Print one front cog only. Tune the 22.2 mm bearing seat for the chosen
   filament and printer profile before producing the second cog.
3. Use a metal 0.5 mm washer and 2.5 mm inner-race spacer. Confirm neither part
   touches a bearing shield or the rotating printed cog.
4. Hand-turn the cog under radial and side load. A single 608 bearing fits the
   10 mm shoulder constraint, but its real tilt, clearance, and impact life
   cannot be established from the CAD model.
5. Print one bracket and fit the captive M6 nut before mounting it. Check that
   the top slot retains the nut during assembly and leaves tool access.
6. Install all four M4 bracket fasteners and load the axle vertically and
   laterally. Inspect the 11.2 mm nose, nut pocket, tapered body, 44 mm rail
   boss, and layer lines for flex or cracking.
7. Wrap six to eight links around the front cog and rotate it in both
   directions. Check tooth entry, release, lateral window clearance, and track
   retention with the shoulder screw fully tightened.
8. Add an adjustable tensioning method; the front bracket position remains
   fixed.
9. Validate spring rate, damping, bump stops, track pins, the rear drive axle,
   and gearbox reduction before powered stair testing.

## Fit-to-purpose judgment

The new front cog and axle stack are coherent for printing and bench-fit
testing: track engagement is positive at both ends, the shoulder rather than
the M6 thread carries the bearing, and the bracket load path reaches a
reinforced rail boss. The main remaining risks are the single-bearing moment
load, printed bracket nose and captive-nut strength, actual bolt dimensions,
bearing-seat tolerance, and the lack of track tension adjustment. Resolve
those with one physical front assembly before printing the second side.
