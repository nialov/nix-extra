{ inputs, lib, stdenv, python3, lagrit, fehm, pflotran }:

let

  dfnworks-base = stdenv.mkDerivation rec {
    pname = "dfnworks-base";
    version = "unstable";

    src = inputs.dfnworks-src;

    buildInputs = [
      (python3.withPackages (p: with p; [ pybind11 wheel pip setuptools ]))
      lagrit
      fehm
      pflotran
    ];

    # Install as Python package
    postInstall = let pythonVersion = lib.versions.majorMinor python3.version;
    in ''
      mkdir -p $out/lib/python${pythonVersion}/site-packages
      python3 -m pip install ./pydfnworks --target $out/lib/python${pythonVersion}/site-packages
    '';

    meta = with lib; {
      description = "";
      homepage = "https://dfnworks.lanl.gov/";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ nialov ];
    };
  };

in dfnworks-base
