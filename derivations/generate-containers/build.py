"""
Build docker-compose containers with compose2nix.

This script will convert docker-compose files to Nix expressions using the
compose2nix tool. It will find all docker-compose.yml files in the given
directory, run compose2nix on each of them, and generate a Nix expression
that imports all the generated files.



"""

import os
import sys
from pathlib import Path

if __name__ == "__main__":
    # get and create the output path
    out = Path(os.environ["out"]).resolve()
    out.mkdir(parents=True, exist_ok=True)
    print(f"Building containres into {out}")
    # find the docker-compose files
    source = Path(sys.argv[1]).resolve()
    if not source.is_dir():
        sys.exit(f"Error: {source} is not a directory")

    # get a list of all dirs in the source that contain a docker-compose.yml file
    compose_dirs = [
        name
        for name in source.iterdir()
        if name.is_dir() and (name / "docker-compose.yml").exists()
    ]

    

    # run compose2nix on each of them
    # if the docker-compose file is in a dir with other files, copy those too
    # 