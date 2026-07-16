# Repository Guidelines

## Project Structure & Module Organization

Keep editable OpenSCAD sources in `assets/`; `assets/track_links.scad` defines reusable track and cog geometry, while `assets/narrow_stair_tracker.scad` assembles the chassis. Place design notes beside each model.

Generated STL and visual-review output also live under `assets/`. `<model>-review/` directories contain five views, `index.html`, and `manifest.json`. Rendering tools live in `plugins/openscad-review/`.

## Build, Test, and Development Commands

- `openscad -o /tmp/model.stl assets/track_links.scad` performs a full OpenSCAD render and exports an STL.
- `python3 plugins/openscad-review/skills/openscad-review/scripts/render_views.py assets/narrow_stair_tracker.scad --preview` renders quick iteration views.
- Run the same review command without `--preview` before submitting changes; this produces final top, bottom, left, right, and isometric views.
- Add `-D 'part="track_link"'` to render a selector from a multi-part model.

OpenSCAD is required. Python targets 3.12 or newer; manage dependencies with `uv`.

## Coding Style & Naming Conventions

Use four-space Python indentation and one OpenSCAD statement per line. Name modules and variables in `snake_case`, with descriptive lowercase selectors such as `spring_clevis`. Parameterize dimensions near the model's top; avoid unexplained geometry constants. Comment mechanical intent, clearances, and coordinate assumptions.

## Dimension Change Approval

Do not change track pitch, track width, link geometry, sprocket or idler dimensions, the chassis envelope, suspension geometry, mounting interfaces, or other major component dimensions without the human's explicit agreement to that specific change. Do not infer approval from a broader task. Before requesting agreement, describe the proposed dimensions and which existing parts may need to be reprinted or replaced. Refactoring, documentation, rendering, and geometry fixes may proceed without separate approval only when they preserve established dimensions, interfaces, and compatibility with already printed parts.

## Testing Guidelines

There is no automated unit-test suite. Treat a successful full render as the syntax and geometry gate, then inspect all five generated views. For assemblies, render relevant parts separately and run collision selectors such as `drive_collision`; expected collision-check output is empty. Document tolerances and physical checks in the adjacent README—images alone do not prove fit, strength, or printability.

## Commit & Pull Request Guidelines

Recent commits use short, imperative, lowercase summaries such as `adding idlers`. Keep each commit focused on one mechanical change and include regenerated review artifacts when geometry changes. Pull requests should explain the design intent, list affected selectors or parts, report render results, and include or link before/after views. Call out unverified dimensions, hardware assumptions, and required physical fit tests.
