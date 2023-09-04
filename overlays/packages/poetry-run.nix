{ writeShellApplication, poetry-with-c-tooling, python39, python310, python311
}:
writeShellApplication {
  name = "poetry-run";
  runtimeInputs = [ poetry-with-c-tooling python39 python310 python311 ];
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
