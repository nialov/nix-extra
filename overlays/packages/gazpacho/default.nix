{
  inputs,
  lib,
  buildPythonPackage,
  pytestCheckHook,
  pytest,
  setuptools,
}:

buildPythonPackage {
  pname = "gazpacho";
  version = inputs.gazpacho-src.shortRev;

  src = inputs.gazpacho-src;
  # src = fetchFromGitHub {
  #   owner = "maxhumber";
  #   repo = pname;
  #   rev = "v${version}";
  #   sha256 = "sha256-UXOpTTiny5drJoD9cICcYD0SggEFfnyXWymiinS+IWE=";
  # };

  pyproject = true;
  build-system = [ setuptools ];
  checkInputs = [
    pytestCheckHook
    pytest
  ];

  disabledTests = [
    "test_get"
    "test_soup"
  ];

  # buildInputs = [ sphinx ];
  # propagatedBuildInputs = [ gazpacho rich ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/maxhumber/gazpacho";
    maintainers = with maintainers; [ nialov ];
    license = licenses.mit;
  };

}
