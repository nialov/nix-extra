import argparse
import subprocess

import psutil


def _parse_arguments() -> dict:
    parser = argparse.ArgumentParser(description=main.__doc__)
    parser.add_argument(
        "minimum_frequency",
        help="Minimum frequency to run fix script",
        nargs=None,
        type=float,
    )
    args = parser.parse_args().__dict__
    return args


def main(minimum_frequency: float):
    """Check and fix CPU frequency."""
    current_freq = psutil.cpu_freq().current
    print(f"Current frequency: {current_freq}")
    if current_freq < minimum_frequency:
        print(f"Frequency under set minimum ({minimum_frequency})")
        subprocess.check_call(["fix-power"])


if __name__ == "__main__":
    args = _parse_arguments()
    main(**args)
