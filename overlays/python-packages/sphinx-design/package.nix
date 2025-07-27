{
  lib,
  buildPythonPackage,
  fetchPypi,
  python,
  sphinx,
  flit-core,
}:

buildPythonPackage rec {
  pname = "sphinx-design";
  version = "0.6.1";

  src = fetchPypi {
    pname = "sphinx_design";
    inherit
      # pname
      version
      ;
    sha256 = "sha256-tE7qNxk4bQTXZcGoJXysorPm+EIdezpedCwP1F+E5jI=";
  };

  pyproject = true;
  build-system = [ flit-core ];
  # buildInputs = [ sphinx ];
  propagatedBuildInputs = [ sphinx ];

  # Seems to look for files in the wrong dir
  doCheck = false;
  checkPhase = ''
    ${python.interpreter} -m unittest discover -s tests
  '';

  meta = with lib; {
    description = "A sphinx extension for designing beautiful, view size responsive web components.";
    homepage = "https://github.com/executablebooks/sphinx-design";
    maintainers = with maintainers; [ nialov ];
    license = licenses.mit;
  };

}
