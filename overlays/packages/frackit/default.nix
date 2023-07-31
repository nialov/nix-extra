{ inputs, lib, stdenv, cmake, python3, opencascade-occt, ... }:

let

  frackit-base = stdenv.mkDerivation rec {
    pname = "frackit-base";
    version = "unstable";

    src = inputs.frackit-src;

    # TODO: Can enable all tests, just used to speed up builds currently
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

    # postFixup = ''
    #   ls -la
    #   cp -r appl $out/appl
    #   cp -r python $out/python
    #   cp -r frackit $out/frackit
    # '';

    # Install as Python package
    postInstall = let pythonVersion = lib.versions.majorMinor python3.version;
    in ''
      mkdir -p $out/lib/python${pythonVersion}/site-packages
      python3 -m pip install ./python --target $out/lib/python${pythonVersion}/site-packages
      # cp -r ./python/frackit $out/lib/python${pythonVersion}/site-packages/
    '';

    meta = with lib; {
      description = "";
      homepage = "https://git.iws.uni-stuttgart.de/tools/frackit";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ nialov ];
    };
  };

in frackit-base
