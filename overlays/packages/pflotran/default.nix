{ inputs, lib, stdenv, gfortran, petsc, mpi, hdf5-full, metis, breakpointHook }:

# let

#   mpi = inputs.lmix-flake-src.packages."${system}".openmpi_4_1_4_gcc11;

# in 
stdenv.mkDerivation {
  pname = "pflotran";
  version = "master";
  preBuild = ''
    export LD_LIBRARY_PATH=${hdf5-full}/lib:$LD_LIBRARY_PATH
  '';

  src = inputs.pflotran-src;

  # ifdef have_hdf5
  #   MYFLAGS += -I$(HDF5_INCLUDE) -I$(HDF5_LIB) ${FC_DEFINE_FLAG}PETSC_HAVE_HDF5
  # endif
  # ifdef have_hdf5
  # LIBS +=  -L${HDF5_LIB} -lhdf5_fortran -lhdf5 -lz 
  # endif
  # patches = [ ./pflotran_makefile_v2.patch ];
  # postPatch = let
  #   flags =
  #     "-I${hdf5-full}/include -I${hdf5-full}/lib -L${hdf5-full}/lib -lhdf5_fortran -lhdf5 -lz";
  # in ''
  #   substituteInPlace src/pflotran/makefile \
  #     --replace 'MYFLAGS = -I.' \
  #     'MYFLAGS = -I. ${flags}'  
  #   substituteInPlace src/pflotran/makefile \
  #     --replace '# the petsc configured in $PETSC_DIR/$PETSC_ARCH' \
  #     'LIBS =  ${flags}'
  # '';
  # PETSC_HAVE_HDF5 = 1;

  nativeBuildInputs = [ gfortran breakpointHook ];
  propagatedBuildInputs = [ mpi ];
  buildInputs = [ petsc hdf5-full metis ];
  enableParallelBuilding = true;

  configureFlags = [
    "--with-petsc-dir=${petsc}"
    "--with-petsc-arch=arch-linux-c-opt"
    "--prefix=$(out)"
  ];
  makeFlags = [
    "HDF5_INCLUDE=${hdf5-full}/include"
    "HDF5_LIB=${hdf5-full}/lib"
    "have_hdf5=1"
  ];
  preConfigure = ''
    patchShebangs configure
  '';
  # configureFlagsArray=(
  #   $configureFlagsArray
  #   "--with-petsc-dir=${petsc}"
  #   "--with-petsc-arch=linux-gnu-c-debug"
  # )

  # configurePhase = ''
  #   ./configure 
  # '';

  meta = with lib; {
    description = "";
    homepage = "https://bitbucket.org/pflotran/pflotran";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ nialov ];
  };
}
