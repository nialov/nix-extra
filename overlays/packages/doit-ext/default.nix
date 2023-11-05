{ inputs, lib, buildPythonPackage, pytestCheckHook, doit, poetry-core
, pytest-regressions }:

buildPythonPackage {
  pname = "doit-ext";
  version = "0.1";
  format = "pyproject";

  src = inputs.doit-ext-src;

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ doit ];

  checkInputs = [ pytestCheckHook pytest-regressions ];

  pythonImportsCheck = [ "doit_ext" ];

  meta = with lib; {
    description = "doit-ext";
    homepage = "https://github.com/nialov/doit-ext";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
