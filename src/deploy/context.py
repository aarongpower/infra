import errno
import fcntl
import getpass
import logging
import os
import re
import shutil
import socket
import struct
import subprocess
import sys
import termios
import time
from functools import wraps
from pathlib import Path
from types import TracebackType
from typing import Any, Callable, List, Optional, Type

import click
import typer
from returns.maybe import Maybe, Nothing
from returns.result import Failure, Result, Success
from rich import print
from rich.console import Console
from rich.logging import RichHandler

from helpers.filesystem import find_pyproject_parent


class BuildType(str):
    SWITCH = "switch"
    BUILD = "build"
    DRY_ACTIVATE = "dry-activate"


def get_flake_root() -> Path:
    """Get the flake root directory."""
    return find_pyproject_parent(os.getcwd()) / "nix"


class Context:
    def __init__(self):
        self.build_type: Maybe[BuildType] = Nothing
        self.build_command: Maybe[List[str]] = Nothing
        self.nickel_build_command: Maybe[List[str]] = Nothing
        self.project_root: Path = find_pyproject_parent()
        self.flake_root: Path = get_flake_root()
        self.nickel_dir: Path = self.project_root / "nickel"
        self.terraform_dir: Path = self.project_root / "terraform"
        self.force: bool = False
        self.show_trace: bool = False
        self.debug: bool = False
        self.hostname: str = socket.gethostname()
        self.log_path: Path = (
            self.project_root
            / "logs"
            / f"{self.hostname}-{getpass.getuser()}-{time.strftime('%Y-%m-%dT%H-%M-%S')}.log"
        )
        self.log_path.parent.mkdir(parents=True, exist_ok=True)

        # ── file handler: everything goes to disk
        file_handler = logging.FileHandler(self.log_path, encoding="utf-8")
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(
            logging.Formatter("%(asctime)s %(levelname)s %(message)s")
        )

        # ── console handler: INFO by default, DEBUG when --debug
        console_handler = RichHandler(
            show_time=False, show_level=False, show_path=False
        )
        console_handler.setLevel(logging.DEBUG if self.debug else logging.INFO)

        # ── main logger
        self.logger = logging.getLogger("deploy")
        self.logger.setLevel(logging.DEBUG)  # never drop messages here
        self.logger.addHandler(console_handler)
        self.logger.addHandler(file_handler)

        # ── helper logger used in run_command (“file‑only”)
        self.file_logger = logging.getLogger("deploy.file")
        self.file_logger.setLevel(logging.DEBUG)
        self.file_logger.addHandler(file_handler)  # attach handler
        self.file_logger.propagate = False

        self.console = Console()

        self.dbg(f"Context initialized: {self.__dict__}")

    def run_command(self, command: list[str]) -> Result[int, str]:
        ansi_escape = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
        last_line = ""

        master, slave = os.openpty()

        # ──► make the PTY as wide as the real terminal (or at least wide enough)
        ts = shutil.get_terminal_size(fallback=(240, 24))
        winsize = struct.pack("HHHH", ts.lines, ts.columns, 0, 0)  # rows, cols
        fcntl.ioctl(slave, termios.TIOCSWINSZ, winsize)

        env = os.environ.copy()
        env["COLUMNS"], env["LINES"] = str(ts.columns), str(ts.lines)

        proc = subprocess.Popen(
            command,
            stdin=slave,
            stdout=slave,
            stderr=slave,
            close_fds=True,
            preexec_fn=os.setsid,
            env=env,  # pass the width/height vars too
        )
        os.close(slave)

        buffer = ""
        try:
            while True:
                try:
                    data = os.read(master, 1024)
                except OSError as e:
                    if e.errno == errno.EIO:
                        break
                    raise
                if not data:
                    break

                text = data.decode(errors="replace")
                sys.stdout.write(text)
                sys.stdout.flush()

                buffer += text.replace("\r", "\n")

                while "\n" in buffer:
                    line, buffer = buffer.split("\n", 1)
                    clean = ansi_escape.sub("", line).strip()
                    if clean and clean != last_line:
                        self.file_logger.info(clean)
                        last_line = clean

            if buffer:
                clean = ansi_escape.sub("", buffer).strip()
                if clean and clean != last_line:
                    self.file_logger.info(clean)

            proc.wait()
        finally:
            os.close(master)

        return (
            Success(proc.returncode)
            if proc.returncode == 0
            else Failure(f"exit {proc.returncode}")
        )

    def __enter__(self) -> "Context":
        return self

    def __exit__(
        self,
        exc_type: Optional[Type[BaseException]],
        exc_val: Optional[BaseException],
        exc_tb: Optional[TracebackType],
    ) -> Optional[bool]:
        ansi_escape = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
        last_line: Optional[str] = None
        try:
            with open(self.log_path, "r", encoding="utf-8") as infile:
                lines = infile.readlines()
            with open(self.log_path, "w", encoding="utf-8") as outfile:
                for line in lines:
                    clean = ansi_escape.sub("", line)
                    if clean != last_line:
                        outfile.write(clean)
                        last_line = clean
        except Exception as e:
            print(f"Error cleaning log file: {e}")
        return None

    def info(self, text: str) -> None:
        self.logger.info(text)

    def error(self, text: str) -> None:
        self.logger.error(text)

    def warn(self, text: str) -> None:
        self.logger.warning(text)

    def dbg(self, text: str) -> None:
        self.logger.debug(text)


def common_params(f: Callable[..., Any]) -> Any:
    @click.option("--force", is_flag=True, default=False)
    @click.option("--show-trace", is_flag=True, default=False)
    @click.option("--debug", is_flag=True, default=False)
    @click.option(
        "--flake-root",
        default=get_flake_root(),
        show_default=True,
        type=click.Path(exists=True, file_okay=False, dir_okay=True, path_type=Path),
    )
    @click.option("--hostname", default=socket.gethostname())
    @wraps(f)
    def wrapper(
        *args: Any,
        ctx: typer.Context,
        flake_root: Path = get_flake_root(),
        force: bool = False,
        show_trace: bool = False,
        debug: bool = False,
        hostname: str = socket.gethostname(),
        **kwargs: Any,
    ):
        ctx.obj.dbg("Setting context parameters")
        ctx.obj.flake_root = flake_root
        ctx.obj.force = force
        ctx.obj.show_trace = show_trace
        ctx.obj.debug = debug
        ctx.obj.hostname = hostname
        ctx.obj.dbg(vars(ctx.obj))
        return f(*args, ctx=ctx, **kwargs)

    return wrapper
