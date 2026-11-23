{
  inputs,
  lib,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  numpy,
  pydantic,
  python-dotenv,
  pytestCheckHook,
  scipy,
  matplotlib,
  pandas,
  approvaltests,
}:

buildPythonPackage (finalAttrs: {
  pname = "gempy-engine";
  version = "2026.2.0a7";
  pyproject = true;
  __structuredAttrs = true;

  src = inputs.gempy-engine-src;

  build-system = [
    setuptools
    setuptools-scm
  ];
  dependencies = [
    numpy
    pydantic
    python-dotenv
    scipy
    matplotlib
    pandas
  ];

  checkInputs = [
    pytestCheckHook
    approvaltests
  ];
  pytestFlags = [
    "tests/test_common"
  ];

  pythonImportsCheck = [
    "gempy_engine"
  ];

  meta = {
    description = "A Python package for GemPy";
    homepage = "https://github.com/gempy-project/gempy_engine";
    changelog = "https://github.com/gempy-project/gempy_engine/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ nialov ];
  };
})
