{
  inputs,
  lib,
  buildPythonPackage,
  matplotlib,
  pytestCheckHook,
  pytest,
}:

let
  python-ternary = buildPythonPackage {
    pname = "python-ternary";
    version = "1.0.8";

    src = inputs.python-ternary-src;

    propagatedBuildInputs = [ matplotlib ];

    checkInputs = [
      pytestCheckHook
      pytest
    ];

    pythonImportsCheck = [ "ternary" ];

    meta = with lib; {
      description = "Make ternary plots in python with matplotlib";
      homepage = "https://github.com/marcharper/python-ternary";
      license = licenses.mit;
      maintainers = with maintainers; [ nialov ];
    };
  };
in
python-ternary
