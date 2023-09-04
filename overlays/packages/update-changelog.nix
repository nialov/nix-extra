{ writeShellApplication, clog-cli, ripgrep, pandoc }:
writeShellApplication {
  name = "update-changelog";
  runtimeInputs = [ clog-cli ripgrep pandoc ];
  text = ''
    homepage="$(rg 'homepage =' pyproject.toml | sed 's/.*"\(.*\)"/\1/')"
    version="$(git tag --sort=-creatordate | head -n 1 | sed 's/v\(.*\)/\1/')"
    clog --repository "$homepage" --subtitle "Release Changelog $version" "$@"
  '';
}
