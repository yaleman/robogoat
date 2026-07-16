#!/usr/bin/env python3
"""Render an OpenSCAD model from standard review viewpoints."""

from __future__ import annotations

import argparse
import hashlib
import html
import json
import shutil
import subprocess
import sys
from dataclasses import asdict, dataclass
from enum import Enum
from pathlib import Path


class View(Enum):
    TOP = ("top", "0,0,0,0,0,0,100")
    LEFT = ("left", "0,0,0,90,0,0,100")
    BOTTOM = ("bottom", "0,0,0,180,0,0,100")
    RIGHT = ("right", "0,0,0,90,0,180,100")
    ISOMETRIC = ("isometric", "0,0,0,55,0,25,100")

    @property
    def label(self) -> str:
        return self.value[0]

    @property
    def camera(self) -> str:
        return self.value[1]


@dataclass(frozen=True)
class RenderResult:
    view: str
    image: str
    command: list[str]
    return_code: int
    output: str


def parse_size(value: str) -> tuple[int, int]:
    try:
        width_text, height_text = value.lower().split("x", maxsplit=1)
        width, height = int(width_text), int(height_text)
    except (TypeError, ValueError) as error:
        raise argparse.ArgumentTypeError("size must look like 1200x900") from error
    if width < 64 or height < 64:
        raise argparse.ArgumentTypeError("each image dimension must be at least 64 pixels")
    return width, height


def find_openscad(explicit: str | None) -> Path:
    candidates = [
        explicit,
        shutil.which("openscad"),
        "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
    ]
    for candidate in candidates:
        if candidate and Path(candidate).is_file():
            return Path(candidate).resolve()
    raise FileNotFoundError(
        "OpenSCAD was not found in PATH or /Applications/OpenSCAD.app"
    )


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def render_view(
    executable: Path,
    model: Path,
    output_dir: Path,
    view: View,
    size: tuple[int, int],
    defines: list[str],
    preview: bool,
) -> RenderResult:
    image_path = output_dir / f"{view.label}.png"
    command = [
        str(executable),
        "--autocenter",
        "--viewall",
        "--projection=ortho",
        f"--camera={view.camera}",
        f"--imgsize={size[0]},{size[1]}",
        "--colorscheme=Tomorrow",
        "--view=edges",
        "--preview" if preview else "--render=true",
    ]
    for definition in defines:
        command.extend(["-D", definition])
    command.extend(["-o", str(image_path), str(model)])

    completed = subprocess.run(
        command,
        cwd=model.parent,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )
    return RenderResult(
        view=view.label,
        image=image_path.name,
        command=command,
        return_code=completed.returncode,
        output=completed.stdout.strip(),
    )


def write_overview(output_dir: Path, model: Path, results: list[RenderResult]) -> None:
    cards = "\n".join(
        (
            '<figure><a href="{image}"><img src="{image}" alt="{label} view"></a>'
            "<figcaption>{label}</figcaption></figure>"
        ).format(image=html.escape(result.image), label=html.escape(result.view.title()))
        for result in results
    )
    document = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{html.escape(model.name)} review</title>
  <style>
    body {{ margin: 24px; color: #202124; background: #f5f5f5; font: 16px system-ui, sans-serif; }}
    h1 {{ font-size: 1.4rem; }}
    main {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)); gap: 18px; }}
    figure {{ margin: 0; padding: 12px; background: white; border: 1px solid #d9d9d9; border-radius: 8px; }}
    img {{ display: block; width: 100%; height: auto; }}
    figcaption {{ margin-top: 8px; font-weight: 650; text-align: center; }}
  </style>
</head>
<body>
  <h1>{html.escape(model.name)} review</h1>
  <main>{cards}</main>
</body>
</html>
"""
    (output_dir / "index.html").write_text(document, encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Render top, left, bottom, right, and isometric OpenSCAD views."
    )
    parser.add_argument("model", type=Path, help="OpenSCAD source file")
    parser.add_argument(
        "-o", "--output-dir", type=Path, help="output directory beside the model by default"
    )
    parser.add_argument(
        "--size", type=parse_size, default=(1200, 900), help="PNG size (default: 1200x900)"
    )
    parser.add_argument(
        "-D", "--define", action="append", default=[], help="OpenSCAD variable definition"
    )
    parser.add_argument("--preview", action="store_true", help="use preview instead of full render")
    parser.add_argument("--openscad", help="explicit OpenSCAD executable")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    model = args.model.resolve()
    if not model.is_file():
        print(f"error: model does not exist: {model}", file=sys.stderr)
        return 2
    if model.suffix.lower() != ".scad":
        print(f"error: expected an .scad file: {model}", file=sys.stderr)
        return 2

    try:
        executable = find_openscad(args.openscad)
    except FileNotFoundError as error:
        print(f"error: {error}", file=sys.stderr)
        return 127

    output_dir = (
        args.output_dir.resolve()
        if args.output_dir
        else model.with_name(f"{model.stem}-review")
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    results: list[RenderResult] = []
    for view in View:
        print(f"Rendering {view.label}...", flush=True)
        result = render_view(
            executable,
            model,
            output_dir,
            view,
            args.size,
            args.define,
            args.preview,
        )
        results.append(result)
        if result.return_code != 0:
            print(result.output, file=sys.stderr)
            print(f"error: {view.label} render failed", file=sys.stderr)
            return result.return_code

    write_overview(output_dir, model, results)
    manifest = {
        "model": str(model),
        "model_sha256": sha256(model),
        "openscad": str(executable),
        "size": list(args.size),
        "projection": "orthographic",
        "mode": "preview" if args.preview else "render",
        "defines": args.define,
        "results": [asdict(result) for result in results],
    }
    (output_dir / "manifest.json").write_text(
        json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
    )
    print(f"Review renders written to {output_dir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
