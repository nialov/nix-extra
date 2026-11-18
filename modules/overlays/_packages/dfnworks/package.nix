{
  lib,
  stdenv,
  python3,
  lagrit,
  fehm,
  pflotran,
  symlinkJoin,
  makeWrapper,
  petsc,
  lndir,
  texlive,
  mpi,
  openssh,
  ...
}:

let

  patchedSrc = python3.pkgs.pydfnworks.passthru.src;

  dfnworks-core = stdenv.mkDerivation {
    pname = "dfnworks-core";
    version = "unstable";

    src = patchedSrc;

    buildInputs = [
      lagrit
      fehm
      pflotran

    ];

    # TODO: Add all makefiles from subdirectories
    preBuild = ''
      makeFiles=(
          "DFNGen"
          "DFNTrans"
          "C_uge_correct"
      )
    '';

    buildPhase = ''
      runHook preBuild
      for makefile in "''${makeFiles[@]}"; do
            local flagsArray=(
              -j$NIX_BUILD_CORES
              SHELL=$SHELL
              $makeFlags "''${makeFlagsArray[@]}"
              $buildFlags "''${buildFlagsArray[@]}"
            )
            echoCmd 'build flags' ""''${flagsArray[@]}""
            make -C $makefile ""''${flagsArray[@]}""
            unset flagsArray
      done
      runHook postBuild
    '';

    # TODO: Continue installing from makefile outputs from all directories
    installPhase = ''
      runHook preInstall

      # Copy libraries.
      install -Dm644 -t $out/lib/        DFNGen/*.o
      install -Dm644 -t $out/lib/        DFNTrans/*.o

      # Copy binaries
      install -Dt $out/bin DFNGen/DFNGen
      install -Dt $out/bin DFNTrans/DFNTrans
      install -Dt $out/bin C_uge_correct/correct_uge

      runHook postInstall
    '';

    meta = with lib; {
      description = "Framework for discrete fracture network (DFN) modeling and simulation";
      homepage = "https://dfnworks.lanl.gov/";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ nialov ];
    };
  };

  dfnworks-full =
    let
      pythonEnv = python3.withPackages (p: [ p.pydfnworks ]);
      mpiWrapped = symlinkJoin {
        name = "mpi-wrapped";
        paths = [ mpi ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild =
          let
            wraps = [
              # Fix to make mpich run in a sandbox
              "--set OMP_NUM_THREADS 1"
              "--set HYDRA_IFACE lo"
              "--set OMPI_MCA_rmaps_base_oversubscribe 1"
              "--set OMPI_MCA_btl 'vader,self'"
              "--prefix PATH : ${lib.makeBinPath [ openssh ]}"
            ];
          in
          ''
            wrapProgram $out/bin/mpirun ${builtins.concatStringsSep " " wraps}
          '';

      };
    in
    stdenv.mkDerivation {
      name = "dfnworks-full";
      unpackPhase = ''
        mkdir $out
        ${lndir}/bin/lndir -silent ${pythonEnv} $out
      '';
      nativeBuildInputs = [ makeWrapper ];
      postBuild =
        let
          PYTHON_EXE = "${pythonEnv}/bin/python3";
          LAGRIT_EXE = "${lagrit}/bin/lagrit";
          PFLOTRAN_EXE = "${pflotran}/bin/pflotran";
          FEHM_EXE = "${fehm}/bin/fehm";
          DFNGEN_EXE = "${dfnworks-core}/bin/DFNGen";
          DFNTRANS_EXE = "${dfnworks-core}/bin/DFNTrans";
          CORRECT_UGE_EXE = "${dfnworks-core}/bin/correct_uge";
          dfnworks_PATH = "${patchedSrc}";
          PETSC_DIR = "${petsc}";
          PETSC_ARCH = "arch-linux-c-opt";
          wraps = [
            "--set PYTHON_EXE ${PYTHON_EXE}"
            "--set LAGRIT_EXE ${LAGRIT_EXE}"
            "--set PFLOTRAN_EXE ${PFLOTRAN_EXE}"
            "--set FEHM_EXE ${FEHM_EXE}"
            "--set DFNGEN_EXE ${DFNGEN_EXE}"
            "--set DFNTRANS_EXE ${DFNTRANS_EXE}"
            "--set CORRECT_UGE_EXE ${CORRECT_UGE_EXE}"
            "--set dfnworks_PATH ${dfnworks_PATH}"
            "--set PETSC_DIR ${PETSC_DIR}"
            "--set PETSC_ARCH ${PETSC_ARCH}"
            "--prefix PATH : ${
              lib.makeBinPath [
                texlive.combined.scheme-full
                mpiWrapped
                openssh
              ]
            }"
          ];
          # TODO: Add all executables to bin/ directory
          # check docker image /bin and lib/petsc/arch-*/bin/
          # e.g. ploftran, lagrit, ...
        in
        ''
          wrapProgram $out/bin/python3 ${builtins.concatStringsSep " " wraps}
          $out/bin/python3 --help > /dev/null
        '';

      doInstallCheck = true;
      installCheckPhase = ''
        export HOME=$(mktemp -d)
        check_dir=$(mktemp -d)
        examples=(
            "mapdfn"
            "faults"
            "constant"
        )
        cp --dereference --no-preserve all --recursive ${patchedSrc} $check_dir/src/
        for example in "''${examples[@]}"; do
            pushd $check_dir/src/examples/$example/
            $out/bin/python3 ./driver.py
            popd
        done
        cp -r $check_dir $out/check-output/
      '';

    };

in
dfnworks-full
