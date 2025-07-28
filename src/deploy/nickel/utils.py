import typer
from returns.maybe import Nothing, Some
from returns.result import Failure, Result, Success


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
    nickel_cmd = ["nickel", "export", str(config_path)]
    ctx.obj.nickel_build_command = Some(nickel_cmd)

    ctx.obj.dbg(f"nickel command: {nickel_cmd}")
    return Success(ctx)


def run_nickel_command(ctx: typer.Context) -> Result[typer.Context, str]:
    """Run the nickel command using the context's run_command method."""
    if ctx.obj.nickel_build_command == Nothing:
        raise ValueError("No nickel build command found in context")

    command = ctx.obj.nickel_build_command.unwrap()

    ctx.obj.info(f"Running: {' '.join(command)}")
    result = ctx.obj.run_command(command)

    if result.is_success():
        ctx.obj.info("Terraform files generated successfully")
        return Success(ctx)
    else:
        return Failure(f"tf-ncl command failed: {result.failure()}")
