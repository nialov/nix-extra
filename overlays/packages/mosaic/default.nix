{ inputs, lib, python3, ... }:

let

  self = python3.pkgs.buildPythonApplication {
    pname = "mosaic";
    version = "unstable-2023-07-13-${inputs.mosaic-src.rev}";
    format = "pyproject";
    src = inputs.mosaic-src.outPath;
    propagatedBuildInputs = with python3.pkgs;
      [ typer pillow ] ++ typer.passthru.optional-dependencies.all;
    nativeBuildInputs = with python3.pkgs; [ setuptools wheel ];
    checkInputs = with python3.pkgs; [
      pytestCheckHook
      pytest
      pytest-regressions
    ];

    pythonImportsCheck = [ "mosaic" ];

    meta = with lib; {
      description = "Python script for creating photomosaic images";
      homepage = "https://github.com/nialov/mosaic";
      license = licenses.mit;
      maintainers = with maintainers; [ nialov ];
    };
  };

in self
