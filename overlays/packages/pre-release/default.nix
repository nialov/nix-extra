{ update-changelog, sync-git-tag-with-poetry, pandoc, writeShellApplication, gum
, resolve-version, git-cliff, ... }:
writeShellApplication {
  name = "pre-release";
  runtimeInputs = [
    update-changelog
    sync-git-tag-with-poetry
    pandoc
    gum
    resolve-version
    git-cliff
  ];
  text = builtins.readFile ./pre-release.sh;

}
