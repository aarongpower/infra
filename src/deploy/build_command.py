from typing import List

import typer
from returns.maybe import Some
from returns.pipeline import is_successful
from returns.result import Failure, Result, Success


def create_build_command(
    ctx: typer.Context,
    root: bool = False,
) -> typer.Context:
    build_type: str = ctx.obj.build_type.unwrap()

    ctx.obj.dbg(f"build type: {build_type}")

    if root:
        ctx.obj.dbg("Running in root mode, using sudo")
        ctx.obj.build_command = Some(["sudo"])
    else:
        ctx.obj.dbg("Running in user mode")
        ctx.obj.build_command = Some([])

    ctx.obj.build_command = ctx.obj.build_command.map(
        lambda cmd: cmd
        + [
            "nixos-rebuild",
            build_type,
            "--flake",
            f"{ctx.obj.flake_root}#{ctx.obj.hostname}",
        ]
    )

    # ctx.obj.build_command = Some(
    #     ["nixos-rebuild", build_type, "--flake", flake_build_path]
    # )

    if ctx.obj.show_trace:
        ctx.obj.build_command = ctx.obj.build_command.map(  # type: ignore
            lambda cmd: cmd + ["--show-trace"]  # type: ignore
        )

    ctx.obj.dbg(
        f"Build command set: {' '.join(list(ctx.obj.build_command.unwrap()))}"  # type: ignore
    )

    return ctx


def run_build_command(ctx: typer.Context) -> Result[typer.Context, str]:
    ctx.obj.logger.info(f"Executing build command: {ctx.obj.build_command.unwrap()}")

    command: List[str] = ["direnv", "exec", "."] + ctx.obj.build_command.unwrap()

    result = ctx.obj.run_command(command)

    if is_successful(result):
        ctx.obj.logger.info("Build command executed successfully")
        return Success(ctx)
    else:
        ctx.obj.logger.error(f"Build command failed: {result.failure()}")
        # ctx.obj.dbg(f"Command output: {cmd}")
        return Failure(result.failure())
