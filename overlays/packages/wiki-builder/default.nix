# { python3, symlinkJoin, writeScriptBin }:
{ stdenv, python3, installShellFiles, makeWrapper }:
let
  name = "wiki-builder";
  pythonSphinx = python3.withPackages (pythonPackages:
    with pythonPackages; [
      typer
      rich
      sphinx
      sphinx_rtd_theme
      sphinxcontrib-blockdiag
      recommonmark
      sphinx-design
      sphinxcontrib-mermaid
    ]);

in stdenv.mkDerivation {
  inherit name;
  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ pythonSphinx makeWrapper ];
  unpackPhase = "true";
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${pythonSphinx}/bin/python $out/bin/${name}
  '';
  # postFixup = ''
  # wrapProgram $out/bin/${name} --prefix PATH : ${lib.makeBinPath [ p7zip ]}
  # '';
  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/${name} --help
  '';
}
