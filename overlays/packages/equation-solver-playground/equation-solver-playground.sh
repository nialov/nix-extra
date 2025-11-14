# shellcheck shell=bash

WORK_DIR="$HOME/.local/share/equation-solver-playground/"
if [ -n "${1-}" ]; then
	echo "Using provided session name: ${1-}"
	SESSION_NAME="${1-}"
else
	SESSION_NAME="session-$(date +%Y%m%d-%H%M%S)"
	echo "No session name provided. Generated session name: $SESSION_NAME"
fi
SESSION_DIR="$WORK_DIR/$SESSION_NAME"
NOTEBOOK="equation_playground.py"
mkdir -p "$SESSION_DIR"

echo "Launching marimo in session: $SESSION_NAME"
pushd "$SESSION_DIR" || exit
# Only copy the template if the notebook does not already exist
if [ ! -f "$NOTEBOOK" ]; then
	if [ -z "${TEMPLATE_PATH-}" ]; then
		echo "Error: TEMPLATE_PATH environment variable is not set." >&2
		exit 1
	fi
	if [ ! -f "$TEMPLATE_PATH" ]; then
		echo "Error: Template file not found at \$TEMPLATE_PATH: $TEMPLATE_PATH" >&2
		exit 1
	fi
	echo "No existing notebook found. Copying template from $TEMPLATE_PATH."
	cp "$TEMPLATE_PATH" "$NOTEBOOK"
	chmod u+rw "$NOTEBOOK"
fi
marimo edit "$NOTEBOOK"
popd || exit
