{
  lib,
  python3,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "sembr";
  version = "unstable-2025-08-03";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "admk";
    repo = "sembr";
    rev = "8cd0e83615b6b94fd09aa67d191cf4c07466c41a";
    hash = "sha256-mnigzatTsYpub3paizkKp9PmIpKm/F2owQBFzkiJM+8=";
  };

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = with python3.pkgs; [
    accelerate
    fastmcp
    flask
    magika
    mcp
    numpy
    pydantic
    requests
    torch
    tqdm
    transformers
    tree-sitter
    tree-sitter-markdown
  ];
  pythonRelaxDeps = [
    "tree-sitter"
  ];

  pythonImportsCheck = [
    "sembr"
  ];

  meta = {
    description = "A semantic line breaker that truly breaks lines semantically. Powered by Transformers";
    homepage = "https://github.com/admk/sembr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nialov ];
    mainProgram = "sembr";
  };
}
