{
  update-changelog,
  sync-git-tag-with-poetry,
  pandoc,
  writeShellApplication,
  gum,
  resolve-version,
  git-cliff,
  ...
}:
writeShellApplication rec {
  description = "Tool for automating pre-release tasks such as changelog updates and Git tagging";
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
