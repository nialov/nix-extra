{ inputs, lib, stdenv, python3, lagrit, fehm, pflotran, symlinkJoin, makeWrapper
, petsc, lndir, texlive }:

let

  dfnworks-core = stdenv.mkDerivation {
    pname = "dfnworks-core";
    version = "unstable";

    src = inputs.dfnworks-src;

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

      runHook postInstall
    '';

    meta = with lib; {
      description = "";
      homepage = "https://dfnworks.lanl.gov/";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ nialov ];
    };
  };

  dfnworks = let

    pythonEnv = python3.withPackages (p:
      with p; [
        pybind11
        wheel
        pip
        setuptools
        numpy
        scipy
        matplotlib
        mplstereonet
        seaborn
        fpdf
        pyvtk
        pflotran.passthru.h5py
        networkx
        mpmath
      ]);

  in stdenv.mkDerivation {
    pname = "dfnworks";
    version = "unstable";

    src = inputs.dfnworks-src;

    buildInputs = [
      # lagrit
      fehm
      # pflotran

    ];

    PYTHON_EXE = "${pythonEnv}/bin/python3";
    LAGRIT_EXE = "${lagrit}/bin/lagrit";
    PFLOTRAN_EXE = "${pflotran}/bin/pflotran";
    FEHM_EXE = "${fehm}/bin/fehm";
    dfnworks_PATH = "$NIX_BUILD_TOP/$sourceRoot";

    postPatch = ''
      pushd $NIX_BUILD_TOP/$sourceRoot/pydfnworks/bin
      ${pythonEnv}/bin/python3 fix_paths.py
      popd
    '';

    buildPhase = ''
      runHook preBuild

      pushd $NIX_BUILD_TOP/$sourceRoot/pydfnworks/
      ${pythonEnv}/bin/python3 setup.py bdist_wheel
      popd

      runHook postBuild
    '';
    # Install as Python package
    installPhase = ''
      runHook preInstall

      pushd $NIX_BUILD_TOP/$sourceRoot/pydfnworks/dist
      ${pythonEnv}/bin/python3 -m pip install ./*.whl --no-index --no-warn-script-location --prefix="$out" --no-cache
      popd

      runHook postInstall
    '';

    # Install as Python package
    # postInstall = let
    #   # pythonDfnworks = python3.withPackages (p:
    #   #   with p; [
    #   #     pybind11
    #   #     wheel
    #   #     pip
    #   #     setuptools
    #   #     numpy
    #   #     scipy
    #   #     matplotlib
    #   #     mplstereonet
    #   #     seaborn
    #   #     fpdf
    #   #     pyvtk
    #   #     pflotran.passthru.h5py
    #   #     networkx
    #   #     mpmath

    #   #   ]);
    #   pythonVersion = lib.versions.majorMinor python3.version;
    #   # TODO: The install does not work. The installer tries to query pypi for the packages
    #   # cp -r -L ${pythonDfnworks}/${pythonDfnworks.sitePackages}/ $out/lib/python${pythonVersion}/site-packages
    # in ''
    #   cd ./pydfnworks
    #   python3 setup.py bdist_wheel
    #   mkdir -p $out/lib/python${pythonVersion}/site-packages
    #   export PYTHONPATH=$out/lib/python${pythonVersion}/site-packages:$PYTHONPATH
    #   python3 -m pip install --no-index dist/*.whl --target $out/lib/python${pythonVersion}/site-packages
    # '';

    meta = with lib; {
      description = "";
      homepage = "https://dfnworks.lanl.gov/";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ nialov ];
    };
  };
  dfnworks-python = python3.pkgs.buildPythonPackage {
    pname = "dfnworks";
    version = "unstable";

    src = inputs.dfnworks-src;

    nativeBuildInputs = [ python3.pkgs.setuptools ];

    propagatedBuildInputs = with python3.pkgs; [
      numpy
      scipy
      matplotlib
      mplstereonet
      fpdf
      pyvtk
      pflotran.passthru.h5py
      networkx
      seaborn
      mpmath
    ];

    checkInputs = with python3.pkgs; [ nose ];

    postPatch = ''
      substituteInPlace ./pydfnworks/pydfnworks/release.py \
        --replace "datetime" ""
      cd ./pydfnworks
    '';

    meta = with lib; {
      description = "";
      homepage = "https://dfnworks.lanl.gov/";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ nialov ];
    };
  };

  dfnworks-full = let pythonEnv = python3.withPackages (_: [ dfnworks-python ]);
  in stdenv.mkDerivation {
    name = "dfnworks-full";
    unpackPhase = ''
      mkdir $out
      ${lndir}/bin/lndir -silent ${pythonEnv} $out
      # install --directory ${pythonEnv} $src
      # export src=$(mktemp -d)
      # ls -la ${pythonEnv}
      # exit 1
      # cp -r ${pythonEnv} $src
      # ls -la $src
    '';
    buildInputs = [ makeWrapper ];
    postBuild = let
      PYTHON_EXE = "${pythonEnv}/bin/python3";
      LAGRIT_EXE = "${lagrit}/bin/lagrit";
      PFLOTRAN_EXE = "${pflotran}/bin/pflotran";
      FEHM_EXE = "${fehm}/bin/fehm";
      DFNGEN_EXE = "${dfnworks-core}/bin/DFNGen";
      dfnworks_PATH = inputs.dfnworks-src;
      wraps = [
        "--set PYTHON_EXE ${PYTHON_EXE}"
        "--set LAGRIT_EXE ${LAGRIT_EXE}"
        "--set PFLOTRAN_EXE ${PFLOTRAN_EXE}"
        "--set FEHM_EXE ${FEHM_EXE}"
        "--set DFNGEN_EXE ${DFNGEN_EXE}"
        "--set dfnworks_PATH ${dfnworks_PATH}"
        "--prefix PATH : ${lib.makeBinPath [ texlive.combined.scheme-full ]}"
      ];
    in ''
      wrapProgram $out/bin/python3 ${builtins.concatStringsSep " " wraps}
      $out/bin/python3 --help > /dev/null
    '';

    doInstallCheck = true;
    installCheckPhase = ''
      check_dir=$(mktemp -d)
      pushd $check_dir
      $out/bin/python3 ${inputs.dfnworks-src}/examples/constant/driver.py
      popd
    '';

  };

in dfnworks-full
