{ inputs, lib, python3, }:

python3.pkgs.buildPythonApplication {
  pname = "gpt-engineer";
  version = "0.0.7";
  format = "pyproject";

  src = inputs.gpt-engineer-src;
  # src = fetchFromGitHub {
  #   owner = "AntonOsika";
  #   repo = "gpt-engineer";
  #   rev = "v${version}";
  #   hash = "sha256-06u0X/73xpDrFuhG5Mq1NTft38JmiktH1dSpXSA3QH0=";
  # };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
    python3.pkgs.pythonRelaxDepsHook
  ];
  pythonRelaxDeps = true;

  propagatedBuildInputs = with python3.pkgs; [
    dataclasses-json
    openai
    termcolor
    typer
    tiktoken
    tabulate
  ];

  # Disable rudder-sdk-python usage (telemetry) and remove
  # development dependencies from pyproject.toml
  postPatch = ''
    substituteInPlace gpt_engineer/collect.py \
      --replace "send_learning(learnings)" ""
    substituteInPlace pyproject.toml \
      --replace "'rudder-sdk-python == 2.0.2'," "" \
      --replace "'pytest == 7.3.1'," "" \
      --replace "'black == 23.3.0'," "" \
      --replace "'pre-commit == 3.3.3'," "" \
      --replace "'mypy == 1.3.0'," "" \
      --replace "'ruff == 0.0.272'," ""
  '';

  pythonImportsCheck = [ "gpt_engineer" ];

  checkInputs = with python3.pkgs; [ pytestCheckHook pytest ];

  # Telemetry test
  disabledTestPaths = [ "tests/test_collect.py" ];

  meta = with lib; {
    description =
      "Specify what you want it to build, the AI asks for clarification, and then builds it";
    homepage = "https://github.com/AntonOsika/gpt-engineer";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
