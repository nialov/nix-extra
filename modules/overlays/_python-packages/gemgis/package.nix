{
  inputs,
  lib,
  buildPythonPackage,
  setuptools,
  setuptools-scm,
  affine,
  geopandas,
  matplotlib,
  numpy,
  pandas,
  pyproj,
  pyvista,
  rasterio,
  shapely,
  build,
  twine,
  wheel,
  # nbsphinx,
  # numpydoc,
  # sphinx,
  # sphinx-automodapi,
  # sphinx-book-theme,
  # sphinx-copybutton,
  # sphinx-gallery,
  # sphinx-markdown-tables,
  # sphinx-numfig,
  # sphinx-rtd-theme,
  gempy,
  geopy,
  mplstereonet,
  owslib,
  # pvgeo,
  py7zr,
  pypdf,
  requests,
  rioxarray,
  scikit-image,
  scikit-learn,
  scipy,
  # segysak,
  tqdm,
  urllib3,
  xarray,
  # xml,
  xmltodict,
  pytest,
  pytest-cov,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "gemgis";
  version = "1.1.9";
  pyproject = true;
  __structuredAttrs = true;

  src = inputs.gemgis-src;

  postPatch = ''
    substituteInPlace tests/test_gemgis.py \
      --replace-fail "gg.download_gemgis_data.download_tutorial_data(filename='test_gemgis.zip',
                                                   dirpath='../docs/getting_started/tutorial/data/test_gemgis/')" \
        "# Network download disabled in offline Nix tests." \
      --replace-fail "rasterio.open('../docs/getting_started/tutorial/data/test_gemgis/raster1.tif')" None
    echo "[tool.pytest.ini_options]
    doctest_optionflags=[\"NUMBER\",\"NORMALIZE_WHITESPACE\"]
    " >> pyproject.toml
    cat pyproject.toml
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    affine
    geopandas
    matplotlib
    numpy
    pandas
    pyproj
    pyvista
    rasterio
    shapely
  ];

  optional-dependencies = {
    build = [
      build
      setuptools
      twine
      wheel
    ];
    # docs = [
    #   nbsphinx
    #   numpydoc
    #   sphinx
    #   sphinx-automodapi
    #   sphinx-book-theme
    #   sphinx-copybutton
    #   sphinx-gallery
    #   sphinx-markdown-tables
    #   sphinx-numfig
    #   sphinx-rtd-theme
    # ];
    optionals = [
      gempy
      geopy
      mplstereonet
      owslib
      # pvgeo
      py7zr
      pypdf
      requests
      rioxarray
      scikit-image
      scikit-learn
      scipy
      # segysak
      tqdm
      urllib3
      xarray
      # xml
      xmltodict
    ];
    tests = [
      pytest
      pytest-cov
    ];
  };

  pythonImportsCheck = [
    "gemgis"
    "gemgis.gemgis"
    "gemgis.vector"
    "gemgis.raster"
    "gemgis.utils"
    "gemgis.visualization"
    "gemgis.web"
    "gemgis.postprocessing"
    "gemgis.misc"
    "gemgis.download_gemgis_data"
  ];

  checkInputs = [
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.tests
  ++ finalAttrs.passthru.optional-dependencies.optionals;

  pytestFlags = [
    "-v"
    # "--doctest-modules"
    "tests/test_gemgis.py"
  ];
  disabledTests = [
    "test_to_gempy_df"
    "test_create_surface_color_dict"
  ];

  meta = {
    description = "Spatial data processing for geomodeling";
    homepage = "https://github.com/cgre-aachen/gemgis";
    changelog = "https://github.com/cgre-aachen/gemgis/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ nialov ];
  };
})
