{ inputs, lib, buildPythonPackage, poetry-core, bidict, bubop, pytestCheckHook
, pyfakefs }:

buildPythonPackage rec {
  pname = "item-synchronizer";
  version = "1.1.4";
  format = "pyproject";

  src = inputs.item-synchronizer-src;
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "poetry>=0.12" poetry-core \
      --replace poetry.masonry.api poetry.core.masonry.api
  '';

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [ bidict bubop ];

  checkInputs = [ pytestCheckHook pyfakefs ];

  pythonImportsCheck = [ "item_synchronizer" ];

  meta = with lib; {
    description = "Synchronize items from two different sources";
    homepage = "https://github.com/bergercookie/item_synchronizer";
    changelog =
      "https://github.com/bergercookie/item_synchronizer/blob/${src.rev}/CHANGELOG.md";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
