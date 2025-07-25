{
  inputs,
  lib,
  buildPythonPackage,
  sphinx,
  pytestCheckHook,
  sphinxcontrib-serializinghtml,
  myst-parser,
  sphinxcontrib-htmlhelp,
  setuptools,
}:

buildPythonPackage {
  pname = "sphinxcontrib-mermaid";
  version = inputs.sphinxcontrib-mermaid-src.shortRev;

  src = inputs.sphinxcontrib-mermaid-src;
  # src = fetchFromGitHub {
  #   owner = "mgaitan";
  #   repo = pname;
  #   rev = "${version}";
  #   sha256 = "sha256-qGd8scpCWQrp1oiOVu+EPWXAWfEEjl20kgaWU1Oo86c=";
  # };

  # buildInputs = [ sphinx ];
  pyproject = true;
  build-system = [ setuptools ];
  propagatedBuildInputs = [
    sphinx
    sphinxcontrib-serializinghtml
    myst-parser
    sphinxcontrib-htmlhelp
  ];
  doCheck = false;
  checkInputs = [ pytestCheckHook ];
  pythonImportsCheck = [ "sphinxcontrib.mermaid" ];

  # Seems to look for files in the wrong dir
  # doCheck = false;
  # checkPhase = ''
  #   ${python.interpreter} -m unittest discover -s tests
  # '';

  meta = with lib; {
    description = "Mermaid diagrams in yours sphinx powered docs";
    homepage = "https://github.com/mgaitan/sphinxcontrib-mermaid";
    maintainers = with maintainers; [ nialov ];
    license = licenses.mit;
  };

}
