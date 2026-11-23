{
  inputs,
  lib,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  matplotlib,
  numpy,
}:

buildPythonPackage (finalAttrs: {
  pname = "gempy-viewer";
  version = "2026.0.5";
  pyproject = true;
  __structuredAttrs = true;

  src = inputs.gempy-viewer-src;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    numpy
    matplotlib
  ];

  # pythonImportsCheck = [
  #   "gempy_viewer"
  # ];

  meta = {
    description = "";
    homepage = "https://github.com/gempy-project/gempy_viewer";
    changelog = "https://github.com/gempy-project/gempy_viewer/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ nialov ];
  };
})
