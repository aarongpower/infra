import typer

from deploy.app import app
from deploy.context import common_params


@app.command()
@common_params
def diff(ctx: typer.Context):
    ctx.obj.info(
        "Comparing closures... with path to flake root: {}".format(ctx.obj.flake_root)
    )
    command = [
        "nix",
        "store",
        "diff-closures",
        str(ctx.obj.flake_root / "result"),
        "/run/current-system",
    ]

    ctx.obj.run_command(command)

    return ctx
