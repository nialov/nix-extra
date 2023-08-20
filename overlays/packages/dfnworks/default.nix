{ inputs, lib, stdenv, python3, lagrit, fehm, pflotran }:

let

  dfnworks-base = stdenv.mkDerivation rec {
    pname = "dfnworks-base";
    version = "unstable";

    src = inputs.dfnworks-src;

    buildInputs = [
      (python3.withPackages (p:
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
        ]))
      lagrit
      fehm
      pflotran

    ];

    # TODO: Add all makefiles from subdirectories
    preBuild = ''
      makeFiles=(
          "DFNGen"
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

in dfnworks-base
