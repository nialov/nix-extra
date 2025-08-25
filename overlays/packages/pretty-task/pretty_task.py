#!/usr/bin/env python3
"""
Pretty printing completed tasks from taskwarrior.
"""

import subprocess
import os
from typing import Any, Dict, List

import json5
import typer
from rich.console import Console
from tabulate import tabulate

print = Console(width=120).print


APP = typer.Typer()


@APP.command()
def main(
    task_executable: str = typer.Option(
        os.environ.get("PRETTY_TASK_TASKWARRIOR_EXECUTABLE", "task")
    ),
    end_interval: str = typer.Option("48h"),
    # column_config: str = typer.Option(
    #     "rc.report.completed.columns=project,description"
    # ),
    # column_label_config: str = typer.Option(
    #     "rc.report.completed.labels=Project,Description"
    # ),
    optional_columns: List[str] = typer.Option([]),
):
    """
    Export tasks in a pretty table.
    """
    today_config = f"end.after:now-{end_interval}our"

    exported_tasks_json = subprocess.check_output(
        [
            task_executable,
            # column_config, column_label_config,
            today_config,
            "rc.verbose=no",
            "export",
        ]
    ).decode("UTF-8")

    exported_tasks_parsed_list: List[Dict[str, Any]] = json5.loads(exported_tasks_json)

    if len(exported_tasks_parsed_list) == 0:
        return

    exported_tasks_parsed_dict = dict()
    for item in exported_tasks_parsed_list:
        for key, value in item.items():
            if key not in exported_tasks_parsed_dict:
                exported_tasks_parsed_dict[key] = [value]
            else:
                exported_tasks_parsed_dict[key].append(value)

    for opt_col in optional_columns:
        if opt_col not in exported_tasks_parsed_dict:
            exported_tasks_parsed_dict[opt_col] = [
                [] for _ in range(len(exported_tasks_parsed_dict))
            ]
    wanted_columns = ["description", "project", *optional_columns]
    exported_tasks_parsed_filtered = {
        key: value
        for key, value in exported_tasks_parsed_dict.items()
        if key in wanted_columns
    }

    df_as_rst = tabulate(
        exported_tasks_parsed_filtered,
        headers=[col.capitalize() for col in exported_tasks_parsed_filtered],
        tablefmt="rst",
        showindex=False,
        # maxcolwidths=80,
    )

    process_result = subprocess.run(
        ["pandoc", "--from", "rst", "--to", "rst"],
        stdout=subprocess.PIPE,
        input=df_as_rst,
        encoding="UTF-8",
    )
    formatted_result = process_result.stdout
    print(formatted_result)


if __name__ == "__main__":
    APP()
