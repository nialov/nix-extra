{
  inputs,
  lib,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  gempy-engine,
  pytestCheckHook,
  approvaltests,
  scikit-image,
  gempy-viewer,
  pyvista,
  torch,
  subsurface-terra,
}:

buildPythonPackage (finalAttrs: {
  pname = "gempy";
  version = "2026.2.0a4";
  pyproject = true;
  __structuredAttrs = true;

  src = inputs.gempy-src;

  postPatch = ''
    rm -r examples
    substituteInPlace setup.cfg \
      --replace "description-file" "description_file"
  '';

  dependencies = [
    gempy-engine
    gempy-viewer
    scikit-image
    pyvista
    torch
    subsurface-terra
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];
  checkInputs = [
    pytestCheckHook
    approvaltests
  ];

  disabledTests = [
    "test_transform_1"
  ];

  pythonImportsCheck = [
    "gempy"
  ];

  pytestFlags = [
    "-v"
    "test/test_core"
    "test/test_community_bugs"
    "test/test_api/test_fault_api.py"
  ];

  meta = {
    description = "GemPy is an open-source, Python-based 3-D structural geological modeling software, which allows the implicit (i.e. automatic) creation of complex geological models from interface and orientation data. It also offers support for stochastic modeling to address parameter and model uncertainties";
    homepage = "https://github.com/gempy-project/gempy";
    changelog = "https://github.com/gempy-project/gempy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ nialov ];
  };
})
