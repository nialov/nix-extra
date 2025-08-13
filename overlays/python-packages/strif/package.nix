{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  hatchling,
  uv-dynamic-versioning,
}:

buildPythonPackage rec {
  pname = "strif";
  version = "3.0.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jlevy";
    repo = "strif";
    rev = "v${version}";
    hash = "sha256-0hFQB/InXFmJRaEWmNICrR6gDsCcjIRx0a3DLKoCKQ0=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'source = "uv-dynamic-versioning"' "" \
      --replace-fail '[tool.hatch.version]' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    hatchling
    uv-dynamic-versioning
  ];

  pythonImportsCheck = [
    "strif"
  ];

  meta = {
    description = "A tiny, useful Python lib of string, file, and object utilities";
    homepage = "https://github.com/jlevy/strif";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nialov ];
  };
}
