from io import StringIO
from rich.console import Console
from rich.pretty import pretty_repr

from typing import Any


def rich_to_str(*objects: Any, **kwargs: Any) -> str:
    buf = StringIO()
    Console(file=buf, force_terminal=True).print(*objects, **kwargs)
    return buf.getvalue()


def rich_pretty_to_string(*objects: Any, **kwargs: Any) -> str:
    """
    Pretty print objects using Rich's Pretty class.
    """
    from rich.pretty import Pretty

    buf = StringIO()
    console = Console(file=buf, force_terminal=False)
    for obj in objects:
        if has_custom_repr(obj):
            console.print(pretty_repr(obj))
        else:
            # Use vars() to get the object's attributes if no custom repr
            console.print(Pretty(vars(obj), **kwargs))
    return buf.getvalue()


def has_custom_repr(obj: object) -> bool:
    return obj.__class__.__repr__ is not object.__repr__


def code_string(code: str) -> str:
    """
    Format a code string with Rich's Text styling.
    """
    from rich.text import Text

    code_str = Text(code)
    code_str.stylize(
        "bold bright_black", 0, len(code)
    )  # Apply bold gray style to the entire string
    return str(code_str)
