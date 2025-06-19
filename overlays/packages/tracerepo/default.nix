{
  inputs,
  buildPythonPackage,
  lib,
  pytest,
  matplotlib,
  fractopo,
  pytest-regressions,
  hypothesis,
  poetry-core,
  sphinxHook,
  pandoc,
  sphinx-autodoc-typehints,
  sphinx-rtd-theme,
  sphinx-gallery,
  nbsphinx,
  notebook,
  ipython,
  coverage,
  pandera,
  json5,

}:

buildPythonPackage {
  pname = "tracerepo";
  version = "0.0.1";

  src = inputs.tracerepo-src;
  format = "pyproject";

  nativeBuildInputs = [
    # Uses poetry for install
    poetry-core
    # Documentation dependencies
    sphinxHook
    pandoc
    sphinx-autodoc-typehints
    sphinx-rtd-theme
    sphinx-gallery
    nbsphinx
    matplotlib
    notebook
    ipython
  ];

  sphinxRoot = "docs_src";
  outputs = [
    "out"
    "doc"
  ];

  propagatedBuildInputs = [
    fractopo
    pandera
    json5
  ];

  checkInputs = [
    pytest
    pytest-regressions
    hypothesis
    coverage
  ];

  checkPhase = ''
    runHook preCheck
    python -m coverage run --source tracerepo -m pytest
    runHook postCheck
  '';

  postCheck = ''
    python -m coverage report --fail-under 70
  '';

  pythonImportsCheck = [ "tracerepo" ];

  meta = with lib; {
    homepage = "https://github.com/nialov/tracerepo";
    description = "Fracture Network analysis";
    license = licenses.mit;
    maintainers = [ maintainers.nialov ];
  };
}
