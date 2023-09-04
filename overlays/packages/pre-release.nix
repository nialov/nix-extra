{ update-changelog, sync-git-tag-with-poetry, pandoc, writeShellApplication, ...
}:
writeShellApplication {
  name = "pre-release";
  runtimeInputs = [ update-changelog sync-git-tag-with-poetry pandoc ];
  text = ''
    sync-git-tag-with-poetry
    update-changelog --changelog CHANGELOG.md
    pandoc CHANGELOG.md --from markdown --to markdown --output CHANGELOG.md
  '';

}
