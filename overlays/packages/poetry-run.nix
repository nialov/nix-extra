{ writeShellApplication, poetry-with-c-tooling, pythons }:
writeShellApplication {
  name = "poetry-run";
  runtimeInputs = [ poetry-with-c-tooling ] ++ pythons;
  text = ''
    poetry check
    poetry env use "$1"
    shift
    poetry env info
    poetry lock --check
    poetry install
    poetry run "$@"
  '';

}
