{ inputs, buildPythonPackage, lib, pytestCheckHook, click, jinja2
, beautifulsoup4, cachecontrol, defusedxml, entrypoints, lazy-object-proxy, lxml
, python-telegram-bot, pytimeparse, pyyaml, requests, schedule, selenium, six
, psutil, sh, pytest, pylint, mock, pytest-mock, freezegun, git, jq }:

buildPythonPackage {
  pname = "kibitzr";
  version = "7.0.0";

  # pypi version does not include tests
  src = inputs.kibitzr-src;
  # src = fetchFromGitHub {
  #   owner = "kibitzr";
  #   repo = "kibitzr";
  #   rev = "refs/tags/v${version}";
  #   sha256 = "sha256-cipQK9Gi8eJHNOivulHcfohsuRaZTfSglJdn7yekvfo=";
  # };

  # dontConfigure = true;

  # nativeBuildInputs = [ ];
  # scikit-build cmake cython
  # ++ lib.optionals stdenv.hostPlatform.isLinux [
  # On Linux the .so files ends up referring to libh3.so instead of the full
  # Nix store path. I'm not sure why this is happening! On Darwin it works
  # fine.
  # autoPatchelfHook
  # ];

  # This is not needed per-se, it's only added for autoPatchelfHook to work
  # correctly. See the note above ^^
  # buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ h3 ];

  # propagatedBuildInputs = [ click Jinja2 bs4 cachecontrol defusedxml entrypoints lazy-object-proxy lxml python-telegram-bot pytimeparse pyyaml requests schedule selenium six psutil ];
  nativeBuildInputs = [ git jq ];
  propagatedBuildInputs = [
    click
    jinja2
    beautifulsoup4
    cachecontrol
    defusedxml
    entrypoints
    lazy-object-proxy
    lxml
    python-telegram-bot
    pytimeparse
    pyyaml
    requests
    schedule
    selenium
    six
    psutil
    sh
  ];

  checkInputs = [ pytestCheckHook pytest pylint mock pytest-mock freezegun ];

  disabledTests = [ "test_scenario" "test_fill_form_sample" ];
  # The following prePatch replaces the h3lib compilation with using the h3 packaged in nixpkgs.
  #
  # - Remove the h3lib submodule.
  # - Patch CMakeLists to avoid building h3lib, and use h3 instead.
  # prePatch = let
  #   cmakeCommands = ''
  #     include_directories(${h3}/include/h3)
  #     link_directories(${h3}/lib)
  #   '';
  # in ''
  #   rm -r src/h3lib
  #   substituteInPlace CMakeLists.txt --replace "add_subdirectory(src/h3lib)" "${cmakeCommands}"
  # '';

  # Extra check to make sure we can import it from Python

  postPatch = ''
    substituteInPlace setup.py \
      --replace "'pytest-runner'" ""
    substituteInPlace requirements/base.in \
      --replace "bs4" "beautifulsoup4"
  '';
  pythonImportsCheck = [ "kibitzr" ];

  meta = with lib; {
    homepage = "https://github.com/kibitzr/kibitzr";
    description = "Personal Web Assistant";
    license = licenses.mit;
    maintainers = [ maintainers.nialov ];
  };
}
