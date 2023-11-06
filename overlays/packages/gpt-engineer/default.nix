{ inputs, lib, python3, relax-pyproject-dependencies }:

python3.pkgs.buildPythonApplication {
  pname = "gpt-engineer";
  version = inputs.gpt-engineer-src.rev;
  format = "pyproject";

  src = inputs.gpt-engineer-src;
  # src = fetchFromGitHub {
  #   owner = "AntonOsika";
  #   repo = "gpt-engineer";
  #   rev = "v${version}";
  #   hash = "sha256-06u0X/73xpDrFuhG5Mq1NTft38JmiktH1dSpXSA3QH0=";
  # };
  # patches = [ ./pyproject.patch ];

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
    python3.pkgs.pythonRelaxDepsHook
  ];
  pythonRelaxDeps = true;
  pythonRemoveDeps = true;

  propagatedBuildInputs = with python3.pkgs; [
    tkinter
    dataclasses-json
    openai
    termcolor
    typer
    tiktoken
    tabulate
    python-dotenv
    (langchain.override {
      psycopg2 = psycopg2.overrideAttrs (_: _: { doCheck = false; });
    })
    backoff
    llama-index
  ];

  # Disable rudder-sdk-python usage (telemetry) and remove
  # development dependencies from pyproject.toml
  postPatch = ''
    ${relax-pyproject-dependencies}/bin/relax-pyproject-dependencies ./pyproject.toml \
        black pytest mypy pre-commit ruff agent-protocol tree_sitter_languages rank-bm25 rudder-sdk-python
    substituteInPlace gpt_engineer/cli/collect.py \
      --replace "send_learning(learnings)" "return"
  '';
  # substituteInPlace pyproject.toml \
  #   --replace "'rudder-sdk-python == 2.0.2'," "" \
  #   --replace "'pytest == 7.3.1'," "" \
  #   --replace "'black == 23.3.0'," "" \
  #   --replace "'pre-commit == 3.3.3'," "" \
  #   --replace "'mypy == 1.3.0'," "" \
  #   --replace "dataclasses-json == 0.5.7" "dataclasses-json >= 0.5.7" \
  #   --replace "termcolor==2.3.0" "termcolor >= 2.0.0" \
  #   --replace "'ruff == 0.0.272'," ""

  pythonImportsCheck = [
    "gpt_engineer"
    # Tested because contents are substituted in postPatch
    "gpt_engineer.cli.collect"
  ];

  checkInputs = with python3.pkgs; [ pytestCheckHook pytest ];

  disabledTestPaths = [
    # Telemetry test
    "tests/test_collect.py"
    # openai test
    "tests/test_ai.py"
    # package install test
    "tests/test_install.py"
    # openai test
    "tests/test_token_usage.py"
  ];

  meta = with lib; {
    description =
      "Specify what you want it to build, the AI asks for clarification, and then builds it";
    homepage = "https://github.com/AntonOsika/gpt-engineer";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
