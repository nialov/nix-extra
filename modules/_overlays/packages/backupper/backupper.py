#!/usr/bin/env python3
"""
Archiver and backup script.
"""

import subprocess
import sys
from pathlib import Path
from typing import List

import typer
from rich.console import Console

print = Console().print

APP = typer.Typer()

EXCLUDES = [
    ".git",
    ".nox",
    ".pytest_cache",
    ".cache",
    ".direnv",
    ".ipynb_checkpoints",
    ".fractopo_cache",
    "__pycache__",
]


def parse_excludes(excludes: List[str]) -> List[str]:
    """
    Generate 7zip exclude options.
    """
    return [f"-xr!{exclude}" for exclude in excludes]


def sizeof_fmt(num, suffix="B"):
    """
    Get human-readable size of file.
    """
    for unit in ["", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"]:
        if abs(num) < 1024.0:
            return f"{num:3.1f}{unit}{suffix}"
        num /= 1024.0
    return f"{num:.1f}Yi{suffix}"


def backup_project(project: Path, remote_path: Path, stdout):
    """
    Backup a project directory.
    """
    if project.is_file():
        print(f"Ignoring {project} as it is a file rather than a directory.")
        return

    print()
    print(f"Starting 7zip archiving of {project}.")

    output_archive_path = remote_path / project.with_suffix(".7z").name
    exists_text = "Exists" if output_archive_path.exists() else "Does not exist"
    print(f"Destination -> {output_archive_path} ({exists_text}).")

    subprocess.check_call(
        [
            "7z",
            # Use update switch
            "u",
            # Output 7z archive path
            str(output_archive_path),
            # Backup src folder path
            str(project),
            # Add directory excludes
            *parse_excludes(EXCLUDES),
            # Allow removing files from destination output 7z archine
            # Also removes files that are later excluded even if they already exist in 7z archive
            "-up0q0",
        ],
        stdout=stdout,
    )

    archive_size = sizeof_fmt(output_archive_path.stat().st_size)
    print(
        f"Finished 7zip archiving to {output_archive_path}. Size of archive is {archive_size}."
    )


@APP.command()
def main(
    project_path: Path = typer.Argument(...),
    remote_path: Path = typer.Option(...),
    verbose: bool = typer.Option(False),
):
    """
    Backup projects.
    """
    if not remote_path.exists():
        raise FileNotFoundError(f"Expected remote path to exist at {remote_path}")

    if verbose:
        stdout = sys.stdout
    else:
        stdout = subprocess.DEVNULL

    for project in project_path.iterdir():
        backup_project(project=project, remote_path=remote_path, stdout=stdout)


if __name__ == "__main__":
    APP()
