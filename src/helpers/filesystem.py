from pathlib import Path


def find_pyproject_parent(start_path: str = ".") -> Path:
    """
    Walk up the directory tree from start_path to find the first parent containing pyproject.toml.
    Returns the Path to that directory, or None if not found.
    """
    path = Path(start_path).resolve()
    for parent in [path] + list(path.parents):
        if (parent / "pyproject.toml").is_file():
            return parent

    raise FileNotFoundError("No pyproject.toml found in parent directories.")


def find_flake_parent(start_path: str = ".") -> Path:
    """
    Walk up the directory tree from start_path to find the first parent containing flake.nix.
    Returns the Path to that directory, or None if not found.
    """
    path = Path(start_path).resolve()
    for parent in [path] + list(path.parents):
        if (parent / "flake.nix").is_file():
            return parent

    raise FileNotFoundError("No flake.nix found in parent directories.")