{ buildFHSUserEnv, micromamba, ... }:
buildFHSUserEnv {
  name = "micromamba-fhs-env";

  targetPkgs = _: [ micromamba ];
  runScript = "bash";

  profile = ''
    set -e
    export MAMBA_ROOT_PREFIX=./.mamba
    exec fish --no-config
    set +e
  '';
}
