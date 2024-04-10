{ inputs, lib, buildPythonPackage, setuptools, multimethod, numpy, packaging
, pandas, pydantic, typeguard, typing-inspect, wrapt, pytestCheckHook, pytest
, pyspark, pyyaml, pytest-asyncio, hypothesis, sphinx, requests, geopandas, mypy
, polars, pyarrow, joblib }:

buildPythonPackage {
  pname = "pandera";
  version = inputs.pandera-src.rev;
  format = "pyproject";

  src = inputs.pandera-src;

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    multimethod
    numpy
    packaging
    pandas
    pydantic
    typeguard
    typing-inspect
    wrapt
    pyspark
    pyyaml
    polars
    pyarrow
    joblib
  ];

  checkInputs = [
    pytestCheckHook
    pytest
    # pytest-xdist
    pytest-asyncio
    hypothesis
    sphinx
    requests
    geopandas
    mypy
  ];

  disabledTests = [
    "test_pandas_stubs_false_positives"
    # hypothesis errors related to collecting tests
    "test_pandas_data_type"
    "test_numpy_data_type"
    # requires setting up an API, does not just work
    "test_app"
    # conflict with typeguard version?
    "test_python_typing_dtypes"
    # Odd typing error
    "test_mypy_pandas_dataframe"
    # TypeError: 'type' object is not s...
    "test_pandas_modules_importable"
    # Error while executing check function KeyError
    "test_check_groups"
  ];

  pythonImportsCheck = [ "pandera" ];

  meta = with lib; {
    description =
      "A light-weight, flexible, and expressive statistical data testing library";
    homepage = "https://github.com/unionai-oss/pandera";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
  };
}
