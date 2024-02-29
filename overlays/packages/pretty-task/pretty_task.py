#!/usr/bin/env python3
"""
Pretty printing completed tasks from taskwarrior.
"""

import subprocess
from datetime import datetime
from pathlib import Path
from textwrap import dedent

import json5
import pandas as pd
import typer
from rich.console import Console
from rich.table import Table
from tabulate import tabulate

print = Console(width=120).print


APP = typer.Typer()


@APP.command()
def completed(
    end_interval: str = typer.Option("48h"),
    column_config: str = typer.Option(
        "rc.report.completed.columns=project,description"
    ),
    column_label_config: str = typer.Option(
        "rc.report.completed.labels=Project,Description"
    ),
):
    """
    Export tasks in a pretty table.
    """
    today_config = f"end.after:now-{end_interval}our"

    exported_tasks_json = subprocess.check_output(
        ["task", column_config, column_label_config, today_config, "export"]
    ).decode("UTF-8")

    exported_tasks_parsed = json5.loads(exported_tasks_json)

    if len(exported_tasks_parsed) == 0:
        return

    df = pd.DataFrame(exported_tasks_parsed)
    optional_columns = ["tags"]
    for opt_col in optional_columns:
        if opt_col not in df.columns:
            df[opt_col] = [[] for _ in df.shape[0]]
    wanted_columns = ["description", "project", *optional_columns]
    df = df[wanted_columns]

    df_as_rst = tabulate(
        df,
        headers=[col.capitalize() for col in df.columns],
        tablefmt="rst",
        showindex=False,
        maxcolwidths=80,
    )

    process_result = subprocess.run(
        ["pandoc", "--from", "rst", "--to", "rst"],
        stdout=subprocess.PIPE,
        input=df_as_rst,
        encoding="UTF-8",
    )
    formatted_result = process_result.stdout
    print(formatted_result)


@APP.command()
def pending(
    suffix: str = typer.Option("list"),
):
    """
    Export pending tasks in a pretty table.
    """
    exported_tasks_json = subprocess.check_output(["task", "export", suffix]).decode(
        "UTF-8"
    )

    exported_tasks_parsed = json5.loads(exported_tasks_json)

    if len(exported_tasks_parsed) == 0:
        return

    df = pd.DataFrame(exported_tasks_parsed)
    optional_columns = []
    for opt_col in optional_columns:
        if opt_col not in df.columns:
            df[opt_col] = [[] for _ in df.shape[0]]
    wanted_columns = ["description", "project", "urgency", *optional_columns]
    df = df[wanted_columns]

    for col in ("description", "project"):
        df[col] = df[col].astype(str)

    projects_sorted_by_mean = (
        df.groupby("project")["urgency"].mean().sort_values(ascending=False)
    )
    projects = projects_sorted_by_mean.index.values
    project_means = projects_sorted_by_mean.values
    date = datetime.now().strftime("%Y.%m.%d")
    lines = [f"# Taskwarrior Task Status ({date})", ""]
    for project, project_mean in zip(projects, project_means):
        lines.append(f"## {project} ({project_mean:.1f})")
        project_df = df.loc[df["project"] == project]
        for _, row in project_df.iterrows():
            desc = row["description"]
            urgency = row["urgency"]
            message = dedent(
                f"""
                 -  {desc} ({urgency:.1f})
                 """
            )
            lines.append(message)

    process_result = subprocess.run(
        ["pandoc", "--from", "markdown", "--to", "markdown"],
        stdout=subprocess.PIPE,
        input="\n".join(lines),
        encoding="UTF-8",
    )
    formatted_result = process_result.stdout
    print(formatted_result)


if __name__ == "__main__":
    APP()
