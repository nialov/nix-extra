{ inputs, lib, buildPythonPackage, sphinx, pytestCheckHook
, sphinxcontrib-serializinghtml, myst-parser, sphinxcontrib-htmlhelp }:

buildPythonPackage {
  pname = "sphinxcontrib-mermaid";
  version = "0.7.1";

  src = inputs.sphinxcontrib-mermaid-src;
  # src = fetchFromGitHub {
  #   owner = "mgaitan";
  #   repo = pname;
  #   rev = "${version}";
  #   sha256 = "sha256-qGd8scpCWQrp1oiOVu+EPWXAWfEEjl20kgaWU1Oo86c=";
  # };

  # buildInputs = [ sphinx ];
  propagatedBuildInputs =
    [ sphinx sphinxcontrib-serializinghtml myst-parser sphinxcontrib-htmlhelp ];
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
