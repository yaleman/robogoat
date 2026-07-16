# Repository Guidelines

## Project Structure & Module Organization

This repository contains parametric OpenSCAD designs for a tracked robot. Keep editable CAD sources in `assets/`; `assets/track_links.scad` defines the reusable track link and cog geometry, while `assets/narrow_stair_tracker.scad` assembles the chassis. Place design-specific notes beside the model in files such as `assets/narrow_stair_tracker_README.md`.

Generated STL files and visual-review output also live under `assets/`. Review directories use the `<model>-review/` pattern and contain five rendered views, an `index.html`, and a `manifest.json`. The reusable rendering workflow is maintained in `plugins/openscad-review/`.

## Build, Test, and Development Commands

- `openscad -o /tmp/model.stl assets/track_links.scad` performs a full OpenSCAD render and exports an STL.
- `python3 plugins/openscad-review/skills/openscad-review/scripts/render_views.py assets/narrow_stair_tracker.scad --preview` renders quick iteration views.
- Run the same review command without `--preview` before submitting changes; this produces final top, bottom, left, right, and isometric views.
- Add `-D 'part="track_link"'` to render a selector from a multi-part model.

OpenSCAD must be installed locally. The Python metadata targets Python 3.12 or newer; use `uv` for any future Python dependency changes.

## Coding Style & Naming Conventions

Use four-space indentation in Python and conventional OpenSCAD formatting with one statement per line. Name OpenSCAD modules and variables in `snake_case`, and give selector values descriptive lowercase names such as `spring_clevis`. Keep dimensions parameterized near the top of each model; avoid unexplained constants in geometry expressions. Add short comments for mechanical intent, clearances, and coordinate-system assumptions.

## Testing Guidelines

There is no automated unit-test suite. Treat a successful full render as the syntax and geometry gate, then inspect all five generated views. For assemblies, render relevant parts separately and run collision selectors such as `drive_collision`; expected collision-check output is empty. Document tolerances and physical checks in the adjacent README—images alone do not prove fit, strength, or printability.

## Commit & Pull Request Guidelines

Recent commits use short, imperative, lowercase summaries such as `adding idlers`. Keep each commit focused on one mechanical change and include regenerated review artifacts when geometry changes. Pull requests should explain the design intent, list affected selectors or parts, report render results, and include or link before/after views. Call out unverified dimensions, hardware assumptions, and required physical fit tests.
