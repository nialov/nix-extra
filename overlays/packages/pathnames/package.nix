# { writers, python3Packages }:
# writers.writePython3Bin "pathnames" {
# libraries = with python3Packages; [ typer ];
# flakeIgnore = [ "E501" ];
# } (builtins.readFile ././pathnames.py)
{
  stdenv,
  python3,
  installShellFiles,
}:
stdenv.mkDerivation {
  name = "pathnames";
  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ (python3.withPackages (pythonPackages: with pythonPackages; [ typer ])) ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${./pathnames.py} $out/bin/pathnames
    chmod +x $out/bin/pathnames
  '';
  postFixup = ''
    INSTALL_DIR=$(mktemp -d)
    $out/bin/pathnames --show-completion fish > $INSTALL_DIR/completion.fish
    $out/bin/pathnames --show-completion bash > $INSTALL_DIR/completion.bash
    installShellCompletion --name pathnames.bash --bash $INSTALL_DIR/completion.bash
    installShellCompletion --name pathnames.fish --fish $INSTALL_DIR/completion.fish
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/pathnames --help

    STEM=$($out/bin/pathnames stem /path/to/file.txt)
    [ "$STEM" == "file" ]
  '';

}
