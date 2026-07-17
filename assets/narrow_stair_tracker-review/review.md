# Narrow stair tracker review

## Outcome

The new pinned track link and matching tapered-tooth cog are integrated into the
340 x 526 mm chassis model. The assembly now displays the actual printable link
geometry instead of rectangular placeholders, with 37 links per side following
the 30 mm, 11-tooth pitch path.

The model is suitable for the next physical prototype gate: two links first,
then six to eight links wrapped around the printed cog. It is not yet a finished
stair-climbing drivetrain.

## Checks completed

- The full assembly compiles in OpenSCAD.
- All five assembly viewpoints were regenerated from the final model hash. The
  colored left, bottom, right, and isometric images are full F6 renders. After
  the top F6 geometry pass succeeded, macOS repeatedly failed to create the
  off-screen raster context, so `top.png` uses the same model's exact CGAL
  vector projection instead.
- Every adjacent link centre is 30.000 to 30.077 mm apart.
- The rear cog/link intersection fixture is empty.
- The front idler/link intersection fixture is empty.
- Three support idlers per side are centred on their tracks at x = -110, 0, and
  +110 mm.
- The support idler tangent and lower track wheel-side face both sit at
  z = 18.758 mm. Exact tangency produces only a zero-area shared edge; with the
  fixture's 0.01 mm tangent allowance, the volumetric intersection is empty.
- Every road wheel is carried by a 55 mm horizontal Christie arm with a vertical
  spring pickup at a 0.60 motion ratio.
- The three arm pivots are at x = -165, -55, and +55 mm; the spring axes are at
  x = -132, -22, and +88 mm.
- Static clearances are 3 mm arm-to-wheel, 1 mm arm-to-hub, 1.5 mm
  spring-cap-to-rail, 7 mm spring-cap-to-wheel, and 2.242 mm
  upper-mount-to-top-track.
- The suspension-clearance intersection fixture is empty after adding the
  intentional 1 mm arm-to-hub gap.
- Each spring has integral 4.4 mm-bore eyelets on 4 mm pins. The lower eyelet is
  pinned beside the bellcrank; the upper eyelet sits between two fork ears with
  0.5 mm axial clearance per side.
- The spring-pivot clearance fixture is empty. It checks the spring and eyelets
  against the arm and fork without including the intended pins.
- At the 12-degree raised-wheel demonstration state, the wheel rises 11.435 mm,
  the spring compresses 6.856 mm, and the two pivots permit 0.837 degrees of
  spring tilt.
- The standalone link is one connected printable solid.
- Straight and 32.727-degree articulated link-pair collision fixtures are empty.
- The cog teeth taper from an 8 mm tangential root to a 5 mm tip, giving angled
  entry and exit faces in both drive directions.

## Remaining physical checks

1. Confirm a 3 mm metal pin fits the printed 3.4 mm bores without binding or
   excessive play.
2. Turn a six-to-eight-link cog wrap by hand in both directions and inspect tooth
   entry, release, and lateral clearance.
3. Add positive pin retention before running a complete track.
4. Select real steel spring rates, preload, dampers/guides, bump stops, and wheel
   travel from the measured vehicle mass and stair-impact loads. The modeled
   coils are only geometry envelopes.
5. Validate the cantilevered arm, pivot, hub, and axle loads; the current model
   establishes packaging and motion geometry, not structural capacity.
6. Select pivot bushings, washers, pin retention, and fork material after wear
   testing a printed lower and upper joint under representative side load.
7. Add an adjustable front idler or another tensioning method; its position is
   currently fixed.
8. Add lateral guidance or guide horns if the track can walk off the wheels.
9. Replace the placeholder motor/gearbox interface with a bearing-supported,
   reduced drive sized for the selected motor and vehicle mass.

## Fit-to-purpose judgment

The link, cog, and Christie suspension packaging are credible for printing and
bench-fit testing. The overall chassis remains a layout prototype: stair use
should wait until spring rate, preload, damping, bump stops, arm and axle load
capacity, pin retention, track tension, lateral guidance, and the reduction
drive have been resolved and tested under load.
