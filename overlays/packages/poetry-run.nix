{ writeShellApplication, poetry-with-c-tooling, pythons, lib }:
writeShellApplication {
  name = "poetry-run";
  runtimeInputs = [ poetry-with-c-tooling ] ++ pythons;
  # postCheck = ''
  #   $out/bin/poetry-run --help | ${ripgrep}/bin/rg "Usage"
  # '';
  text = let
    availablePythons = lib.concatStringsSep "\n"
      (builtins.map (python: builtins.toString python.interpreter) pythons);
  in ''
    if [[ "$1" == "--help" || $# -eq 0 ]]; then
        echo "Usage: poetry-run <python> <cmd>"
        echo "Arguments:"
        echo "  <python>  Choose the Python interpreter. Passed to poetry env use <python>."
        echo "  <cmd>     Pass the command to run. Passed to poetry run <cmd>."
        echo "Options:"
        echo "  --help    Show this help. Use without other arguments."
        echo "Available Pythons:"
        echo "${availablePythons}"
        exit 0
    fi
    poetry check
    poetry env use "$1"
    shift
    poetry env info
    poetry check --lock
    poetry install
    poetry run "$@"
  '';

}
