{
  stdenv,
  python3,
  # installShellFiles,
  wsl-open,
}:
stdenv.mkDerivation {
  name = "wsl-open-dynamic";
  # nativeBuildInputs = [ installShellFiles ];
  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [ typer ]))
    wsl-open
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${./wsl-open-dynamic.py} $out/bin/wsl-open-dynamic
    cp ${./wsl-open-dynamic.py} $out/bin/xdg-open
    chmod +x $out/bin/wsl-open-dynamic
    chmod +x $out/bin/xdg-open
  '';
  # postFixup = ''
  #   INSTALL_DIR=$(mktemp -d)
  #   $out/bin/wsl-open-dynamic --show-completion fish > $INSTALL_DIR/completion.fish
  #   $out/bin/wsl-open-dynamic --show-completion bash > $INSTALL_DIR/completion.bash
  #   installShellCompletion --name wsl-open-dynamic.bash --bash $INSTALL_DIR/completion.bash
  #   installShellCompletion --name wsl-open-dynamic.fish --fish $INSTALL_DIR/completion.fish
  # '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/wsl-open-dynamic --help
    $out/bin/xdg-open --help
  '';

}
