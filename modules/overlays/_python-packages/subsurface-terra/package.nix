{
  inputs,
  lib,
  buildPythonPackage,
  setuptools,
  pytestCheckHook,
  setuptools-scm,
  xarray,
  netcdf4,
  python-dotenv,
  pydantic,
  matplotlib,
  rasterio,
  pyvista,
  segyio,
  plyfile,
  tifffile,
  geopandas,
  trimesh,
  scipy,
  imageio,
}:

buildPythonPackage (finalAttrs: {
  pname = "subsurface";
  version = "2026.2.6post1";
  pyproject = true;
  __structuredAttrs = true;

  src = inputs.subsurface-src;

  postPatch = ''
    rm -r examples
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];
  dependencies = [
    xarray
    netcdf4
    python-dotenv
    pydantic
    matplotlib
    rasterio
    pyvista
    segyio
    plyfile
    tifffile
    geopandas
    trimesh
    scipy
    imageio

  ];

  checkInputs = [
    pytestCheckHook
  ];

  pytestFlags = [
    "-v"
    "--ignore"
    "tests/test_io/test_lines/test_atalaya.py"
    "--ignore"
    "tests/test_io/test_meshes/test_read_topography.py"
    "--ignore"
    "tests/test_io/test_meshes/test_surface_reader.py"
    "--ignore"
    "tests/test_io/test_volumes/test_read_volume.py"
    "--ignore"
    "tests/test_structs/test_base_structures.py"
    "--ignore"
    "tests/test_io/test_lines"
    "--ignore"
    "tests/test_visualization/test_pyvista.py"
    "--ignore"
    "tests/test_io/test_volumes/"
    "--ignore"
    "tests/test_io/test_raster/"
    "--ignore"
    "tests/test_io/test_combined/test_read_OMF.py"
    "--ignore"
    "tests/test_io/test_combined/test_read_OMF_to_well.py"
    "--ignore"
    "tests/test_io/test_meshes/test_segy_reader.py"
    "--ignore"
    "tests/test_io/test_subsurface_binary/test_read_le_file_v1.py"
    "--ignore"
    "tests/test_io/test_meshes/test_read_profiles.py"
    "--ignore"
    "tests/test_io/test_meshes/"
  ];
  pythonImportsCheck = [
    "subsurface"
  ];

  disabledTests = [
    "test_vtk_uniform_to_structured_data"
    "test_vtk_file_to_binary"
    "test_volumetric_mesh_to_subsurface"
    "test_read_unstruct"
  ];

  meta = {
    description = "Core data exchange library for subsurface science and engineering";
    homepage = "https://github.com/terranigma-solutions/subsurface";
    changelog = "https://github.com/terranigma-solutions/subsurface/blob/${finalAttrs.src.rev}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ nialov ];
  };
})
