{ pkgs }:
let

  inherit (pkgs) lib;
in {
  src = ./.;
  hooks =
    # let pre-commit-fish-src = inputs.pre-commit-fish-src.outPath;
    # in
    {
      nixfmt.enable = true;
      black.enable = true;
      isort = {
        enable = true;
        raw = { args = [ "--profile" "black" ]; };
      };
      shellcheck.enable = true;
      statix.enable = true;
      deadnix.enable = true;
      luacheck.enable = true;
      stylua.enable = true;
      detect-secrets = {
        enable = lib.mkDefault false;
        name = "detect-secrets";
        entry =
          "${pkgs.python3Packages.detect-secrets}/bin/detect-secrets-hook";
        files = ".*";
        raw = { args = [ "--baseline" ".secrets.baseline" ]; };
      };
      # commitizen = {
      # enable = true;
      # name = "commitizen";
      # entry = "${pkgs.commitizen}/bin/cz check --commit-msg-file";
      # stages = [ "commit-msg" ];
      # };
      yamllint = {
        enable = true;
        excludes = [ "^secrets/" ];
      };
      fish-lint = {
        enable = true;
        name = "fish-lint";
        entry =
          # let
          #   script =
          #     "${pre-commit-fish-src}/pre-commit-hooks/fish_indent_lint.fish";
          # in 
          ''
            ${pkgs.fish}/bin/fish_indent --check
          '';
        files = "\\.(fish)$";
      };
      fish-format = {
        enable = true;
        name = "fish-format";
        entry =
          # let
          #   script =
          #     "${pre-commit-fish-src}/pre-commit-hooks/fish_indent_format.fish";
          # in
          ''
            ${pkgs.fish}/bin/fish_indent --write
          '';
        files = "\\.(fish)$";
      };
      pre-commit-hook-ensure-sops = {
        enable = lib.mkDefault false;
        name = "pre-commit-hook-ensure-sops";
        entry = ''
          ${pkgs.pre-commit-hook-ensure-sops}/bin/pre-commit-hook-ensure-sops
        '';
        files = "^secrets/";
      };
      nbstripout = {
        enable = lib.mkDefault false;
        name = "nbstripout";
        description = "Strip output from Jupyter notebooks";
        entry = "${pkgs.nbstripout}/bin/nbstripout";
        files = "\\.(ipynb)$";
      };
    };
}
