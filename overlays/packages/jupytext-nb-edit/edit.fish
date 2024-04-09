#!/usr/bin/env fish

set temp_dir (mktemp -d)
set notebook "$argv[1]"
set notebook_py_name "$(path basename $notebook | path change-extension py)"
set temp_output "$temp_dir/$notebook_py_name"
jupytext "$notebook" --output "$temp_output"

and set -a -x PYTHONPATH "$(pwd)"
and "$EDITOR" "$temp_output"
and jupytext "$temp_output" --output "$notebook" --show-changes --update
