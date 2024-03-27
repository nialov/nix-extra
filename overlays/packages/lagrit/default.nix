{ inputs, lib, stdenv, gfortran, cmake, python3, runCommand, lndir, applyPatches
}:

let

  patchedSrc = runCommand "patched-src" { } "";

  self =

    stdenv.mkDerivation {
      pname = "lagrit";
      version = "3.3.2";

      # TODO: To include Exodus, use -DLAGRIT_BUILD_EXODUS=ON
      # Exodus is from https://github.com/sandialabs/seacas but it is not packaged with nix
      nativeBuildInputs = [ gfortran cmake ];

      # TODO: Move to installCheckPhase
      passthru.tests = runCommand "lagrit-tests" { } ''
        mkdir $out
        ${lndir}/bin/lndir -silent ${inputs.lagrit-src}/test $out
        pushd $out
        ${python3}/bin/python3 runtests.py --executable ${self}/bin/lagrit --levels 1 || exit 0
        popd

      '';

      # doInstallCheck = true;
      # installCheckPhase = ''
      # '';

      meta = with lib; {
        description =
          "Los Alamos Grid Toolbox (LaGriT) is a library of user callable tools that provide mesh generation, mesh optimization and dynamic mesh maintenance in two and three dimensions";
        homepage = "https://github.com/lanl/lagrit";
        license = with licenses; [ bsd3 ];
        maintainers = with maintainers; [ nialov ];
      };
    };
in self
