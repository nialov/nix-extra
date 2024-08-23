#!/user/bin/env python3
import subprocess
from pathlib import Path

import typer
from rich.console import Console
from rich.traceback import install

install(show_locals=False, max_frames=1, extra_lines=0)


APP = typer.Typer()
CONSOLE = Console()


@APP.command()
def main(regex: str = typer.Argument(...), directory: Path = typer.Option("")):
    """
    Search through git history.

    Limits to ``directory`` if given.
    """

    def run_process(args: list):
        result = subprocess.run(args, capture_output=True, encoding="utf-8")
        result.check_returncode()
        return result

    use_directory = len(str(directory.stem)) > 0

    directory_args = ["--", str(directory)] if use_directory else []
    rev_result = run_process(["git", "rev-list", "--all"] + directory_args)
    revs = rev_result.stdout.splitlines()

    results = []
    for rev in revs:
        try:
            grep_result = run_process(["git", "grep", regex, rev] + directory_args)
            results.append(grep_result)
        except subprocess.CalledProcessError:
            results.append(None)

    for rev, result in zip(revs, results):
        if result is not None:
            result_stdout = result.stdout
            if len(result_stdout) > 10:
                header = run_process(
                    [
                        "git",
                        "log",
                        "--name-status",
                        "--diff-filter=ACDMRT",
                        "-1",
                        "-U",
                        rev,
                    ]
                )
                CONSOLE.print(header.stdout)
                CONSOLE.print(result_stdout)
                CONSOLE.print()


if __name__ == "__main__":
    APP()
