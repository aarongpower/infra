import typer
from returns.maybe import Some
from returns.pipeline import flow, is_successful
from returns.result import Result

from deploy.context import BuildType
from deploy.nix.app import nix_app
from deploy.nix.build_command import create_build_command, run_build_command


@nix_app.command()
def build(ctx: typer.Context):
    """Build the NixOS configuration without activating it."""
    ctx.obj.dbg("Setting build type to BUILD")
    ctx.obj.build_type = Some(BuildType.BUILD)

    result: Result[typer.Context, str] = flow(
        ctx,  # Start with the context object
        create_build_command,  # Result[str, str]
        run_build_command,  # Result[typer.Context, str],
    )

    if is_successful(result):
        ctx.obj.info("Deployment successful!")
    else:
        ctx.obj.error(f"Deployment failed: {result.failure()}")
        raise typer.Exit(code=1)


@nix_app.command()
def switch(ctx: typer.Context):
    """Build and activate the NixOS configuration."""
    ctx.obj.dbg("Setting build type to SWITCH")
    ctx.obj.build_type = Some(BuildType.SWITCH)

    def builder(ctx: typer.Context) -> typer.Context:
        return create_build_command(ctx, True)

    result: Result[typer.Context, str] = flow(
        ctx,  # Start with the context object
        builder,  # Result[str, str]
        run_build_command,  # Result[typer.Context, str],
    )

    if is_successful(result):
        ctx.obj.info("Switch successful!")
    else:
        ctx.obj.error(f"Switch failed: {result.failure()}")
        raise typer.Exit(code=1)


@nix_app.command()
def dry_activate(ctx: typer.Context):
    """Test the activation of the NixOS configuration without applying it."""
    ctx.obj.dbg("Setting build type to DRY_ACTIVATE")
    ctx.obj.build_type = Some(BuildType.DRY_ACTIVATE)

    result: Result[typer.Context, str] = flow(
        ctx,  # Start with the context object
        create_build_command,  # Result[str, str]
        run_build_command,  # Result[typer.Context, str]
    )

    if is_successful(result):
        ctx.obj.info("Dry activation successful!")
    else:
        ctx.obj.error(f"Dry activation failed: {result.failure()}")
        raise typer.Exit(code=1)
