# (This file will track migration progress for the new Python version of nixos-rebuild-latest-from-gitea.)

# [Migrate nixos-rebuild-latest-from-gitea bash script to Python]
# Epic: Replace the bash implementation with a Python script and adapt this package.nix logic to invoke it.
# All significant discoveries, mapping tables, and progress from beads tasks will be documented as comments in this file.

# --- MIGRATION IN PROGRESS ---

# Beads Task: Analyze bash script_to_transform.txt
# Result:
#   nixos-rebuild-latest-from-gitea: Bash Script Analysis (beads persistent record)
# -------------------------------------------------------------
# Overview:
#   Automates obtaining and deploying the latest successful NixOS closure
#   for a given host, built in CI on Gitea, and deploying it locally.
#
# Inputs & CLI:
#   - HOST (first positional argument): required, the NixOS host name.
#   - (Implicit) Uses fixed branch "testing", fixed Gitea server, and repository name.
#
# Steps / Workflow:
#   1. Decrypts Gitea API token from sops-encrypted YAML at 'secrets/nialov.yaml'.
#   2. Sets some static variables: BRANCH, SERVER, BKT_TTL (10m/expiration for bkt)
#   3. For host $HOST:
#      a. Queries Gitea API for runs on the main.yaml workflow @ branch $BRANCH with success.
#      b. From these, selects latest (max .id), extracts its run id.
#      c. Fetches all jobs from that workflow run; selects the one matching build-nixos-$HOST, latest id.
#      d. Obtains logs for the job; parses the last nixos-system path mentioned (tail/rg/awk pipeline).
#      e. Copies the resulting Nix closure from the SERVER to the local machine (nix copy).
#      f. Prompts user (gum choose): boot/switch/build/test (default: boot). Uses nh os to activate new config.
#
# Dependencies:
#   - sops (YAML secret decryption)
#   - curl (HTTP requests, run inside bkt for caching/proxy)
#   - jq (JSON parsing from API calls)
#   - bkt (executes/caches HTTP requests)
#   - gum (fuzzy/terminal choice prompt)
#   - rg (ripgrep), tail, awk (log parsing for Nix closure path)
#   - nh os (NixOS host deploy commands)
#   - nix (for nix copy)
#
# API Endpoints:
#   (1) GET runs:   /api/v1/repos/nialov/example-repository/actions/runs/
#   (2) GET jobs:   /api/v1/repos/nialov/example-repository/actions/runs/<run_id>/jobs/
#   (3) GET logs:   /api/v1/repos/nialov/example-repository/actions/jobs/<job_id>/logs
#   -> All require API token in header.
#
# Temporary files: used for responses and IDs (cleaned up by mktemp lifecycle).
#
# Outputs:
#   - Echoes progress to user (what, which artifacts).
#   - Writes, then reads IDs and JSONs from temp files.
#   - Eventually prints/copies a NixOS closure and runs host activation.
#   - Prompts user interactively for activation mode.
#
# Hidden assumptions:
#   - Fixed Gitea server/repo/branch/closure naming conventions.
#   - sops secret is available at a precise path.
#   - User has permissions and SSH for nix copy from SERVER.
#   - nh os and all CLI tools are on PATH.
#   - Host is always a positional argument, not a named flag.
#
# Pain points for porting:
#   - Complex jq JSON queries -> Python dict processing
#   - ripgrep/awk/tail log parsing -> Python regex
#   - gum (terminal multi-choice) -> Python TUI or fallback prompt
#   - Streaming/caching/curl via bkt: may need substitute or make optional
#   - YAML sops extraction (Python: use sops or python-sops/yq if available)
# -------------------------------------------------------------

