{ inputs, lib, stdenv, gfortran, petsc, mpi, hdf5-full, metis, python3, busybox
, openssh, runCommand, parmetis }:

# TODO: mpi must be the same used for compiling petsc
# petsc should therefore have passthru attribute of the mpi used

stdenv.mkDerivation (finalAttrs: {
  pname = "pflotran";
  version = "master";

  src = inputs.pflotran-src;

  postPatch = let
    # TODO: Probably only part of the flags are required
    # could try using NIX_LD path or similar method to give them
    flags =
      "-L${hdf5-full}/lib -I${hdf5-full}/include -lhdf5_hl -lhdf5_hl_fortran -lhdf5 -lz -ldl -lm -h5p";
  in ''
    substituteInPlace src/pflotran/makefile \
      --replace 'MYFLAGS = -I.' \
      'MYFLAGS = -I. ${flags}'  
    substituteInPlace src/pflotran/makefile \
      --replace '# the petsc configured in $PETSC_DIR/$PETSC_ARCH' \
      'LIBS =  ${flags}'
    substituteInPlace src/clm-pflotran/makefile \
      --replace 'TEST_OPTIONS += --mpiexec $(MPIEXEC)' \
      'TEST_OPTIONS += --mpiexec ${mpi}/bin/mpiexec'
  '';

  # TODO: What inputs should be given in what way? (nativeBuildInputs, propagatedBuildInputs?)
  nativeBuildInputs = [ gfortran ];
  propagatedBuildInputs = [ mpi ];
  # TODO: Is metis used?
  buildInputs = [ petsc hdf5-full metis parmetis ];
  enableParallelBuilding = true;

  configureFlags = [
    "--with-petsc-dir=${petsc}"
    "--with-petsc-arch=arch-linux-c-opt"
    "--prefix=$(out)"
  ];
  # TODO: Are these required with the flags set earlier?
  makeFlags = [
    "HDF5_INCLUDE=${hdf5-full}/include"
    "HDF5_LIB=${hdf5-full}/lib"
    "have_hdf5=1"
  ];
  preConfigure = ''
    patchShebangs configure
  '';

  # TODO: This should use the make check functionality but downstream flags in
  # the commands get set wrong e.g. mpiexec --oversubscribe flag is incorrectly
  # passed
  # TODO: h5py should probably be compiled with same hdf5?
  # TODO: Test log printing should probably be done better
  passthru = {
    h5py = python3.pkgs.h5py.override { hdf5 = hdf5-full; };
    tests = {
      main = let
        pythonWithH5py = python3.withPackages (_: [ finalAttrs.passthru.h5py ]);
        # TODO: Should clean the environment variables set inside the script. Not sure what is necessary.
        # TODO: Some tests fail because petsc is not compiled with hypre which is not packaged in nixpkgs
      in runCommand "pflotran-main-test" { } ''
        tmpdir=$(mktemp -d -u)
        cp -r -L ${finalAttrs.src} $tmpdir
        chmod -R 777 $tmpdir
        cd $tmpdir/regression_tests

        export PATH=$PATH:${openssh}/bin
        # Fix to make mpich run in a sandbox
        export OMP_NUM_THREADS=1
        export HYDRA_IFACE=lo
        export OMPI_MCA_rmaps_base_oversubscribe=1
        export OMPI_MCA_btl="vader,self"

        ${pythonWithH5py}/bin/python regression_tests.py -e ${finalAttrs.finalPackage}/bin/pflotran \
            --suites standard standard_parallel \
            --mpiexec ${mpi}/bin/mpiexec \
            --recursive-search ./default ./general \
            --backtrace --debug ||
        echo "Test logs:" && \
        echo "" && \
        ${busybox}/bin/find . -name '*.testlog' -exec ${busybox}/bin/cat {} \; && \
        exit 1
        cp -L $tmpdir $out
      '';
    };
  };

  doCheck = false;
  # checkPhase = let
  #   pythonWithH5py = python3.withPackages (p: with p; [ h5py ]);
  #   defaultConfigs = ''
  #     $(sed -n '/STANDARD_CFG =/,/ifneq ($(strip $(HYPRE_LIB)),)/{//!p;}' Makefile)
  #   '';
  # in ''
  #   runHook preCheck
  #   cd /build/source/regression_tests

  #   export PATH=$PATH:${openssh}/bin
  #   # Fix to make mpich run in a sandbox
  #   export OMP_NUM_THREADS=1
  #   export HYDRA_IFACE=lo
  #   export OMPI_MCA_rmaps_base_oversubscribe=1

  #   ${pythonWithH5py}/bin/python regression_tests.py -e /build/source/src/pflotran/pflotran \
  #       --suites standard standard_parallel \
  #       --mpiexec ${mpi}/bin/mpiexec \
  #       --config-files ${defaultConfigs} \
  #       --backtrace --debug ||
  #   echo "Test logs:" && \
  #   echo "" && \
  #   ${busybox}/bin/find . -name '*.testlog' -exec ${busybox}/bin/cat {} \; && \
  #   exit 1
  #   runHook postCheck
  # '';

  meta = with lib; {
    description = "";
    homepage = "https://bitbucket.org/pflotran/pflotran";
    license = licenses.lgpl3Only;
    maintainers = with maintainers; [ nialov ];
  };
})
