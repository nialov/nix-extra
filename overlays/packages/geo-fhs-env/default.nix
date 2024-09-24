{ buildFHSUserEnv, fish, gdal, poetry, python39, python310, python311, cacert
, stdenv, gcc, expat, zlib, ... }:
buildFHSUserEnv {
  name = "geo-fhs-env";

  targetPkgs = _: [ fish gdal poetry python39 python310 python311 cacert gcc ];
  runScript = "bash";

  profile =

    let
      ccLib = "${stdenv.cc.cc.lib}/lib";
      zlibLib = "${zlib}/lib";
      expatLib = "${expat}/lib";
      ldPath = "${ccLib}:${zlibLib}:${expatLib}";

    in ''
      set -e
      export POETRY_VIRTUALENVS_IN_PROJECT=1
      export LD_LIBRARY_PATH="$LD_LIBRARY_PATH":"${ldPath}"
      exec fish --no-config
      set +e
    '';
}
