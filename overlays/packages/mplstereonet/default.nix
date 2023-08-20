{ inputs, lib, buildPythonPackage, numpy, matplotlib, shapely, pytestCheckHook
, pytest }:

buildPythonPackage {
  pname = "mplstereonet";
  version = "0.6";
  format = "setuptools";

  src = inputs.mplstereonet-src;

  propagatedBuildInputs = [ numpy matplotlib shapely ];

  checkInputs = [ pytestCheckHook pytest ];

  # TODO: Probably fails due to shapely version stuff
  #        > FAILED tests/test_examples.py::test_all_examples - TypeError:
  #        object of type 'GeometryCollection' has no len()

  disabledTests = [ "test_all_examples" ];

  pythonImportsCheck = [ "mplstereonet" ];

  meta = with lib; {
    description = "Stereonets for matplotlib";
    homepage = "https://github.com/joferkington/mplstereonet";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
