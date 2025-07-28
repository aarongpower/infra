import typer

app = typer.Typer()

# Import sub-apps
from deploy.nix.app import nix_app
from deploy.nickel.app import nickel_app

# Add sub-apps to the main app
app.add_typer(nix_app, name="nix")
app.add_typer(nickel_app, name="nickel")
