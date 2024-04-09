{ writeShellApplication, poetry, git, resolve-version }:
writeShellApplication {
  name = "sync-git-tag-with-poetry";
  runtimeInputs = [ poetry git resolve-version ];
  text = ''
    version="$(resolve-version)"
    poetry version "$version"
  '';
}
