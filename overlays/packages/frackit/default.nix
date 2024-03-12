{ inputs, lib, stdenv, cmake, python3, opencascade-occt, doxygen, graphviz-nox
, fontconfig, ... }:

let

  frackit-base = stdenv.mkDerivation {
    pname = "frackit-base";
    version = "0.0.1";

    src = inputs.frackit-src;

    patches = [ ./python-wheel.patch ];

    postPatch = ''
      substituteInPlace appl/CMakeLists.txt \
        --replace "add_subdirectory(example3)" "# add_subdirectory(example3)" 
    '';

    preBuild = ''
      HOME=$TMPDIR
    '';

    nativeBuildInputs = [ cmake ];
    buildInputs = [
      (python3.withPackages (p: with p; [ pybind11 wheel pip setuptools ]))
      opencascade-occt
      doxygen
      graphviz-nox
      fontconfig
    ];
    doCheck = true;
    preCheck = ''
      make build_tests
    '';
    checkPhase = ''
      runHook preCheck
      ctest --output-on-failure
      runHook postCheck
    '';

    FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";
    FONTCONFIG_PATH = "${fontconfig.out}/etc/fonts/";
    postBuild = ''
      FONTCONFIG_CACHE="$(mktemp -d)" make doc_doxygen
      cp -r doc/ "$doc"
    '';

    # Install as Python package
    postInstall = ''
      pushd $NIX_BUILD_TOP/$sourceRoot/build/dist
      python -m pip install ./*.whl --no-index --no-warn-script-location --prefix="$out" --no-cache
      popd
    '';

    outputs = [ "out" "doc" ];

    meta = with lib; {
      description = "";
      homepage = "https://git.iws.uni-stuttgart.de/tools/frackit";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ nialov ];
    };
  };

in frackit-base
