import typer

from deploy.app import app
from deploy.context import common_params


@app.command()
@common_params
def show(ctx: typer.Context):
    """
    Run `nix show` on the flake root directory.
    """
    command = ["nix", "flake", "show", str(ctx.obj.flake_root)]

    if ctx.obj.hostname:
        command.append(f"#{ctx.obj.hostname}")

    ctx.obj.run_command(command)

    return ctx
