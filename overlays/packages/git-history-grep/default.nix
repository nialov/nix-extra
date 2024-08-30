{ stdenv, python3, installShellFiles, git, lib, makeWrapper }:

stdenv.mkDerivation {
  name = "git-history-grep";
  nativeBuildInputs = [ makeWrapper installShellFiles ];
  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [ typer rich ]))
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${././git_history_grep.py} $out/bin/git-history-grep
    wrapProgram $out/bin/git-history-grep --prefix PATH : ${
      lib.makeBinPath [ git ]
    }
    chmod +x $out/bin/git-history-grep
  '';
  postFixup = ''
    INSTALL_DIR=$(mktemp -d)
    $out/bin/git-history-grep --show-completion fish > $INSTALL_DIR/completion.fish
    $out/bin/git-history-grep --show-completion bash > $INSTALL_DIR/completion.bash
    installShellCompletion --name git-history-grep.bash --bash $INSTALL_DIR/completion.bash
    installShellCompletion --name git-history-grep.fish --fish $INSTALL_DIR/completion.fish
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/git-history-grep --help
  '';

}
