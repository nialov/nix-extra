{
  inputs,
  lib,
  buildPythonPackage,
  numpy,
  pytestCheckHook,
  pytest,
  hypothesis,
  setuptools,
}:

buildPythonPackage {
  pname = "drillcore-transformations";
  version = "0.3.0";

  src = inputs.drillcore-transformations-src;

  pyproject = true;
  build-system = [ setuptools ];
  propagatedBuildInputs = [
    numpy
  ];

  checkInputs = [
    pytest
    hypothesis
    pytestCheckHook
  ];

  pythonImportsCheck = [ "drillcore_transformations" ];

  meta = with lib; {
    description = "Transform structural drillcore measurements";
    homepage = "http://www.github.com/nialov/drillcore-transformations";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
