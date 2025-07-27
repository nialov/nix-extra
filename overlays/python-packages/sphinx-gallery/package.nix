{
  inputs,
  lib,
  buildPythonPackage,
  sphinx,
  pytestCheckHook,
  pytest,
  numpy,
  matplotlib,
  joblib,
  pillow,
  seaborn,
  statsmodels,
  plotly,
  graphviz,
  absl-py,
  lxml,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "sphinx-gallery";
  version = inputs.sphinx-gallery-src.shortRev;
  format = "pyproject";
  src = inputs.sphinx-gallery-src;

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    sphinx
    pillow
  ];

  # Move tests outside of package and remove use of pytest-coverage
  postPatch = ''
    mv sphinx_gallery/tests tests/
    substituteInPlace pyproject.toml \
      --replace-fail "--cov-report=" ""
    substituteInPlace pyproject.toml \
      --replace-fail "--cov=sphinx_gallery" ""
    substituteInPlace tests/test_gen_rst.py \
      --replace-fail "root = Path(__file__).parents[2]" "root = Path(__file__).parent.parent"
    substituteInPlace tests/test_notebook.py \
      --replace-fail "root = Path(__file__).parents[2]" "root = Path(__file__).parent.parent"
  '';
  # substituteInPlace tests/test_gen_rst.py \
  #   --replace-fail "sphinx_gallery/tests/reference_parse.txt" "tests/reference_parse.txt"

  checkInputs = [
    pytestCheckHook
    pytest
    numpy
    matplotlib
    joblib
    pillow
    seaborn
    statsmodels
    plotly
    graphviz
    absl-py
    lxml
  ];

  # We do not want tests from tests/tinybuild
  pytestFlagsArray = [ "tests/*.py" ];
  disabledTests = [
    # Requires jupyterlite
    "test_full_noexec"
    # "test_create_jupyterlite"
    # Requires network
    "test_embed_code_links_get_data"
  ];

  pythonImportsCheck = [ "sphinx_gallery" ];

  meta = with lib; {
    description = "Sphinx extension for automatic generation of an example gallery";
    homepage = "https://github.com/sphinx-gallery/sphinx-gallery";
    changelog = "https://github.com/sphinx-gallery/sphinx-gallery/blob/${src.rev}/CHANGES.rst";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nialov ];
  };
}
