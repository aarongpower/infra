from pathlib import Path

import typer

from deploy.context import (
    flake_root_option,
    force_option,
    hostname_option,
    show_trace_option,
)

# Create a simple Typer app
nix_app = typer.Typer(help="Nix-related commands")


@nix_app.callback()
def nix_callback(
    ctx: typer.Context,
    force: bool = force_option,
    show_trace: bool = show_trace_option,
    flake_root: Path = flake_root_option,
    hostname: str = hostname_option,
    update: bool = False,
    update_input: str = "",
) -> None:
    """Common callback for all nix commands."""
    # Make sure ctx.obj exists
    if ctx.obj is None:
        ctx.obj = type("Context", (), {})()
        ctx.obj.info("Nix context initialized")

    # Set values in the context object
    ctx.obj.force = force
    ctx.obj.show_trace = show_trace
    ctx.obj.flake_root = flake_root
    ctx.obj.hostname = hostname
    ctx.obj.update = update
    ctx.obj.update_input = update_input

    ctx.obj.info(
        f"Nix common parameters set: force={force}, show_trace={show_trace}, flake_root={flake_root}, hostname={hostname}, update_input={update_input}"
    )
