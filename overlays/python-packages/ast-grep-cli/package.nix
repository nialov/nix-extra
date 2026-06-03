{
  lib,
  buildPythonPackage,
  python,
  ast-grep,
}:
buildPythonPackage rec {
  pname = "ast-grep-cli";
  inherit (ast-grep) version;
  format = "other";
  dontUnpack = true;
  dontBuild = true;
  propagatedBuildInputs = [ ast-grep ];
  pythonRuntimeDepsCheckHook = "";

  installPhase = ''
    dist="$out/${python.sitePackages}/${pname}-${version}.dist-info"
    mkdir -p "$dist"
    printf 'Metadata-Version: 2.1\nName: ast-grep-cli\nVersion: ${version}\n' > "$dist/METADATA"
    touch "$dist/RECORD"
  '';

  meta = with lib; {
    description = "Shim package exposing ast-grep CLI to Python dependency resolution";
    license = licenses.mit;
  };
}
