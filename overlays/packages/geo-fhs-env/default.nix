{ buildFHSUserEnv, lib, writeScript, ... }:
buildFHSUserEnv {
  name = "geo-fhs-env";

  targetPkgs = fhsPkgs:

    let
      pythons = builtins.map
        (python: python.withPackages (p: [ p.setuptools p.pip p.wheel ]))
        (lib.attrValues { inherit (fhsPkgs) python310 python311; });
    in lib.attrValues {
      inherit (fhsPkgs) fish poetry cacert gcc expat zlib pkg-config cmake uv;
      glibDev = fhsPkgs.glib.dev;
      libffiDev = fhsPkgs.libffi.dev;

    } ++ pythons;
  runScript = writeScript "entrypoint.sh" ''
    #!/usr/bin/env bash

    exec /usr/bin/env fish "$@"
  '';

  profile =

    # let
    #   ccLib = "${stdenv.cc.cc.lib}/lib";
    #   zlibLib = "${zlib}/lib";
    #   expatLib = "${expat}/lib";
    #   ldPath = "${ccLib}:${zlibLib}:${expatLib}";

    # in 
    # ''
    #   export POETRY_VIRTUALENVS_IN_PROJECT=1
    #   export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${ldPath}"
    # '';
    ''
      export POETRY_VIRTUALENVS_IN_PROJECT=1
      export UV_LINK_MODE=copy
      export UV_PYTHON_PREFERENCE=only-managed
    '';
}
