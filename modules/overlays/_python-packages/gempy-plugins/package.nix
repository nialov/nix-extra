{
  inputs,
  lib,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  pytestCheckHook,
  gempy,
  scikit-learn,
}:

buildPythonPackage (finalAttrs: {
  pname = "gempy-plugins";
  version = "2026.0.3";
  pyproject = true;
  __structuredAttrs = true;

  src = inputs.gempy-plugins-src;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    gempy
    scikit-learn
  ];
  pythonImportsCheck = [
    "gempy_plugins"
    "gempy_plugins.gis_data"
    "gempy_plugins.orientations_generator"
  ];

  checkInputs = [
    pytestCheckHook
  ];

  pytestFlags = [
    "gempy_plugins/gis_data/"
    "gempy_plugins/orientations_generator/"
  ];

  meta = {
    description = "";
    homepage = "https://github.com/gempy-project/gempy_plugins";
    changelog = "https://github.com/gempy-project/gempy_plugins/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ nialov ];
  };
})
