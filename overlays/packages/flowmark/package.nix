{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "flowmark";
  version = "0.5.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jlevy";
    repo = "flowmark";
    rev = "v${version}";
    hash = "sha256-V8Y0cyd1kX9OqGqxi+UU8W3NdcuHfjJghQHNc0qyipU=";
  };
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'source = "uv-dynamic-versioning"' "" \
      --replace-fail '[tool.hatch.version]' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  build-system = [
    python3.pkgs.hatchling
    python3.pkgs.poetry-core
    python3.pkgs.uv-dynamic-versioning
  ];

  dependencies = with python3.pkgs; [
    marko
    regex
    strif
    typing-extensions
  ];

  pythonImportsCheck = [
    "flowmark"
  ];

  meta = {
    description = "Better auto-formatting for Markdown";
    homepage = "https://github.com/jlevy/flowmark";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nialov ];
    mainProgram = "flowmark";
  };
}
