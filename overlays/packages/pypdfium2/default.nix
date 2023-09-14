{ lib, buildPythonPackage, fetchFromGitHub, build, ctypesgen, setuptools, wheel
}:

buildPythonPackage rec {
  pname = "pypdfium2";
  version = "4.20.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "pypdfium2-team";
    repo = "pypdfium2";
    rev = version;
    hash = "sha256-FlCN+oYQ3yNHDlHxa2xeTQmPZ+sfXFz7SOzksWEi7CY=";
  };

  PDFIUM_PLATFORM = "sourcebuild";

  nativeBuildInputs = [ build ctypesgen setuptools wheel ];

  pythonImportsCheck = [ "pypdfium2" ];

  meta = with lib; {
    description = "Python bindings to PDFium";
    homepage = "https://github.com/pypdfium2-team/pypdfium2";
    license = with licenses; [ ];
    maintainers = with maintainers; [ nialov ];
  };
}