# Beads Task: Define Python CLI and behavior
# Result:
#   CLI specification for nixos-rebuild-latest-from-gitea (Python):
#   ----------------------------------------------------------------
#   - The CLI MUST be implemented using the Typer library (https://typer.tiangolo.com/) for Python argument/option parsing and automatic --help documentation.
#   - Typer's use is limited to CLI syntax, validation, type-safety, and help output; all workflow and data-manipulation logic will invoke the original tools via subprocess as per migration policy.
#   - Typer is chosen for its type-annotation, auto-doc, and ease-of-use above argparse or Click.
#   Usage:
#     nixos-rebuild-latest-from-gitea.py HOST [--branch BRANCH] [--server SERVER] [--repo REPO] [--select-action ACTION]
#   Required:
#     - HOST: name of the target NixOS host (string, positional).
#   Optional (defaults match bash script; expose for testability):
#     --branch:  branch to use (default: 'testing')
#     --server:  Gitea server (default: 'example.com')
#     --repo:    Gitea repository (default: 'nialov/example-repository')
#     --select-action: if set, skip interactive action selector; value: boot/switch/build/test.
#   Behavior:
#     - Should match the bash workflow (see Beads Analysis above).
#       Take CLI input, orchestrate subprocess commands for secrets, API calls, jq queries,
#       log parsing, prompts.
#     - For full compatibility, script should:
#         - Print informative status and result output (like bash script's 'echo's).
#         - Respect all bash script environment usages: SOPS, bkt, etc.
#         - If --select-action is not given, prompt as bash script (gum, or simple input())
#     - For first draft: all curl/jq/etc. should be external subprocess calls per Beads mapping (do not port natively).
#   Notes:
#     - CLI should be implemented using argparse or similar.
#     - Output and error handling should be similar to Bash version, with clear failure modes and helpful messages.
#     - All POSIX environment and temp file assumptions must be respected in the Python CLI for full drop-in testing.
#   ----------------------------------------------------------------

# Beads Task: Map bash logic to Python
# Result:
#   **For the first draft, replicate as much original Bash shell-tooling as possible by using Python's subprocess library.**
#   E.g., for jq queries, log parsing, curl, bkt, gum, etc., prefer calling the original CLI tools via subprocess.run (or equivalent).
#   Do not attempt to reimplement these workflows or data filtering with native Python modules, such as json or yaml parsing. This ensures the first draft preserves all quirks, edge cases, and side effects implicit in the existing Bash logic.
#   Only after the subprocess draft is fully working and battle-tested may we consider gradual internalization/migration away from subprocess to direct Python libraries, if desired.
#
#   ---- Mapping Table: Bash → Python subprocess.run ----
#   Bash Step                                       | Python subprocess Equivalent
#   ---------------------------------------------------------------------------------------
#   sops -d --extract ... secrets/nialov.yaml        | subprocess.run(["sops", "-d", "--extract", ...], capture_output=True)
#   HOST="$1"                                      | HOST = sys.argv[1] or argparse positional arg
#   curl -s -H "Authorization: token $TOKEN" ...    | subprocess.run(["curl", "-s", "-H", f"Authorization: token {TOKEN}", ...], ...)
#   > "$GITEA_RUNS_JSON" (writes to temp file)     | open(tempfile, "w").write(result.stdout)
#   jq ...                                          | subprocess.run(["jq", ...], input=json_bytes, ...)
#   mktemp                                          | tempfile.NamedTemporaryFile() or mkstemp()
#   bkt -- <any>                                    | subprocess.run(["bkt", "--", ...], ...)
#   rg nixos-system | tail -n 1 | awk '{print $2}'  | compose subprocesses via PIPE to implement rg | tail | awk
#   gum choose boot switch build test                | subprocess.run(["gum", "choose", ...]) or fallback to input()/print
#   nix copy ...                                    | subprocess.run(["nix", "copy", ...], ...)
#   nh os "$action" "$latest_built"               | subprocess.run(["nh", "os", action, latest_built], ...)
#   echo ...                                        | print("...")
#   temp files/cleanup                              | tempfile.NamedTemporaryFile(delete=True), files auto-managed
#   ENV variables (export BKT_TTL, etc.)            | env=... in subprocess.run(), os.environ in Python
#
#   Notes:
#   - For jq or curl input/output chaining, use input= and stdout=PIPE, parse output via communicate().
#   - Use files as intermediates ONLY if needed to replicate bash precisely; otherwise use pipes where reliable.
#   - Compose process pipelines using subprocess.Popen(..., stdout=PIPE) / run shell=True if necessary.
#   - Error handling: use subprocess.CalledProcessError, check_returncode(), report to user as appropriate.
#   - For user interactivity (gum), if not available, prompt via Python input() fallback.
#
#   This mapping is strict for the initial version as per migration policy—no internal re-implementation until subprocess logic is working end-to-end.
#   -------------------------------------------------------------

