import typer

# Import the remaining top-level commands
import deploy.diff  # type: ignore # noqa: F401
import deploy.show  # type: ignore # noqa: F401

# Import subcommands
import deploy.nix.commands  # type: ignore # noqa: F401
import deploy.nickel.commands  # type: ignore # noqa: F401
from deploy.app import app

# Import all deploy modules to register their commands
# Ignored by type checkers since they are dynamically registered
# This is necessary to ensure that the commands are available when the app is run.
from deploy.context import Context


@app.callback()
def main(ctx: typer.Context) -> None:
    ctx.obj = Context()


if __name__ == "__main__":
    app()


# def print_context(ctx: typer.Context) -> typer.Context:
#     """
#     Print the context parameters.
#     """
#     ctx.obj.logger.info("Context parameters:")
#     max_len = max(len(param) for param in ctx.params)
#     for param, value in ctx.params.items():
#         ctx.obj.info(
#             f"{tab}{param.ljust(max_len)}: [bright black]{value}[/bright black]"
#         )

#     return ctx
