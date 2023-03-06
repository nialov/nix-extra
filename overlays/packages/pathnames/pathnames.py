#!/usr/bin/env python3
"""
Script for intelligent path handling using pathlib.
"""

from enum import Enum, unique
from pathlib import Path

import typer

APP = typer.Typer()


@unique
class Option(Enum):

    STEM = "stem"
    NAME = "name"
    ABSOLUTE = "absolute"
    RESOLVE = "resolve"


OPTION_DISPATCH = {
    Option.STEM: lambda path: path.stem,
    Option.NAME: lambda path: path.name,
    Option.ABSOLUTE: lambda path: path.absolute(),
    Option.RESOLVE: lambda path: path.resolve(),
}


def _dispatch(path: Path, option: Option):
    typer.echo(OPTION_DISPATCH[option](path))


@APP.command()
def stem(
    path: Path = typer.Argument(...),
):
    """
    Return filename stem.
    """
    _dispatch(path=path, option=Option.STEM)


@APP.command()
def name(
    path: Path = typer.Argument(...),
):
    """
    Return filename.
    """
    _dispatch(path=path, option=Option.NAME)


@APP.command()
def absolute(
    path: Path = typer.Argument(...),
    resolve: bool = typer.Option(True, help="Resolve full path (symlinks, etc.)."),
):
    """
    Return absolute path.
    """
    _dispatch(path=path, option=Option.RESOLVE if resolve else Option.ABSOLUTE)


if __name__ == "__main__":
    APP()
