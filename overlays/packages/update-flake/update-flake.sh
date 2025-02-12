#!/usr/bin/env bash

update_branch=${1:-update_flake_lock}
repo_name="$(basename "$(pwd)")"
update_worktree="$(dirname "$(pwd)")/$repo_name.$update_branch"

gum log "$update_worktree"

if [[ -d "$update_worktree" ]]; then
    gum log "Found existing worktree at $update_worktree"
else
    gum confirm "Create new worktree at $update_worktree for branch $update_branch?" && git worktree add "$update_worktree" "$update_branch" || exit 1
fi

pushd "$update_worktree" || exit 1

git fetch

if ! git diff origin/master --quiet; then

    gum log "Branch $update_branch differs from origin/master"
    gum confirm "Hard reset to master?" && git reset --hard origin/master || exit 1

fi

gum confirm "Update flake and commit?" && nix flake update && nix develop -c git commit -am "build(flake): update" || exit 1

if ! git push; then
    gum confirm "Force push with lease to remote?" && git push --force-with-lease || exit 1
fi

if ! gh repo show; then
    if tea pr; then
        gum confirm "Create gitea pull request?" && tea pr create --title "Update flake.lock" || exit 1
    fi
else
    gum confirm "Create github pull request?" && gh pr create --fill --title "Refactor pre-commit hooks" || exit 1
fi
