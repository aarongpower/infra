# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Changing document

IMPORTANT: This document (CLAUDE.md) should be updated whenever meaningful changes are made to the code in this repo.

## Repository Overview

This repository contains infrastructure-as-code configurations for personal infrastructure, using a combination of:

- NixOS/Nix for system configuration
- Nickel to generate config where it spans both Nix and Terraform
- Python CLI tool (called `carson`) for deployment operations

The codebase is structured with a Python CLI (`carson`) that orchestrates the deployment of NixOS configurations and Nickel-to-Terraform conversions.

## Key Directories

- `/nix`: Contains all Nix configurations
  - `flake.nix`: The main entry point for NixOS configurations
  - `nixosSystems/`: Configurations for NixOS machines
  - `home/`: Home-manager configurations
  - `_devshells/`: Development environment definitions
  - `_common/`: Shared configurations

- `/nickel`: Contains Nickel files for generating configurations
  - `tf-ncl.ncl`: Main Nickel configuration for Terraform generation

- `/src`: Contains the Python CLI tool for deployment
  - `deploy/`: Command modules for the CLI
  - `helpers/`: Utility functions

## CLI Commands

The project includes a Python-based CLI tool (`carson`) with the following commands:

### Nix Commands

```bash
# Build the NixOS configuration without activating it
carson nix build [--force] [--show-trace] [--debug] [--flake-root PATH] [--hostname HOSTNAME]

# Build and activate the NixOS configuration (requires sudo)
carson nix switch [--force] [--show-trace] [--debug] [--flake-root PATH] [--hostname HOSTNAME]

# Test activation without applying (dry run)
carson nix dry-activate [--force] [--show-trace] [--debug] [--flake-root PATH] [--hostname HOSTNAME]
```

### Nickel Commands

```bash
# Generate Terraform files from Nickel configuration
carson nickel build [--force] [--show-trace] [--debug] [--flake-root PATH] [--hostname HOSTNAME]
```

## Development Setup

1. Set up the development environment using Nix flakes:

```bash
# Enter the development shell
nix develop

# Or if direnv is installed, just cd into the directory
# The .envrc file will automatically load the development environment
# May need to run `direnv allow` to activate first time or when changes to important files are made
```

2. The development shell includes:
   - Python 3.12
   - uv (Python package manager)
   - Terraform
   - Ansible
   - Nickel and tf-ncl
   - Various formatting tools (nixfmt, alejandra)

3. The shell automatically sets up a Python virtual environment in `.venv` and installs dependencies from `pyproject.toml`

## Common Workflows

1. **Deploying NixOS Configuration**:
   ```bash
   # Check what would change (dry run)
   carson nix dry-activate
   
   # Deploy the changes
   carson nix switch
   ```

2. **Working with Nickel and Terraform**:
   ```bash
   # Generate Terraform configurations from Nickel
   carson nickel build
   
   # Review generated Terraform files
   cd terraform
   ```

## Architecture Notes

- The CLI tool (`carson`) is designed to be a wrapper around NixOS, Nickel, and Terraform tooling
- The tool uses a Context object to maintain state during operations
- Commands are organized into sub-apps (nix, nickel) for better organization
- The tool logs all operations to files in the `logs/` directory
- Configuration is determined based on the current hostname

## IMPORTANT: Code style
- python
    - always specify types, we use strict type checking
    - in general always use `returns` types like Maybe and Result where relevant
    - code is formatted with Ruff
- nix
    - code is formatted with Alejandra