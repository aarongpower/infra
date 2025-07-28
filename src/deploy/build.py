import typer
from returns.maybe import Some
from returns.pipeline import flow, is_successful
from returns.result import Result

from deploy.app import app
from deploy.build_command import create_build_command, run_build_command
from deploy.context import BuildType, common_params
from helpers.rich import rich_pretty_to_string


@app.command()
@common_params
def build(ctx: typer.Context):
    ctx.obj.dbg("Initializing context object")
    ctx.obj.build_type = Some(BuildType.BUILD)
    ctx.obj.dbg("Context object initialized")
    ctx.obj.dbg(rich_pretty_to_string(ctx, expand_all=True))

    result: Result[typer.Context, str] = flow(
        ctx,  # Start with the context object
        create_build_command,  # Result[str, str]
        run_build_command,  # Result[typer.Context, str],
    )

    if is_successful(result):
        ctx.obj.logger.info("Deployment successful!")
    else:
        ctx.obj.logger.error(f"Deployment failed: {result.failure()}")
        raise typer.Exit(code=1)
