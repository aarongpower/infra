#!/usr/bin/env python3
"""Convert docker-compose directories to Nix modules using compose2nix.

This script mirrors the behaviour of the original shell version used in a Nix
build:

    1. Finds every `docker-compose.yml` under the given containers directory.
    2. Optionally executes a custom `compose2nix.command` if present next to the
       compose file; otherwise runs `compose2nix -project=<name>`.
    3. Collects all generated `<name>-docker-compose.nix` files under $out and
       writes a single `containers.nix` that imports them.

Usage (inside a Nix build environment where the `$out` variable is defined):

    build_containers.py ./systems/my‑host/containers

The resulting layout under $out will be:

    $out/
      ├── containers.nix           # central module importing each compose file
      ├── project1-docker-compose.nix
      ├── project2-docker-compose.nix
      └── ...
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Iterable, Set


def find_compose_dirs(root: Path) -> Set[Path]:
    """Return unique directories containing a docker‑compose.yml under *root*."""
    return {
        p.parent.resolve()
        for p in root.rglob("docker-compose.yml")
        if p.is_file()
    }


def write_containers_header(f):
    f.write("{ pkgs, lib, ... }:\n")
    f.write("{\n")
    f.write("  imports = [\n")


def write_containers_footer(f):
    f.write("  ];\n")
    f.write("}\n")


def run_compose2nix(project_dir: Path, project_name: str):
    """Run `compose2nix` for a project already staged in *project_dir*."""
    subprocess.run(
        ["compose2nix", f"-project={project_name}"],
        check=True,
        cwd=project_dir,
    )


def run_custom_command(project_dir: Path, command_file: Path):
    """Execute the custom shell command defined in *command_file* inside *project_dir*."""
    command = command_file.read_text()
    subprocess.run(command, shell=True, check=True, cwd=project_dir)


def stage_project(tmp_root: Path, source_dir: Path, files: Iterable[str]) -> Path:
    """Copy *files* from *source_dir* into a new project directory under *tmp_root*."""
    project_name = source_dir.name
    dest = tmp_root / project_name
    dest.mkdir()
    for name in files:
        shutil.copy(source_dir / name, dest)
    return dest


def build_projects(compose_dirs: Iterable[Path], out: Path, tmp_root: Path, f):
    for dir_path in sorted(compose_dirs):
        project_name = dir_path.name
        print(f"\n→ {project_name}:", flush=True)

        compose_file = dir_path / "docker-compose.yml"
        command_file = dir_path / "compose2nix.command"

        if command_file.exists():
            print("  • Found compose2nix.command – using custom build command")
            project_tmp = stage_project(tmp_root, dir_path, ["docker-compose.yml", "compose2nix.command"])
            run_custom_command(project_tmp, command_file)
        elif compose_file.exists():
            print("  • Running compose2nix default path")
            project_tmp = stage_project(tmp_root, dir_path, ["docker-compose.yml"])
            run_compose2nix(project_tmp, project_name)
        else:
            print("  • Skipped – no docker-compose.yml present")
            continue

        # Move generated file into $out and record import
        dest = out / f"{project_name}-docker-compose.nix"
        shutil.move(project_tmp / "docker-compose.nix", dest)
        f.write(f'    "{dest}"\n')


def main():
    if len(sys.argv) != 2:
        print("Usage: build_containers.py <containersDir>", file=sys.stderr)
        sys.exit(1)

    containers_dir = Path(sys.argv[1]).resolve()
    if not containers_dir.is_dir():
        sys.exit(f"Error: {containers_dir} is not a directory")

    out = Path(os.environ.get("out", "./result")).resolve()
    out.mkdir(parents=True, exist_ok=True)
    print(f"Building docker‑compose containers found in {containers_dir}")

    compose_dirs = find_compose_dirs(containers_dir)
    if not compose_dirs:
        print("No docker‑compose.yml files found – nothing to do.")
        return

    tmp_root = Path(tempfile.mkdtemp())
    print(f"Using temporary directory: {tmp_root}")

    try:
        containers_nix_path = out / "containers.nix"
        with containers_nix_path.open("w") as f:
            write_containers_header(f)
            build_projects(compose_dirs, out, tmp_root, f)
            write_containers_footer(f)
    finally:
        shutil.rmtree(tmp_root)
        print("Clean‑up complete.")


if __name__ == "__main__":
    main()