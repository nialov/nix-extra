{ inputs, lib, buildPythonPackage, poetry-core, loguru, python-dateutil, pyyaml
, tqdm, click, pytestCheckHook, pyfakefs }:

buildPythonPackage rec {
  pname = "bubop";
  version = "0.1.5";
  format = "pyproject";

  src = inputs.bubop-src;
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "poetry>=0.12" poetry-core \
      --replace poetry.masonry.api poetry.core.masonry.api
  '';

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [ loguru python-dateutil pyyaml tqdm click ];

  checkInputs = [ pytestCheckHook pyfakefs ];

  pythonImportsCheck = [ "bubop" ];

  meta = with lib; {
    description = "Bergercookie's Useful Bits Of Python";
    homepage = "https://github.com/bergercookie/bubop";
    changelog =
      "https://github.com/bergercookie/bubop/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
