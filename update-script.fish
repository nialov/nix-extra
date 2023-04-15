#!/usr/bin/env fish

pushd ~/projects/nix-extra

and git pull
and set current_date (date +%Y-%m-%d-%H-%M)
and set branch_name "build-update-flake-$current_date"
and git branch $branch_name
and git checkout $branch_name
and nix flake update
and pre-commit run --all-files
and nix -Lv flake check
and git add .

popd
