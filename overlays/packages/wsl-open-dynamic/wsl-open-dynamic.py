#!/usr/bin/env python3
"""
Script for intelligent wsl-open.
"""

import os
import subprocess
from pathlib import Path
from textwrap import dedent
from typing import List

import typer

APP = typer.Typer()


@APP.command()
def main(args: List[str] = typer.Argument(...)):
    """
    Main entrypoint.
    """
    mnt_path = Path("/mnt/")
    powershell_path_suffix = "Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
    attempts = []
    for letter in ("c", "d", "f"):
        powershell_path = mnt_path / letter / powershell_path_suffix
        new_env = os.environ.copy()
        new_env["PATH"] = ":".join((f"{powershell_path.parent}", new_env["PATH"]))
        if powershell_path.exists():
            subprocess.check_call(["wsl-open", *args], env=new_env)
            return
        attempts.append(powershell_path)
    raise SystemError(
        dedent(
            f"""
        Expected to find powershell.exe in one of
        {attempts}
        """.strip()
        )
    )


if __name__ == "__main__":
    APP()
