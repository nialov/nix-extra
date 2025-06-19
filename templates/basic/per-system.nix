(
  { inputs, ... }:

  {
    perSystem =
      {
        config,
        system,
        pkgs,
        lib,
        ...
      }:
      let
        mkNixpkgs =
          nixpkgs:
          import nixpkgs {
            inherit system;
            overlays =

              let
                localOverlay = _: prev: {
                  python-env = prev.python3.withPackages (p: lib.attrValues { inherit (p) numpy; });

                };

              in
              [
                inputs.nix-extra.overlays.default
                localOverlay
              ];
            config = {
              allowUnfree = true;
            };
          };

      in
      {
        _module.args.pkgs = mkNixpkgs inputs.nixpkgs;
        devShells = {
          default = pkgs.mkShell {
            buildInputs = lib.attrValues { inherit (pkgs) python-env; };
            shellHook =
              config.pre-commit.installationScript
              + ''
                export PROJECT_DIR="$PWD"
                # Prefix PATH with defined Python environment binaries
                export PATH="${pkgs.python-env}/bin/:$PATH"
                # Prefix PYTHONPATH with ./ and potential ./src/
                export PYTHONPATH="$PWD:$PWD/src:$PYTHONPATH"
              '';
          };

        };

        pre-commit = {
          check.enable = true;
          settings.hooks = {
            nixfmt.enable = true;
            nbstripout.enable = true;
            isort = {
              enable = true;
            };
            shellcheck.enable = true;
            statix.enable = true;
            deadnix.enable = true;
            rstcheck.enable = true;
            yamllint = {
              enable = true;
            };
            commitizen.enable = true;
            ruff = {
              enable = true;
            };
          };

        };
        legacyPackages = pkgs;
      };

  }
)
