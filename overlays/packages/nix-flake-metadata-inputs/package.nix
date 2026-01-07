{
  stdenv,
  python3,
  installShellFiles,
  jq,
  lib,
  makeWrapper,
}:

stdenv.mkDerivation rec {
  description = "Utility for displaying and processing Nix flake input metadata";
  name = "nix-flake-metadata-inputs";
  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];
  buildInputs = [ python3 ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${././nix-flake-metadata-inputs.py} $out/bin/nix-flake-metadata-inputs
    chmod +x $out/bin/nix-flake-metadata-inputs
    wrapProgram $out/bin/nix-flake-metadata-inputs --prefix PATH : ${lib.makeBinPath [ jq ]}
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/nix-flake-metadata-inputs --help
  '';

}
