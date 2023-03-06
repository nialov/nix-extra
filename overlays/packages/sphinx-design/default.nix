{ lib, buildPythonPackage, fetchPypi, python, sphinx }:

buildPythonPackage rec {
  pname = "sphinx-design";
  version = "0.2.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "aa49bf924516f5de8a479794c7be81e077df5599c9da2a082003d5b388e1d450";
  };

  # buildInputs = [ sphinx ];
  propagatedBuildInputs = [ sphinx ];

  # Seems to look for files in the wrong dir
  doCheck = false;
  checkPhase = ''
    ${python.interpreter} -m unittest discover -s tests
  '';

  meta = with lib; {
    description =
      "A sphinx extension for designing beautiful, view size responsive web components.";
    homepage = "https://github.com/executablebooks/sphinx-design";
    maintainers = with maintainers; [ nialov ];
    license = licenses.mit;
  };

}
