{ buildFHSUserEnv, lib, appimageTools, ... }:

let

  base = appimageTools.defaultFhsEnvArgs;

  customConfig = {
    name = "fhs";

    targetPkgs = fhsPkgs:

      let
        pythons = builtins.map (python:
          python.withPackages (p: [ p.setuptools p.pip p.wheel p.virtualenv ]))
          (lib.attrValues { inherit (fhsPkgs) python310 python311 python312; });
        basePkgs = base.targetPkgs fhsPkgs;
      in lib.attrValues {
        inherit (fhsPkgs)
          fish cacert gcc pkg-config wget cmake gnumake libffi poetry
          micromamba;

      } ++ pythons ++ basePkgs;
    extraOutputsToInstall = [ "dev" ];
    runScript = ''
      bash "$@"
    '';
    profile = ''
      export POETRY_VIRTUALENVS_IN_PROJECT=1
      export MAMBA_ROOT_PREFIX=./.mamba
    '';

  };
  # Already has passthru with "args" attribute...
  # passthruConfig = {

  #   passthru.inputs = {
  #     inherit (customConfig) targetPkgs extraOutputsToInstall runScript profile;

  #   };
  # };

in buildFHSUserEnv (lib.foldl' lib.recursiveUpdate { } [ base customConfig ])
