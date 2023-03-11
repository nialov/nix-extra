{ inputs, lib, buildPythonPackage, gazpacho, rich }:

buildPythonPackage rec {
  pname = "synonym-cli";
  version = inputs.synonym-cli-src.shortRev;

  src = inputs.synonym-cli-src;
  # src = fetchFromGitHub {
  #   owner = "agmmnn";
  #   repo = pname;
  #   rev = "v${version}";
  #   sha256 = "sha256-KLk6OMuQFWv+zToqJeePW17fK+eols+3VB8B4w8Sy5Y=";
  # };

  # buildInputs = [ sphinx ];
  propagatedBuildInputs = [ gazpacho rich ];

  pythonImportsCheck = [ "synonym_cli" "synonym_cli.cli" ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/${src.owner}/${pname}";
    maintainers = with maintainers; [ nialov ];
    # TODO: No license for project
    license = licenses.bsd3;
    broken = true;
  };

}
