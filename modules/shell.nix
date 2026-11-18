{
  perSystem =
    { config, pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        buildInputs =
          with pkgs;
          [
            bash
            # task execution from dodo.py
            git
            # Formatters & linters
            # pre-commit - removed, now added via enabledHookPackages
            watchexec
            ruff
            shellcheck
            nixfmt
          ]
          ++ config.pre-commit.enabledHookPackages;
        # Include pre-commit check shellHook so they can be ran with `pre-commit ...`
        shellHook = config.pre-commit.installationScript;
      };
    };
}
