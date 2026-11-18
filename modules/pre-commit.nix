{
  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      checks =
        # Adds selected pre-commit hooks from git-hooks.nix to checks.
        lib.filterAttrs
          (
            name: _:
            builtins.elem name [
              "nbstripout"
              "black-nb"
              "cogapp"
              "rstcheck"
              "check-added-large-files"
              "trim-trailing-whitespace"
              "detect-secrets"
              "sqlfluff-lint"
              "sqlfluff-fix"
              "ruff"
              "no-pushes-to-branch"
            ]
          )
          (
            lib.mapAttrs' (
              name: value: lib.nameValuePair name (pkgs.writeText "${name}-entry" value.entry)
            ) config.pre-commit.settings.hooks
          );

      pre-commit = {
        check.enable = true;
        settings.hooks = {
          ruff.enable = true;
          treefmt.enable = true;
          treefmt.settings.formatters = [ config.treefmt.build.wrapper ];
          shellcheck.enable = true;
          statix.enable = false;
          deadnix.enable = true;
          luacheck.enable = true;
          yamllint.enable = true;
          fish-lint.enable = true;
        };
      };
    };
}
