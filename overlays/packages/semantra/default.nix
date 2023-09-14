{ inputs, lib, python3 }:

python3.pkgs.buildPythonApplication {
  pname = "semantra";
  version = "unstable-2023-07-08";
  format = "pyproject";

  src = inputs.semantra-src;
  # src = fetchFromGitHub {
  #   owner = "freedmand";
  #   repo = "semantra";
  #   rev = "55ae5fe5ebc02f723b678e6fd2084316853c9d72";
  #   hash = "sha256-obteS2vUfHoKYQnDv5QL8HnRTST9N8+UsiPjVRGPPmg=";
  # };

  nativeBuildInputs = [ python3.pkgs.setuptools python3.pkgs.wheel ];

  propagatedBuildInputs = with python3.pkgs; [
    annoy
    click
    flask
    openai
    pillow
    pypdfium
    python-dotenv
    tiktoken
    torch
    tqdm
    transformers
  ];

  pythonImportsCheck = [ "semantra" ];

  meta = with lib; {
    description = "Multi-tool for semantic search";
    homepage = "https://github.com/freedmand/semantra";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
