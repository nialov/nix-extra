(_: {
  systems = [ "x86_64-linux" ];

  perSystem = { config, pkgs, ... }:
    let

      inherit (pkgs) lib;

    in {

      devShells = {
        poetry-devshell = pkgs.mkShell {
          buildInputs = with pkgs; [
            pre-commit
            pandoc
            poetry-with-c-tooling
            # Supported python versions
            python38
            python39
            python310
            python311
            python312
          ];
          # Include pre-commit check shellHook so they can be ran with `pre-commit ...`
          shellHook = lib.optionalString config.pre-commit.check.enable
            config.pre-commit.installationScript;
        };
      };

    };
})
