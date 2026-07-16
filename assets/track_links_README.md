# Pinned track links

`track_links.scad` is a standalone link design. It deliberately does not include a chassis, wheels, sprocket, or motor mount.

The default generated meshes are `track_link.stl` and `track_cog_reference.stl`.

## Default link

- 55 mm track width
- 30 mm pin pitch
- 40 mm overall link length including hinge barrels
- 10.5 mm overall height
- 10 mm hinge barrel outside diameter
- 3.4 mm bore for a 3 mm pin or M3 fastener
- 0.5 mm axial clearance on each side of the centre knuckle
- 3.3 mm radial material around each pin bore
- 1 mm positive overlap at every barrel connector
- 0.3 mm radial clearance between a pad end and the neighbouring hinge barrel
- 10 x 16 mm through-window for cog-wheel drive

Every link is identical. The two outer knuckles at the front accept the centre knuckle of the next link.

## Cog-wheel drive

Each link has a through drive window on its centreline. The included `cog_reference` uses an 11-tooth, chord-correct 30 mm pitch circle. Each tooth is 8 mm wide at its tangential root, tapers symmetrically to 5 mm at its tip, is 14 mm wide across the track, and is 10 mm tall radially. The approximately 8.5-degree leading and trailing faces help the teeth enter and leave the link windows in both directions.

The 8 mm root leaves 1 mm nominal tangential clearance on each side inside the 10 mm window. The 14 mm tooth width leaves 1 mm nominal lateral clearance on each side inside the 16 mm window.

The reference cog teeth overlap its body by 1 mm. The cog is still a geometry and engagement reference, not a finished wheel: it has no hub, clamp, bearing interface, or material-specific tooth relief. Design the final cog only after measuring a printed run of links.

## Hardware

Use 3 mm stainless rod with push-on retainers for the first test. M3 x 60 mm screws can be used for fit testing, but threaded fasteners are not ideal long-term bearing surfaces. Do not use printed 3 mm pins for a loaded track.

The 3.4 mm horizontal holes are intentionally generous, but printed holes can still shrink. Test two links first and ream with a 3.4 mm drill if necessary.

## Printing

Print with the broad, flat wheel-side face on the bed and the two tread ribs facing upward. No support is intended. Use at least four perimeters around the hinge barrels.

Suggested prototype materials:

- PETG or ASA for inexpensive geometry tests
- PA6-CF or PAHT-CF after the hinge and sprocket tests pass

The `six_link_plate` selector lays out six links in approximately 132 x 117 mm.

## Selectors

Set `part` near the top of the file:

- `link`: one printable link
- `straight_pair`: two links with a reference pin
- `bent_pair`: two links bent 32.727 degrees for an 11-tooth sprocket target
- `six_link_plate`: six printable links
- `cog_reference`: pitch-matched reference cog wheel
- `cog_engagement`: one link engaged with the reference cog
- `pin_reference`: pin envelope only; not intended as a printed load-bearing pin
- `dimensions`: echoed dimensions
- `straight_collision`: adjacent-link intersection test; the correct result is empty
- `bend_collision`: bent-link intersection test; the correct result is empty
- `cog_collision`: cog/link intersection test; the correct result is empty

## Prototype gate

1. Print two links.
2. Confirm a 3 mm pin passes through both links without forcing or visible slop.
3. Articulate the pair through at least 33 degrees.
4. Print six to eight links and wrap them around a short reference-cog sector.
5. Design the final cog around the measured pitch, bore, and tooth clearances.
