{ writeShellApplication, git }:
writeShellApplication {
  name = "resolve-version";
  runtimeInputs = [ git ];
  text = ''
    version="$(git tag --sort=-creatordate | head -n 1 | sed 's/v\(.*\)/\1/')"
    echo "$version"
  '';
}
