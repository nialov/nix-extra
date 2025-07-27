{
  inputs,
  lib,
  stdenv,
  cmake,
  python3Packages,
  opencascade-occt,
  doxygen,
  graphviz-nox,
  fontconfig,
  ...
}:

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
      (python3Packages.python.withPackages (
        p: with p; [
          pybind11
          wheel
          pip
          setuptools
        ]
      ))
      opencascade-occt
      doxygen
      graphviz-nox
      fontconfig
    ];

    FONTCONFIG_FILE = "${fontconfig.out}/etc/fonts/fonts.conf";
    FONTCONFIG_PATH = "${fontconfig.out}/etc/fonts/";
    postBuild = ''
      FONTCONFIG_CACHE="$(mktemp -d)" make doc_doxygen
      cp -r doc/ "$doc"
    '';

    doCheck = true;
    # Check version matches that in repo
    preCheck = ''
      grep ${self.version} ${self.src}/CMakeLists.txt -q
      make build_tests
    '';
    # Skip failing test_triangle test
    checkPhase = ''
      runHook preCheck
      ctest --output-on-failure -E '^test_triangle$'
      runHook postCheck
    '';

    # Install as Python package
    postInstall = ''
      pushd $NIX_BUILD_TOP/$sourceRoot/build/dist
      python -m pip install ./*.whl --no-index --no-warn-script-location --prefix="$out" --no-cache
      popd
    '';

    outputs = [
      "out"
      "doc"
    ];

    meta = with lib; {
      description = "";
      homepage = "https://git.iws.uni-stuttgart.de/tools/frackit";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ nialov ];
      broken = true;
    };
  };

in
self
