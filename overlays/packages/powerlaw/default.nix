{
  inputs,
  lib,
  buildPythonPackage,
  scipy,
  matplotlib,
  numpy,
  mpmath,
  pytestCheckHook,
  pytest,
}:

buildPythonPackage {
  pname = "powerlaw";
  version = "1.5";

  src = inputs.powerlaw-src;
  # src = fetchFromGitHub {
  #   owner = "jeffalstott";
  #   repo = "powerlaw";
  #   # The version at this rev should be aligned to the one at pypi according
  #   # to the commit message.
  #   rev = "6732699d790edbe27c2790bf22c3ef7355d2b07e";
  #   sha256 = "sha256-x3jXk+xOQpIeEGlzYqNwuZNPpkesF0IOX8gUhhwHk5Q=";
  # };

  propagatedBuildInputs = [
    scipy
    numpy
    matplotlib
    mpmath
  ];

  postPatch = ''
    substituteInPlace testing/test_powerlaw.py \
        --replace "reference_data/" "testing/reference_data/"
  '';

  checkInputs = [
    pytest
    pytestCheckHook
  ];

  pytestFlagsArray = [ "testing" ];

  pythonImportsCheck = [ "powerlaw" ];

  meta = with lib; {
    description = "Toolbox for testing if a probability distribution fits a power law";
    homepage = "http://www.github.com/jeffalstott/powerlaw";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
