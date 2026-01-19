#!/usr/bin/env python3
"""
nixos-rebuild-latest-from-gitea (Python port: CLI, token extraction, fetch workflow runs step)
"""

import typer
import subprocess
import tempfile
import os
from typing import Optional

app = typer.Typer(
    add_completion=False,
    help="Automate fetching and deploying latest successful NixOS closure for a given host from Gitea CI job, in Python.",
)

SOPS_PATH = "secrets/nialov.yaml"
SOPS_KEY = '["gitea"]["nialov-admin-token"]'


@app.command()
def main(
    host: str = typer.Argument(..., help="Target NixOS host name"),
    branch: str = typer.Option(
        "testing", help="Git branch to use (default: 'testing')"
    ),
    server: str = typer.Option(
        "example.com", help="Gitea server FQDN (default: 'example.com')"
    ),
    repo: str = typer.Option(
        "nialov/example-repository",
        help="Gitea repository (default: 'nialov/example-repository')",
    ),
    select_action: Optional[str] = typer.Option(
        None,
        help="Optional: skip interactive prompt and use this action ('boot', 'switch', 'build', 'test')",
    ),
):
    """Fetch, print, and deploy latest NixOS closure for HOST."""

    # Step 1: Decrypt Gitea API token using sops.
    token = get_gitea_token()

    # Step 2: Fetch workflow runs via bkt + curl, write to temp file
    api_url = f"https://{server}/api/v1/repos/{repo}/actions/runs/"

    runs_json_file = tempfile.NamedTemporaryFile(
        delete=False, mode="w+b", prefix="gitea_runs_", suffix=".json"
    )
    runs_json_path = runs_json_file.name
    runs_json_file.close()  # Will write via subprocess, not Python.

    bkt_cmd = [
        "bkt",
        "--",
        "curl",
        "-s",
        "-H",
        f"Authorization: token {token}",
        api_url,
    ]
    try:
        with open(runs_json_path, "wb") as outfile:
            subprocess.run(bkt_cmd, check=True, stdout=outfile, stderr=subprocess.PIPE)
    except FileNotFoundError:
        typer.secho(
            "Error: 'bkt' or 'curl' not found in PATH. Both are required.",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        typer.secho(
            f"Error: bkt/curl failed to fetch Gitea workflow runs.\n{bkt_curl_error_message(e)}",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)

    typer.secho(
        f"[OK] Downloaded workflow runs JSON to {runs_json_path}", fg=typer.colors.GREEN
    )

    # Step 3: Parse workflow runs JSON for latest successful relevant workflow using jq via subprocess
    jq_branch = branch
    jq_filter = (
        ".workflow_runs | "
        'map(select(.path == "main.yaml@refs/heads/" + "'
        + jq_branch
        + '" and .conclusion == "success")) '
        "| max_by(.id) | .id"
    )
    try:
        jq_result = subprocess.run(
            ["jq", "-r", jq_filter, runs_json_path],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except FileNotFoundError:
        typer.secho(
            "Error: jq not found in PATH. Install jq to continue.",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        typer.secho(
            f"Error: jq failed to filter latest successful workflow run.\n{e.stderr}",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    latest_run_id = jq_result.stdout.strip()
    if not latest_run_id or latest_run_id == "null":
        typer.secho(
            "Error: No matching successful workflow run found for branch.",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    typer.secho(
        f"[OK] Latest successful run ID: {latest_run_id}", fg=typer.colors.GREEN
    )

    # Step 4: Fetch jobs for this run via bkt + curl
    jobs_api_url = (
        f"https://{server}/api/v1/repos/{repo}/actions/runs/{latest_run_id}/jobs/"
    )
    jobs_json_file = tempfile.NamedTemporaryFile(
        delete=False, mode="w+b", prefix="gitea_jobs_", suffix=".json"
    )
    jobs_json_path = jobs_json_file.name
    jobs_json_file.close()
    jobs_bkt_cmd = [
        "bkt",
        "--",
        "curl",
        "-s",
        "-H",
        f"Authorization: token {token}",
        jobs_api_url,
    ]
    try:
        with open(jobs_json_path, "wb") as outfile:
            subprocess.run(
                jobs_bkt_cmd, check=True, stdout=outfile, stderr=subprocess.PIPE
            )
    except FileNotFoundError:
        typer.secho(
            "Error: 'bkt' or 'curl' not found for jobs fetch.",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        typer.secho(
            f"Error: bkt/curl failed fetching jobs for run {latest_run_id}:\n{bkt_curl_error_message(e)}",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    typer.secho(
        f"[OK] Downloaded workflow jobs JSON to {jobs_json_path}", fg=typer.colors.GREEN
    )

    # Step 5: Use jq to extract the job ID for this host
    jq_host = host
    jq_job_id_filter = (
        '.jobs | map(select(.name == "build-nixos-'
        + jq_host
        + '")) | max_by(.id) | .id'
    )
    try:
        jq_job_result = subprocess.run(
            ["jq", "-r", jq_job_id_filter, jobs_json_path],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except FileNotFoundError:
        typer.secho(
            "Error: jq not found in PATH for job ID extraction.",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        typer.secho(
            f"Error: jq failed to extract job ID for host {host}:\n{e.stderr}",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    latest_job_id = jq_job_result.stdout.strip()
    if not latest_job_id or latest_job_id == "null":
        typer.secho(
            f"Error: No successful build job found for host {host} (in run {latest_run_id}).",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    typer.secho(
        f"[OK] Latest job ID for host {host}: {latest_job_id}", fg=typer.colors.GREEN
    )

    # Step 6.1: Fetch job logs for latest job ID using bkt+curl
    logs_api_url = (
        f"https://{server}/api/v1/repos/{repo}/actions/jobs/{latest_job_id}/logs"
    )
    job_logs_file = tempfile.NamedTemporaryFile(
        delete=False, mode="w+b", prefix="gitea_joblogs_", suffix=".log"
    )
    job_logs_path = job_logs_file.name
    job_logs_file.close()
    logs_bkt_cmd = [
        "bkt",
        "--",
        "curl",
        "-s",
        "-H",
        f"Authorization: token {token}",
        logs_api_url,
    ]
    try:
        with open(job_logs_path, "wb") as outfile:
            subprocess.run(
                logs_bkt_cmd, check=True, stdout=outfile, stderr=subprocess.PIPE
            )
    except FileNotFoundError:
        typer.secho(
            "Error: 'bkt' or 'curl' not found for logs fetch.",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        typer.secho(
            f"Error: bkt/curl failed to fetch job logs for job {latest_job_id}:\n{bkt_curl_error_message(e)}",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    typer.secho(
        f"[OK] Downloaded job logs for job {latest_job_id} to {job_logs_path}",
        fg=typer.colors.GREEN,
    )
    # Step 6.2: Use rg subprocess to search log for 'nixos-system' lines
    try:
        rg_result = subprocess.run(
            ["rg", "nixos-system", job_logs_path],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except FileNotFoundError:
        typer.secho(
            "Error: rg not found in PATH. Install ripgrep to continue.",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        # If no match found, rg returns 1 and writes nothing to stdout
        if e.returncode == 1:
            typer.secho(
                "Error: No nixos-system lines found in job log (no closure built).",
                fg=typer.colors.RED,
                err=True,
            )
            raise typer.Exit(code=1)
        else:
            typer.secho(
                f"Error: rg failed unexpectedly (code {e.returncode}):\n{e.stderr}",
                fg=typer.colors.RED,
                err=True,
            )
            raise typer.Exit(code=1)
    matches = rg_result.stdout.strip()
    if not matches:
        typer.secho(
            "No nixos-system lines found in job log.", fg=typer.colors.RED, err=True
        )
        raise typer.Exit(code=1)
    typer.secho(
        f"[OK] Found nixos-system lines in logs:\n{matches}", fg=typer.colors.GREEN
    )
    # Step 6.3: Pipe rg output to tail -n 1 to get last matching line
    try:
        tail_result = subprocess.run(
            ["tail", "-n", "1"],
            input=matches,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except FileNotFoundError:
        typer.secho("Error: tail not found in PATH.", fg=typer.colors.RED, err=True)
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        typer.secho(
            f"Error: tail -n 1 failed:\n{e.stderr}", fg=typer.colors.RED, err=True
        )
        raise typer.Exit(code=1)
    last_match = tail_result.stdout.strip()
    if not last_match:
        typer.secho(
            "No last closure candidate line (tail gave empty result)",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    typer.secho(
        f"[OK] Last candidate closure line: {last_match}", fg=typer.colors.GREEN
    )
    # Step 6.4: Pipe last_match to awk to extract closure path (print $NF)
    try:
        awk_result = subprocess.run(
            ["awk", "{print $NF}"],
            input=last_match,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except FileNotFoundError:
        typer.secho("Error: awk not found in PATH.", fg=typer.colors.RED, err=True)
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        typer.secho(
            f"Error: awk failed to extract closure from line:\n{e.stderr}",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    closure_path = awk_result.stdout.strip()
    if not closure_path:
        typer.secho(
            "Could not extract closure path with awk.", fg=typer.colors.RED, err=True
        )
        raise typer.Exit(code=1)
    typer.secho(f"[OK] Extracted closure path: {closure_path}", fg=typer.colors.GREEN)
    # Step 6.5: Validate closure path format and existence
    if not closure_path.startswith("/nix/store/"):
        typer.secho(
            f"Error: Extracted path does not begin with /nix/store/: {closure_path}",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    if not os.path.exists(closure_path):
        typer.secho(
            f"Error: Closure path does not exist locally (expected for remote CI): {closure_path}",
            fg=typer.colors.YELLOW,
        )
        # This warning is expected for remote artifacts, so do not exit. Just warn.
    else:
        typer.secho(
            f"[OK] Closure path exists and is plausible: {closure_path}",
            fg=typer.colors.GREEN,
        )
    # Step 6.6: Output closure path to user, ready for deployment phase
    typer.secho(
        f"\nClosure path for deployment: {closure_path}\n",
        fg=typer.colors.CYAN,
        bold=True,
    )

    # Step 7: Copy closure with nix copy if needed
    if not os.path.exists(closure_path):
        nix_copy_cmd = [
            "nix",
            "copy",
            "--no-check-sigs",
            "--from",
            f"ssh-ng://{server}",
            closure_path,
        ]
        typer.secho(f"Running: {' '.join(nix_copy_cmd)}", fg=typer.colors.BLUE)
        try:
            subprocess.run(nix_copy_cmd, check=True)
        except FileNotFoundError:
            typer.secho(
                "Error: nix or ssh missing in PATH.", fg=typer.colors.RED, err=True
            )
            raise typer.Exit(code=1)
        except subprocess.CalledProcessError as e:
            typer.secho(f"Error: nix copy failed: {e}", fg=typer.colors.RED, err=True)
            raise typer.Exit(code=1)
        typer.secho("[OK] Copied closure using nix copy", fg=typer.colors.GREEN)
    else:
        typer.secho(
            "[SKIP] Closure already local; skipping nix copy", fg=typer.colors.YELLOW
        )

    # Step 8: Select action for deployment
    action = select_action
    allowed_actions = ["boot", "switch", "build", "test"]
    if not action or action not in allowed_actions:
        typer.secho(
            f"Select deployment action for host {host}:",
            fg=typer.colors.BLUE,
            bold=True,
        )
        for idx, a in enumerate(allowed_actions, 1):
            typer.echo(f"{idx}. {a}")
        sel = typer.prompt("Enter number for action", default="1")
        try:
            idx = int(sel)
            if not (1 <= idx <= len(allowed_actions)):
                raise ValueError()
            action = allowed_actions[idx - 1]
        except Exception:
            typer.secho(
                "Invalid selection, defaulting to 'boot'", fg=typer.colors.YELLOW
            )
            action = "boot"
    typer.secho(
        f"[ACTION] nh os {action} {closure_path}", fg=typer.colors.BLUE, bold=True
    )

    # Step 9: Deploy using nh os
    nh_cmd = ["nh", "os", action, closure_path]
    try:
        subprocess.run(nh_cmd, check=True)
        typer.secho(
            f"[OK] Deployment completed via nh os {action}", fg=typer.colors.GREEN
        )
    except FileNotFoundError:
        typer.secho("Error: nh not found in PATH.", fg=typer.colors.RED, err=True)
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        typer.secho(f"Error: nh os {action} failed: {e}", fg=typer.colors.RED, err=True)
        raise typer.Exit(code=1)

    typer.secho("✔ All done.", fg=typer.colors.CYAN, bold=True)
    raise typer.Exit(code=0)


def get_gitea_token() -> str:
    try:
        result = subprocess.run(
            ["sops", "-d", "--extract", SOPS_KEY, SOPS_PATH],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    except FileNotFoundError:
        typer.secho(
            "Error: sops not found in PATH. Install sops to continue.",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    except subprocess.CalledProcessError as e:
        typer.secho(
            f"Error: sops failed to decrypt the Gitea token.\n{sops_error_message(e)}",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    token = result.stdout.strip()
    if not token:
        typer.secho(
            "Error: No Gitea token extracted from sops output.",
            fg=typer.colors.RED,
            err=True,
        )
        raise typer.Exit(code=1)
    typer.secho(
        f"[OK] Gitea token extracted (begins with: {token[:4]}...)",
        fg=typer.colors.GREEN,
    )
    return token


def sops_error_message(e: subprocess.CalledProcessError) -> str:
    return e.stderr.strip() if e.stderr else str(e)


def bkt_curl_error_message(e: subprocess.CalledProcessError) -> str:
    return e.stderr.decode(errors="replace") if hasattr(e.stderr, "decode") else str(e)


def run_checked(
    cmd,
    *,
    error_msg=None,
    tool_desc=None,
    input=None,
    out_file=None,
    capture_stdout=True,
    text=True,
    exit_code=1,
):
    """
    Unified subprocess runner for CLI tools.
      - cmd: command list
      - error_msg: user context error msg
      - tool_desc: tool string for user
      - input: optional input data (for stdin, as string)
      - out_file: if provided, send stdout to this open file
      - capture_stdout: if True, return stdout
      - text: treat text (vs binary)
      - exit_code: Typer exit code (for error exits only)

    Usage:
      Replace any subprocess.run/try/except call for external CLI tools (bkt, jq, rg, tail, awk, sops, nix, nh...)
      with run_checked(...), passing error context and tool name.
      This ensures all tool errors are consistently actionable and user friendly.
    """
    kwargs = {"check": True, "stderr": subprocess.PIPE}
    # Only add kwargs that subprocess.run supports.
    if input is not None:
        kwargs["input"] = input
        kwargs["text"] = text
    if out_file is not None:
        kwargs["stdout"] = out_file
        # Don't set 'text' if writing to file
    elif capture_stdout:
        kwargs["stdout"] = subprocess.PIPE
        kwargs["text"] = text
    try:
        res = subprocess.run(cmd, **kwargs)
        return (
            res.stdout.strip()
            if capture_stdout and hasattr(res, "stdout") and res.stdout
            else None
        )
    except FileNotFoundError:
        msg = f"Error: {tool_desc or cmd[0]} not found in PATH."
        if error_msg:
            msg += f" {error_msg}"
        typer.secho(msg, fg=typer.colors.RED, err=True)
        raise typer.Exit(code=exit_code)
    except subprocess.CalledProcessError as e:
        err = None
        if hasattr(e, "stderr") and e.stderr:
            err = (
                e.stderr.decode(errors="replace")
                if isinstance(e.stderr, bytes)
                else str(e.stderr)
            )
        msg = f"Error running {' '.join(cmd)}\n"
        if error_msg:
            msg += f"{error_msg}\n"
        if err:
            msg += err.strip()
        typer.secho(msg, fg=typer.colors.RED, err=True)
        raise typer.Exit(code=exit_code)


# Contributors: All tool subprocesses throughout this script should use run_checked().
# For new CLI/automation steps, prefer run_checked (with error_msg/tool_desc args)
# over raw subprocess.run for greater maintainability and consistent user errors.

if __name__ == "__main__":
    app()
