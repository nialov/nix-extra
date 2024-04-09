{ inputs, lib, buildPythonPackage, enum34, future, gpsoauth, mock
, pytestCheckHook, six, setuptools, cython }:

buildPythonPackage {
  pname = "gkeepapi";
  version = inputs.gkeepapi-src.rev;
  format = "pyproject";

  src = inputs.gkeepapi-src;
  # postPatch = ''
  #   rm Makefile
  # '';
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "setuptools ~= 58.0" "setuptools" \
      --replace "cython ~= 0.29.0" "cython"
  '';

  nativeBuildInputs = [ setuptools cython ];
  propagatedBuildInputs = [ enum34 future gpsoauth mock ];

  checkInputs = [ pytestCheckHook six ];

  pythonImportsCheck = [ "gkeepapi" ];

  meta = with lib; {
    description = "An unofficial client for the Google Keep API";
    homepage = "https://github.com/kiwiz/gkeepapi";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
