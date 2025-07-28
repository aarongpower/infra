from typing import List

import typer
from returns.maybe import Some
from returns.pipeline import flow, is_successful
from returns.result import Result, Success, Failure

from deploy.app import app
from deploy.context import BuildType, common_params


def create_nickel_command(ctx: typer.Context) -> Result[typer.Context, str]:
    """Create the tf-ncl command to convert Nickel files to Terraform."""
    ctx.obj.dbg("Creating tf-ncl command")
    
    config_path = ctx.obj.nickel_dir / "tf-ncl.ncl"
    
    # Check if tf-ncl config exists
    if not config_path.exists():
        return Failure(f"Config file not found: {config_path}")
    
    # Make sure terraform directory exists
    ctx.obj.terraform_dir.mkdir(parents=True, exist_ok=True)
    
    # Create command and store it in the context
    tf_ncl_cmd = ["tf-ncl", "convert", "--config", str(config_path)]
    ctx.obj.nickel_build_command = Some(tf_ncl_cmd)
    
    ctx.obj.dbg(f"tf-ncl command: {tf_ncl_cmd}")
    return Success(ctx)


def run_nickel_command(ctx_result: Result[typer.Context, str]) -> Result[typer.Context, str]:
    """Run the tf-ncl command using the context's run_command method."""
    if ctx_result.is_failure():
        return Failure(ctx_result.failure())
    
    ctx = ctx_result.unwrap()
    
    if ctx.obj.nickel_build_command.is_nothing():
        return Failure("No nickel build command found in context")
    
    command = ctx.obj.nickel_build_command.unwrap()
    
    ctx.obj.info(f"Running: {' '.join(command)}")
    result = ctx.obj.run_command(command)
    
    if result.is_success():
        ctx.obj.info("Terraform files generated successfully")
        return Success(ctx)
    else:
        return Failure(f"tf-ncl command failed: {result.failure()}")


@app.command()
@common_params
def nickel(ctx: typer.Context):
    """Generate Terraform files from Nickel files using tf-ncl."""
    ctx.obj.dbg("Initializing Nickel to Terraform conversion")
    ctx.obj.build_type = Some(BuildType.BUILD)  # Reuse the BUILD type
    
    result = flow(
        ctx,
        create_nickel_command,
        run_nickel_command,
    )
    
    if not is_successful(result):
        ctx.obj.error(f"Nickel to Terraform conversion failed: {result.failure()}")
        raise typer.Exit(code=1)