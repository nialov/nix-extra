import argparse
import datetime
import json
import subprocess
from functools import partial

run_cmd = partial(
    subprocess.run,
    check=True,
    text=True,
    capture_output=True,
)


def main():
    """
    Show metadata of flake inputs.
    """
    metadata_output = run_cmd(
        ["nix", "flake", "metadata", "--json"],
    )

    input_target_output = run_cmd(
        ["jq", '.locks.nodes."{}".locked'.format(_parse_arguments())],
        input=metadata_output.stdout,
    )

    input_target_output_json = json.loads(input_target_output.stdout)

    output = run_cmd(
        [
            "nix",
            "flake",
            "metadata",
            "{type}:{owner}/{repo}/{rev}".format_map(input_target_output_json),
        ],
    )

    print(output.stdout)


def _check_input(input_target) -> str:
    if not isinstance(input_target, str):
        raise TypeError("Expected str input_target")
    if len(input_target) == 0:
        raise ValueError("Expected non-zero length input_target")
    return input_target


def _parse_arguments() -> str:
    parser = argparse.ArgumentParser(description=main.__doc__)
    parser.add_argument("input_target", help="flake input to inspect", nargs=None)
    args = parser.parse_args()
    input_target = args.input_target
    return _check_input(input_target)


if __name__ == "__main__":
    main()
