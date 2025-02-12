{ buildFHSEnv, lib, appimageTools, ... }:

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
        extraPkgs = lib.attrValues {
          inherit (fhsPkgs)
            fish cacert gcc pkg-config wget openmpi mpich cmake gnumake libffi
            poetry uv micromamba;
        };
      in extraPkgs ++ pythons ++ basePkgs;
    extraOutputsToInstall = [ "dev" ];
    runScript = ''
      bash "$@"
    '';
    profile = ''
      export POETRY_VIRTUALENVS_IN_PROJECT=1
      export MAMBA_ROOT_PREFIX=./.mamba
      export UV_LINK_MODE=copy
      export UV_PYTHON_PREFERENCE=only-managed
    '';

  };

in buildFHSEnv (lib.foldl' lib.recursiveUpdate { } [ base customConfig ])
