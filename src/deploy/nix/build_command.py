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

    # Base command
    cmd_parts = [
        "nixos-rebuild",
        build_type,
        "--flake",
        f"{ctx.obj.flake_root}#{ctx.obj.hostname}",
    ]

    # Add options based on context
    ctx.obj.dbg("Setting options in build command")
    if ctx.obj.show_trace:
        ctx.obj.dbg("Adding --show-trace to build command")
        cmd_parts.append("--show-trace")

    if ctx.obj.force:
        ctx.obj.dbg("Adding --force to build command")
        cmd_parts.append("--force")

    # if ctx.obj.update_input != "":
    #     ctx.obj.dbg("Adding --update_input to build command")
    #     cmd_parts.append("--update-input")
    #     cmd_parts.append(ctx.obj.update_input)

    # Update the build command
    ctx.obj.build_command = ctx.obj.build_command.map(lambda cmd: cmd + cmd_parts)

    ctx.obj.info(f"Constructed build command: {' '.join(cmd_parts)}")

    ctx.obj.dbg(f"Build command set: {' '.join(list(ctx.obj.build_command.unwrap()))}")

    return ctx


def run_build_command(ctx: typer.Context) -> Result[typer.Context, str]:
    ctx.obj.info(f"Executing build command: {ctx.obj.build_command.unwrap()}")

    def run_if(flag: bool, msg: str, args: list[str]) -> Result[None, str]:
        if not flag:
            return Success(None)
        ctx.obj.info(msg)
        res: Result[None, str] = ctx.obj.run_command(args)  # assume Result[None, str]
        if not is_successful(res):
            ctx.obj.error(f"Flake update failed: {res.failure()}")
            return Failure(res.failure())
        return res

    result = Success(None)

    result: Result[None, str] = result.bind( # type: ignore
        lambda _: run_if(
            ctx.obj.update,
            "Updating all flake inputs",
            ["nix", "flake", "update", "--flake", f"{ctx.obj.flake_root}"],
        )  
    )

    result: Result[None, str] = result.bind( # type: ignore
        lambda _: run_if(
            bool(ctx.obj.update_input),
            f"Updating flake inputs: {ctx.obj.update_input}",
            [
                "nix",
                "flake",
                "update",
                "--flake",
                f"{ctx.obj.flake_root}",
                ctx.obj.update_input,
            ],
        )
    )

    command: List[str] = ["direnv", "exec", "."] + ctx.obj.build_command.unwrap()

    result = ctx.obj.run_command(command)

    if is_successful(result):
        ctx.obj.info("Build command executed successfully")
        return Success(ctx)
    else:
        ctx.obj.error(f"Build command failed: {result.failure()}")
        return Failure(result.failure())
