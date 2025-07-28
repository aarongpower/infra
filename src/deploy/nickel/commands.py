import typer
from returns.maybe import Some
from returns.pipeline import flow, is_successful
from returns.pointfree import bind
from returns.result import Result

from deploy.context import BuildType, common_params
from deploy.nickel.app import nickel_app
from deploy.nickel.utils import create_nickel_command, run_nickel_command


@nickel_app.command()
@common_params
def build(ctx: typer.Context):
    """Generate Terraform files from Nickel files using tf-ncl."""
    ctx.obj.dbg("Initializing Nickel to Terraform conversion")
    ctx.obj.build_type = Some(BuildType.BUILD)  # Reuse the BUILD type

    result: Result[typer.Context, str] = flow(
        ctx,
        create_nickel_command,
        bind(run_nickel_command),
    )

    if not is_successful(result):
        ctx.obj.error(f"Nickel to Terraform conversion failed: {result.failure()}")
        raise typer.Exit(code=1)