# Beads Task: Draft package.nix modifications for Python
# Result:
#   package.nix adaptation strategy for Python wrapper:
#   ----------------------------------------------------------------
#   - Instead of Bash script (writeShellApplication), use writeScriptBin or python3.withPackages to package python source as an executable.
#   - Place the new Python script into nixos-rebuild-latest-from-gitea.py as a sibling file.
#   - runtimeInputs: supply all required CLI tools (jq, curl, sops, bkt, gum, rg, nh, awk, tail, etc.) because subprocess logic expects them.
#     * python3 itself must also be present.
#   - Reference Python entry via a build phase, symlink, or directly as bin output using writeScriptBin.
#   - CLI and behavior conform to prior bead's spec.
#   - The packaged tool's invocation and CLI signature must not change for drop-in testing compatibility (HOST positional, options match, exit codes reasonable).
#   ----------------------------------------------------------------
#   Outline for package.nix:
#     1. Add a src field or let-script = ./nixos-rebuild-latest-from-gitea.py;
#     2. Use writeScriptBin/writeTextFile, or python3.withPackages (pinned env if needed)
#     3. List all CLI tool deps explicitly in runtimeInputs
#     4. Provide executable wrapper named 'nixos-rebuild-latest-from-gitea'
#   ----------------------------------------------------------------

# Beads Task: Plan migration testing and validation
# Result:
#   Migration validation/testing plan:
#   ----------------------------------------------------------------
#   - Minimal validation is to verify the Python script, when packaged, produces identical effects and outputs as the Bash version for representative real/CI data:
#       * End-to-end: Successfully fetches/run IDs, job IDs, logs, selects/prints/copies a closure, and prompts for/executes 'nh os ...' per user choice.
#       * Compare outputs with Bash version for same HOST and CI state. All subprocess shelling must yield correct data/files.
#   - Tool dependency: All CLI tools required by subprocess must be present (checked via 'which' or subprocess.run(..., check=True)).
#   - Script should fail early/clearly if required tools/env variables/secrets are missing, mimicking Bash's behavior.
#   - Add racket smoke test: Run with --select-action boot and a fixed HOST against a test Gitea/CI instance (or mock responses) to check Python output, prompt, API call success, file I/O correctness, and subprocess flows.
#   - Make sure all tempfiles and process exits are cleaned up (match mktemp idioms/bkt caching).
#   - Optionally add a test Nix build phase/derivation that invokes the Python script against test fixtures; print diagnostics if anything fails.
#   - User acceptance: if the Python version works in-place of Bash for normal workflows, migration is provisionally successful.
#   - Once Python subprocess draft is validated by these checks, then move on to gradual internal porting as desired.
#   ----------------------------------------------------------------

{
  stdenv,
  python3,
  makeWrapper,
  jq,
  curl,
  sops,
  gum,
  bkt,
  ripgrep,
  nh,
  gawk,
  coreutils,
  lib,
}:

# Fully migrates to using the Python script as the CLI, wrapping all dependent tools for subprocess execution.
stdenv.mkDerivation rec {
  pname = "nixos-rebuild-latest-from-gitea";
  version = "1.0.0-python-migration";
  src = ./nixos-rebuild-latest-from-gitea.py;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [
    (python3.withPackages (ps: with ps; [ typer ]))
    jq
    curl
    sops
    gum
    bkt
    ripgrep
    nh
    gawk
    coreutils
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/nixos-rebuild-latest-from-gitea
    chmod +x $out/bin/nixos-rebuild-latest-from-gitea
    wrapProgram $out/bin/nixos-rebuild-latest-from-gitea \
      --prefix PATH : "${
        lib.makeBinPath [
          jq
          curl
          sops
          gum
          bkt
          ripgrep
          nh
          gawk
          coreutils
        ]
      }"
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/nixos-rebuild-latest-from-gitea --help
  '';
  meta = {
    description = "Fetch & deploy latest NixOS closure from Gitea CI (Python, subprocess)";
    homepage = "https://github.com/nialov/nix-extra";
    license = lib.licenses.mit;
    maintainers = [ "nialov" ];
  };
}

# --- End new Python packaging logic ---
