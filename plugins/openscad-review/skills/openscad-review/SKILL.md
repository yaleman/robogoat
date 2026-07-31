---
name: openscad-review
description: Render OpenSCAD .scad models as top, bottom, left, right, and isometric PNG views, then visually inspect the geometry. Use when Codex needs to review an OpenSCAD model, verify a parametric CAD change, check part orientation or occluded faces, or produce consistent multi-view evidence before calling a model complete.
---

# OpenSCAD Review

Render the model with the bundled script, inspect every view, and report concrete geometric findings. Treat a successful OpenSCAD render as a syntax and geometry gate, not as proof that the design is correct or printable.

## Render

OpenSCAD is a native GUI/runtime application and can fail inside the restricted
Codex command sandbox before it parses the model. In particular, Qt/CPU-loader
errors from a sandboxed invocation are not evidence that the user's OpenSCAD
installation or `.scad` file is broken.

Always run the renderer in the host environment with command escalation. Do
not run an initial non-escalated render and treat its failure as authoritative.
The command must use `sandbox_permissions: "require_escalated"` and run from the
user's workspace so relative `use` and `include` paths behave normally:

```bash
python3 <skill-dir>/scripts/render_views.py path/to/model.scad
```

When invoking this through the command tool, the invocation must be equivalent
to:

```text
sandbox_permissions: require_escalated
cmd: python3 <skill-dir>/scripts/render_views.py path/to/model.scad
```

If an unavoidably non-escalated invocation has already failed, rerun the exact
same command escalated before diagnosing syntax, geometry, or OpenSCAD-loader
problems. Report the two classes of failure separately.

The default output directory is `<model-stem>-review` beside the model. The script writes `top.png`, `left.png`, `bottom.png`, `right.png`, `isometric.png`, a labelled `index.html`, and a `manifest.json` containing the render settings and OpenSCAD output.

Useful options:

```bash
# Override Customizer variables. Repeat -D as needed.
python3 <skill-dir>/scripts/render_views.py model.scad -D 'part="track_link"'

# Faster preview images while iterating.
python3 <skill-dir>/scripts/render_views.py model.scad --preview

# Choose the output location and image size.
python3 <skill-dir>/scripts/render_views.py model.scad \
  --output-dir build/model-review --size 1600x1200
```

Use full rendering for the final review. Preview mode uses OpenCSG and can show false black faces or other backside artifacts on otherwise valid geometry.

Do not install OpenSCAD silently. If neither `openscad` nor the standard macOS application executable exists in the escalated host environment, report that OpenSCAD is required and ask before installing it.

## Inspect

Open each PNG with the local image viewer. Inspect all five; do not infer hidden geometry from the isometric view alone.

Check for:

- disconnected or unexpectedly missing solids;
- mirrored, inverted, or inconsistent left/right geometry;
- holes, pockets, and fastener access that disappear in opposing views;
- collisions, coplanar overlaps, and parts occupying the same space;
- implausibly thin walls, unsupported spans, trapped parts, and inaccessible assembly features;
- cropping, empty renders, or view-to-view scale differences, which indicate the render itself is not trustworthy.

For a multi-part selector model, render the assembly first, then render each relevant selector value separately with `-D`. Do not assume the default selector exposes every printable part.

## Report

Lead with the review outcome. Name the affected view and feature for every finding. Distinguish among:

- render failures or OpenSCAD warnings;
- visible model defects;
- printability or engineering risks that require dimensions or physical validation;
- aspects that cannot be established from images alone.

Link the overview and individual images when useful. Never claim dimensional accuracy, watertightness, tolerances, load capacity, or printability solely from PNG inspection.
