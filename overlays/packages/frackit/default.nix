{ inputs, lib, stdenv, cmake, pythonPackages, opencascade-occt, doxygen
, graphviz-nox, fontconfig, ... }:

let

  self = stdenv.mkDerivation {
    pname = "frackit-base";
    version = "1.3.0";

    src = inputs.frackit-src;

    patches = [ ./python-wheel.patch ];

    postPatch = ''
      substituteInPlace appl/CMakeLists.txt \
        --replace-fail "add_subdirectory(example3)" "# add_subdirectory(example3)" 
    '';

    preBuild = ''
      HOME=$TMPDIR
    '';

    nativeBuildInputs = [ cmake ];
    buildInputs = [
      (pythonPackages.python.withPackages
        (p: with p; [ pybind11 wheel pip setuptools ]))
      opencascade-occt
      doxygen
      graphviz-nox
      fontconfig
    ];
    doCheck = true;
    # Check version matches that in repo
    preCheck = ''
      grep ${self.version} ${self.src}/CMakeLists.txt -q
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

in self
