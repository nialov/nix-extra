# { writers, python3Packages }:
# writers.writePython3Bin "pathnames" {
# libraries = with python3Packages; [ typer ];
# flakeIgnore = [ "E501" ];
# } (builtins.readFile ././pathnames.py)
{ stdenv, python3, installShellFiles, taskwarrior2, pandoc, lib, makeWrapper }:

stdenv.mkDerivation {
  name = "pretty-task";
  nativeBuildInputs = [ makeWrapper installShellFiles ];
  buildInputs = [
    (python3.withPackages (pythonPackages:
      with pythonPackages; [
        typer
        json5
        rich
        tabulate
        ipython
      ]))
    # taskwarrior
    # pandoc
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${././pretty_task.py} $out/bin/pretty-task
    wrapProgram $out/bin/pretty-task --prefix PATH : ${
      lib.makeBinPath [ taskwarrior2 pandoc ]
    }
    chmod +x $out/bin/pretty-task
  '';
  postFixup = ''
    INSTALL_DIR=$(mktemp -d)
    $out/bin/pretty-task --show-completion fish > $INSTALL_DIR/completion.fish
    $out/bin/pretty-task --show-completion bash > $INSTALL_DIR/completion.bash
    installShellCompletion --name pretty-task.bash --bash $INSTALL_DIR/completion.bash
    installShellCompletion --name pretty-task.fish --fish $INSTALL_DIR/completion.fish
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/pretty-task --help
  '';

}
