from deploy.context import BuildType
from deploy.build_command import create_build_command, run_build_command
from deploy.app import app
from deploy.context import common_params
from helpers.rich import rich_pretty_to_string


import typer
from returns.maybe import Some
from returns.pipeline import flow, is_successful
from returns.result import Result


@app.command()
@common_params
def dry_activate(ctx: typer.Context):
    ctx.obj.dbg("Setting build type to DRY_ACTIVATE")
    ctx.obj.build_type = Some(BuildType.DRY_ACTIVATE)
    ctx.obj.dbg("Context object initialized")
    ctx.obj.dbg(rich_pretty_to_string(ctx, expand_all=True))

    result: Result[typer.Context, str] = flow(
        ctx,  # Start with the context object
        create_build_command,  # Result[str, str]
        run_build_command,  # Result[typer.Context, str]
    )

    if is_successful(result):
        ctx.obj.logger.info("Dry activation successful!")
    else:
        ctx.obj.logger.error(f"Dry activation failed: {result.failure()}")
        raise typer.Exit(code=1)
