({ inputs, ... }: {
  systems = [ "x86_64-linux" ];
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  flake = { };

  # perSystem = { self', pkgs, ... }:
  perSystem = { pkgs, lib, ... }: {
    # _module.args.pkgs = lib.mkDefault (import inputs.nixpkgs {
    #   inherit system;
    #   overlays = [ self.overlays.default ];
    #   config = { };
    # });
    pre-commit = {
      check.enable = lib.mkDefault false;
      settings =

        {
          src = ./.;
          hooks =
            # let pre-commit-fish-src = inputs.pre-commit-fish-src.outPath;
            # in
            {
              isort = {
                enable = lib.mkDefault false;
                raw = { args = [ "--profile" "black" ]; };
              };
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
              fish-lint = {
                enable = lib.mkDefault false;
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
                enable = lib.mkDefault false;
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
              sync-git-tag-with-poetry = {
                enable = lib.mkDefault false;
                name = "sync-git-tag-with-poetry";
                description = "sync-git-tag-with-poetry";
                entry = ''
                  ${pkgs.sync-git-tag-with-poetry}/bin/sync-git-tag-with-poetry
                '';
                # stages = [ "push" "manual" ];
                pass_filenames = false;
              };
              trim-trailing-whitespace = {
                enable = lib.mkDefault false;

                name = "trim-trailing-whitespace";
                description = "This hook trims trailing whitespace.";
                entry =
                  "${pkgs.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
                types = [ "text" ];
              };
              check-added-large-files = {
                enable = lib.mkDefault false;
                name = "check-added-large-files";
                description = "This hook checks for large added files.";
                entry =
                  "${pkgs.python3Packages.pre-commit-hooks}/bin/check-added-large-files --maxkb=5000";
              };
              rstcheck = {
                enable = lib.mkDefault false;
                name = "rstcheck";
                description = "Check documentation with rstcheck";
                entry = "${pkgs.rstcheck}/bin/rstcheck";
                files = "\\.(rst)$";
                raw = {
                  args = [ "-r" "docs_src" "--ignore-directives" "automodule" ];
                };
              };
              cogapp = {
                enable = lib.mkDefault false;
                name = "cogapp";
                description = "Execute Python snippets in text files";
                entry = "${pkgs.python3Packages.cogapp}/bin/cog";
                files = "(README.rst|docs_src/index.rst)";
                pass_filenames = false;
                raw = {
                  args = [ "-e" "-r" "--check" "-c" "docs_src/index.rst" ];
                  always_run = true;
                };
              };
            };
        };
    };

  };
})
