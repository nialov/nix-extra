{
  inputs,
  lib,
  buildPythonPackage,
  setuptools,
  pytestCheckHook,
  pytest,
  geopandas,
  dask,
  shapely,
  pyarrow,
}:

buildPythonPackage {
  pname = "dask-geopandas";
  version = inputs.dask-geopandas.rev;
  format = "pyproject";

  src = inputs.dask-geopandas;

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    geopandas
    shapely
    dask
    pyarrow
  ];

  checkInputs = [
    pytestCheckHook
    pytest
  ];

  disabledTests = [ "test_repr" ];

  pythonImportsCheck = [ "dask_geopandas" ];

  meta = with lib; {
    description = "Parallel GeoPandas with Dask";
    homepage = "https://github.com/geopandas/dask-geopandas";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nialov ];
  };
}
