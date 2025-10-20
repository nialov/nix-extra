{
  inputs,
  prev,
  final,
}:
let

  parmetis =
    let
      parmetisPkgs = import inputs.nixpkgs-2505 {
        inherit (prev) system;
        config = {
          allowUnfree = true;
        };
      };
    in
    parmetisPkgs.parmetis;

  petscStableMpi = inputs.nixpkgs-petsc.legacyPackages."${prev.system}".petsc.override {
    inherit (final) mpi;
  };
in
petscStableMpi.overrideAttrs (
  _: prevAttrs: {
    buildInputs = prevAttrs.buildInputs ++ [
      prev.metis
      final.hdf5-full
      prev.zlib
      parmetis
    ];
    # RUN ./configure --CFLAGS='-O3' --CXXFLAGS='-O3' --FFLAGS='-O3' --with-debugging=no --download-mpich=yes --download-hdf5=yes --download-hdf5-fortran-bindings=yes --download-fblaslapack=yes --download-metis=yes --download-parmetis=yes
    # make PETSC_DIR=/build/petsc-3.19.2 PETSC_ARCH=arch-linux-c-opt all
    # export FC="${prev.gfortran}/bin/gfortran" F77="${prev.gfortran}/bin/gfortran"
    preConfigure = ''
      patchShebangs ./lib/petsc/bin
    '';
    configureFlags = [
      "F77=${prev.gfortran}/bin/gfortran"
      "AR=${prev.gfortran}/bin/ar"
      "CC=${prev.openmpi}/bin/mpicc"
      "--with-hdf5=1"
      "--with-hdf5-fortran-bindings=1"
      "--CFLAGS='-O3'"
      "--CXXFLAGS='-O3'"
      "--FFLAGS='-O3'"
      "--with-debugging=no"
      "--with-metis=1"
      # "--with-fblaslapack=1"
      # "--with-hdf5-include=${prev.hdf5-fortran.dev.outPath}/include"
      # "--with-hdf5-lib=-L${prev.hdf5-fortran.out.outPath}/lib -lz"
      # "--with-mpi=0"
      # '' else ''
      # "--CC=mpicc"
      "--with-cxx=mpicxx"
      "--with-fc=mpif90"
      "--with-mpi=1"
      "--with-zlib=1"
      # ''}
      # ${if withp4est then ''
      "--with-p4est=1"
      # "--with-zlib-include=${prev.zlib.dev}/include"
      # "--with-zlib-lib=-L${prev.zlib}/lib -lz"
      "--with-blas=1"
      "--with-lapack=1"
      "--with-parmetis=1"
    ];
    # postPatch = ''
    #   substituteInPlace config/BuildSystem/config/base.py \
    #     --replace "return not (returnCode or len(output))" \
    #     "return True"
    # '';
    doCheck = false;
    mpiSupport = true;
    makeFlags = [ "PETSC_ARCH=arch-linux-c-opt" ];
    passthru = { inherit parmetis; };

  }
)
