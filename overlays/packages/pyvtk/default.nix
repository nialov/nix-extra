{ inputs, lib, buildPythonPackage, six, numpy, pytestCheckHook, pytest }:

buildPythonPackage rec {
  pname = "pyvtk";
  version = "0.5.14";
  format = "setuptools";

  src = inputs.pyvtk-src;

  postPatch = ''
    echo "__version__ = '0.5.14'" > pyvtk/__version__.py
    substituteInPlace setup.py \
      --replace "if 1" "if False"
    substituteInPlace test/test_pyvtk.py \
      --replace 'input_dir = "input"' 'input_dir = "test/input"' \
      --replace 'output_dir = "output"' 'output_dir = "test/output"'
  '';

  propagatedBuildInputs = [ six numpy ];

  checkInputs = [ pytestCheckHook pytest ];
  preCheck = ''
    mkdir -p test/output
  '';

  pythonImportsCheck = [ "pyvtk" ];

  meta = with lib; {
    description = "Manupulate VTK files in Python";
    homepage = "https://github.com/pearu/pyvtk";
    license = with licenses; [ ];
    maintainers = with maintainers; [ nialov ];
  };
}
