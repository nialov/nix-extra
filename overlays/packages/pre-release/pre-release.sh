#!/usr/bin/env bash

new_version_arg="${1:-v}"
new_version="$(gum input --prompt "New version with v prefix:" --placeholder "$new_version_arg")"

# Checks
gum log "Checking for dirty worktree"
git diff --exit-code
version="$(git tag --sort=-creatordate | head -n 1 | sed 's/v\(.*\)/\1/')"
gum confirm "Current tag without v prefix is: $version and new version is $new_version. Continue?"
previous_tag="$(git tag --sort=-creatordate | sed 's/v\(.*\)/\1/' | sed -n '2p')"
gum log "Occurrences of previous tag in project py, md and rst suffix files:"
rg --fixed-strings "$previous_tag" --glob '*.py' --glob '*.md' --glob '*.rst' --glob "*.toml"

# Automation

gum log "Generating a CHANGELOG.md for use in updating CHANGELOG.md in repository"
tmp_changelog="$(mktemp -d)/CHANGELOG.md"
git-cliff --tag "$new_version" -o "$tmp_changelog"
echo "$tmp_changelog"
