{ buildFHSUserEnv, lib, writeScript, ... }:
buildFHSUserEnv {
  name = "micromamba-fhs-env";

  targetPkgs = fhsPkgs: lib.attrValues { inherit (fhsPkgs) micromamba; };
  runScript = writeScript "entrypoint.sh" ''
    #!/usr/bin/env bash

    exec /usr/bin/env fish $@
  '';

  profile = ''
    export MAMBA_ROOT_PREFIX=./.mamba
  '';
}
