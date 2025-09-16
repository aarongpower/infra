from typing import Annotated

import typer

from deploy.context import Context


def _root_callback(
    ctx: typer.Context,
    debug: Annotated[
        bool, typer.Option("--debug", "-d", help="Enable debug output")
    ] = False,
) -> None:
    print("App callback invoked")
    # Initialize context
    ctx.obj = ctx.obj or Context()
    ctx.obj.info("App context initialized")
    print(f"Debug flag is {'on' if debug else 'off'}")
    if ctx.obj.debug and hasattr(ctx.obj, "dbg"):
        ctx.obj.dbg("Debug mode enabled at app level")


# Create the main app with the callback wired at construction time
app = typer.Typer(name="carson", no_args_is_help=True, callback=_root_callback)

# Import sub-apps
from deploy.nix.app import nix_app

# Add sub-apps to the main app
app.add_typer(nix_app, name="nix")
