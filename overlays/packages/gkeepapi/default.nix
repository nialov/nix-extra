{ inputs, lib, buildPythonPackage, enum34, future, gpsoauth, mock
, pytestCheckHook, setuptools, six }:

buildPythonPackage {
  pname = "gkeepapi";
  version = inputs.gkeepapi-src.rev;
  format = "pyproject";

  src = inputs.gkeepapi-src;

  nativeBuildInputs = [ setuptools ];
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
