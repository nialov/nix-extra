{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  pythonRelaxDepsHook,
  python,
  tiktoken,
  pydantic,
  litellm,
  click,
  rich,
  opentelemetry-api,
  tomli,
  fastapi,
  uvicorn,
  httpx,
  openai,
  mcp,
  magika,
  zstandard,
  websockets,
  transformers,
  watchdog,
  sqlite-vec,
  ast-grep-cli,
  ast-grep-py,
  rtk,
  pkgs,
}:
let
  version = "0.22.4";
in
buildPythonPackage rec {
  pname = "headroom-ai";
  inherit version;
  pyproject = true;

  src = fetchFromGitHub {
    owner = "chopratejas";
    repo = "headroom";
    rev = "v${version}";
    hash = "sha256-DHf9t1zQmHAJcVvZ6J+HHSJdUt+xzofkmHxhA1MgZlw=";
  };

  env = {
    ORT_LIB_LOCATION = "${pkgs.onnxruntime.dev}/lib";
    ORT_PREFER_DYNAMIC_LINK = "1";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    pkg-config
    pythonRelaxDepsHook
  ];

  buildInputs = [ pkgs.onnxruntime.dev ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-WQBvil0bsS6/Z6b+uRauwOQq4VZ57VwAoghcyFdVgLE=";
  };

  pythonRelaxDeps = [ "litellm" ];

  dependencies = [
    tiktoken
    pydantic
    litellm
    click
    rich
    opentelemetry-api
    ast-grep-cli
    ast-grep-py
    fastapi
    uvicorn
    httpx
    openai
    mcp
    magika
    zstandard
    websockets
    transformers
    watchdog
    sqlite-vec
    rtk
  ]
  ++ lib.optionals (python.pythonOlder "3.11") [
    tomli
  ]
  ++ httpx.optional-dependencies.http2;

  postPatch = ''
    substituteInPlace headroom/install/runtime.py \
      --replace-fail 'sys.executable, "-m", "headroom.cli"' '"headroom"'
    substituteInPlace headroom/cli/wrap.py \
      --replace-fail 'sys.executable, "-m", "headroom.cli", "proxy"' '"headroom", "proxy"'
  '';

  doCheck = false;
  dontCheckRuntimeDeps = true;
  pythonImportsCheck = [ "headroom" ];

  meta = with lib; {
    description = "Context optimization layer for LLM applications";
    homepage = "https://github.com/chopratejas/headroom";
    changelog = "https://github.com/chopratejas/headroom/blob/v${version}/CHANGELOG.md";
    license = licenses.asl20;
    mainProgram = "headroom";
    maintainers = [ ];
  };
}
