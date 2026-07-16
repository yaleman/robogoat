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
- Every adjacent link centre is 30.000 to 30.077 mm apart.
- The rear cog/link intersection fixture is empty.
- The front idler/link intersection fixture is empty.
- Three support idlers per side are centred on their tracks at x = -110, 0, and
  +110 mm.
- The support idler tangent and lower track wheel-side face both sit at
  z = 18.758 mm. Exact tangency produces only a zero-area shared edge; with the
  fixture's 0.01 mm tangent allowance, the volumetric intersection is empty.
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
4. Add suspension or preload adjustment for the three lower support idlers; this
   revision holds them at rigid nominal contact.
5. Add an adjustable front idler or another tensioning method; its position is
   currently fixed.
6. Add lateral guidance or guide horns if the track can walk off the wheels.
7. Replace the placeholder motor/gearbox interface with a bearing-supported,
   reduced drive sized for the selected motor and vehicle mass.

## Fit-to-purpose judgment

The link and cog geometry is now credible for printing and bench testing. The
overall chassis remains a layout prototype: stair use should wait until pin
retention, track tension, lateral guidance, axle support, and the reduction drive
have been resolved and tested under load.
