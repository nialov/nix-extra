{ lib, buildPythonPackage, fetchPypi, click, beautifulsoup4, requests, tabulate
}:

buildPythonPackage rec {
  pname = "kr-cli";
  version = "0.1.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "B8aSsS8tNKsG3FyrwBX2YB9Vtf/+Z+7bUW5jVgSqNJg=";
  };

  # buildInputs = [ sphinx ];
  propagatedBuildInputs = [ click beautifulsoup4 requests tabulate ];

  # Seems to look for files in the wrong dir
  doCheck = false;
  # checkPhase = ''
  #   kr-cli --help
  # '';
  pythonImportsCheck = [ "kr" ];

  meta = with lib; {
    description = "CLI tool to download roms from https://roms-download.com/";
    homepage = "https://github.com/jonatasleon/kr-cli";
    maintainers = with maintainers; [ nialov ];
    license = licenses.mit;
  };

}
