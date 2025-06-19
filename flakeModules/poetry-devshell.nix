(_: {
  systems = [ "x86_64-linux" ];

  perSystem =
    { config, pkgs, ... }:
    let

      inherit (pkgs) lib;

    in
    {

      devShells = {
        poetry-devshell = pkgs.mkShell {
          buildInputs = with pkgs; [
            pre-commit
            pandoc
            poetry-run
          ];
          # Include pre-commit check shellHook so they can be ran with `pre-commit ...`
          shellHook = lib.optionalString config.pre-commit.check.enable config.pre-commit.installationScript;
        };
      };

    };
})
