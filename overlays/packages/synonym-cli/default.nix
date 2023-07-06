{ inputs, lib, buildPythonPackage, gazpacho, rich, poetry-core, aiohttp, pytest
, pytestCheckHook, requests, importlib-metadata }:

let

  gazpachoOlder =
    gazpacho.overrideAttrs (_: _: { src = inputs.gazpacho-1-1-src; });

in buildPythonPackage rec {
  pname = "synonym-cli";
  version = inputs.synonym-cli-src.shortRev;
  format = "pyproject";

  src = inputs.synonym-cli-src;
  # src = fetchFromGitHub {
  #   owner = "agmmnn";
  #   repo = pname;
  #   rev = "v${version}";
  #   sha256 = "sha256-KLk6OMuQFWv+zToqJeePW17fK+eols+3VB8B4w8Sy5Y=";
  # };
  nativeBuildInputs = [ poetry-core ];

  # buildInputs = [ sphinx ];
  propagatedBuildInputs =
    [ gazpachoOlder rich importlib-metadata aiohttp requests ];
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'importlib-metadata = "^5.2.0"' 'importlib-metadata = "*"' \
      --replace 'rich = "^12.6.0"' 'rich = "*"'
  '';

  checkInputs = [ pytestCheckHook pytest ];

  pythonImportsCheck = [ "synonym_cli" "synonym_cli.cli" ];

  # Only test of the package but also a network test
  disabledTests = [ "test_req" ];

  meta = with lib; {
    description = "";
    homepage = "https://github.com/${src.owner}/${pname}";
    maintainers = with maintainers; [ nialov ];
    # TODO: No license for project
    license = licenses.bsd3;
    # TODO: Does not seem to work and the only test is a network test
    broken = true;
  };

}
