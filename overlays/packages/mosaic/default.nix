{ inputs, lib, python3, poetry2nix, ripgrep }:

python3.pkgs.buildPythonApplication {
  pname = "mosaic";
  version = "unstable-2023-07-13";
  format = "setuptools";

  src = poetry2nix.cleanPythonSources { src = inputs.mosaic-src; };

  propagatedBuildInputs = with python3.pkgs; [ pillow ];

  pythonImportsCheck = [ "mosaic" ];

  postCheck = ''
    $out/bin/mosaic | ${ripgrep}/bin/rg --quiet "ERROR: Usage: "
  '';

  meta = with lib; {
    description = "Python script for creating photomosaic images";
    homepage = "https://github.com/nialov/mosaic";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
