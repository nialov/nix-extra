# { writers, python3Packages }:
# writers.writePython3Bin "pathnames" {
# libraries = with python3Packages; [ typer ];
# flakeIgnore = [ "E501" ];
# } (builtins.readFile ././pathnames.py)
{ stdenv, python3, installShellFiles, p7zip, lib, makeWrapper }:
stdenv.mkDerivation rec {
  name = "backupper";
  nativeBuildInputs = [ installShellFiles makeWrapper ];
  buildInputs = [
    (python3.withPackages (pythonPackages: with pythonPackages; [ typer rich ]))
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${./backupper.py} $out/bin/${name}
    chmod +x $out/bin/${name}
  '';
  postFixup = ''
    wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath [ p7zip ]}
    INSTALL_DIR=$(mktemp -d)
    $out/bin/${name} --show-completion fish > $INSTALL_DIR/completion.fish
    $out/bin/${name} --show-completion bash > $INSTALL_DIR/completion.bash
    installShellCompletion --name ${name}.bash --bash $INSTALL_DIR/completion.bash
    installShellCompletion --name ${name}.fish --fish $INSTALL_DIR/completion.fish
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/${name} --help
  '';

}
