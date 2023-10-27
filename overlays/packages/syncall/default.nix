{ inputs, lib, python3 }:

python3.pkgs.buildPythonApplication {
  pname = "syncall";
  version = "0.3.1";
  format = "pyproject";

  src = inputs.syncall-src;
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "poetry>=0.12" poetry-core \
      --replace poetry.masonry.api poetry.core.masonry.api
    substituteInPlace syncall/asana/asana_side.py \
      --replace "asana.Client" "asana.ApiClient"
    substituteInPlace syncall/scripts/tw_asana_sync.py \
      --replace "asana.Client" "asana.ApiClient"
    substituteInPlace syncall/asana/utils.py \
      --replace "asana.Client" "asana.ApiClient"
  '';
  nativeBuildInputs = [ python3.pkgs.poetry-core ];
  propagatedBuildInputs = with python3.pkgs; [
    pyyaml
    bidict
    click
    loguru
    python-dateutil
    rfc3339
    typing
    item-synchronizer
    bubop
    xattr
    taskw
    caldav
    gkeepapi
    google-api-python-client
    notion-client
    google-auth-oauthlib
    asana
    pyfakefs
  ];

  checkInputs = with python3.pkgs; [ pytestCheckHook ];

  # These do some weird file attribute/filesystem stuff
  disabledTests =
    [ "test_filesystem_file" "test_filesystem_side" "test_filesystem_gkeep" ];

  pythonImportsCheck = [ "syncall" ];

  meta = with lib; {
    description =
      "Bi-directional synchronization between services such as Taskwarrior, Google Calendar, Notion, Asana, and more";
    homepage = "https://github.com/bergercookie/syncall";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
