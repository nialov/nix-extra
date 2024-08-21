{ stdenv, python3, installShellFiles, jq, lib, makeWrapper }:

stdenv.mkDerivation {
  name = "nix-flake-metadata-inputs";
  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ python3 makeWrapper ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    cp ${././nix-flake-metadata-inputs.py} $out/bin/nix-flake-metadata-inputs
    chmod +x $out/bin/nix-flake-metadata-inputs
    wrapProgram $out/bin/nix-flake-metadata-inputs --prefix PATH : ${
      lib.makeBinPath [ jq ]
    }
  '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/nix-flake-metadata-inputs --help
  '';

}
