{
  stdenv,
  python3,
  installShellFiles,
  # p7zip,
  # lib,
  makeWrapper,
  inputs,
}:
stdenv.mkDerivation rec {
  name = "filesender-client";
  version = "2.57";
  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];
  buildInputs = [
    (python3.withPackages (
      pythonPackages: with pythonPackages; [
        urllib3
        requests
      ]
    ))
  ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${inputs.filesender-src}/scripts/client/filesender.py $out/bin/${name}
    chmod +x $out/bin/${name}
  '';
  # postFixup = ''
  #   wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath [ p7zip ]}
  #   INSTALL_DIR=$(mktemp -d)
  #   $out/bin/${name} --show-completion fish > $INSTALL_DIR/completion.fish
  #   $out/bin/${name} --show-completion bash > $INSTALL_DIR/completion.bash
  #   installShellCompletion --name ${name}.bash --bash $INSTALL_DIR/completion.bash
  #   installShellCompletion --name ${name}.fish --fish $INSTALL_DIR/completion.fish
  # '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/${name} --help
  '';

}
