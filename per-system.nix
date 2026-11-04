(
  { self, inputs, ... }:

  {
    imports = [ ./nix/tests ];
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
            overlays = [ self.overlays.default ];
            config = {
              allowUnfree = true;
            };
          };

      in
      {
        _module.args.pkgs = mkNixpkgs inputs.nixpkgs;
        devShells = {
          default = pkgs.mkShell {
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
        packages = {
          inherit (pkgs)
            taskfzf
            backupper
            wiki-builder
            wsl-open-dynamic
            pretty-task
            bootstrapSecretsScript
            rstcheck
            copier
            pre-commit-hook-ensure-sops
            deploy-rs
            git-branch-clean
            allas-cli-utils
            grokker
            poetry-with-c-tooling
            # synonym-cli
            mosaic
            sync-git-tag-with-poetry
            resolve-version
            poetry-run
            python311-with-c-tooling
            python312-with-c-tooling
            python313-with-c-tooling
            jupytext-nb-edit
            template-check
            nvim-nixvim

            gdal
            fhs
            fhs-no-ld
            nix-flake-remote-eval-and-build
            flowmark
            ;
          inherit (pkgs.python3Packages)
            doit-ext
            sphinxcontrib-mermaid
            sphinx-gallery
            # item-synchronizer
            powerlaw
            python-ternary
            mplstereonet
            pyvtk
            drillcore-transformations
            # TODO: fractopo needs update upstream
            # fractopo

            # TODO: Update pandera for numpy 2
            # tracerepo pandera
            ;
          # inherit (pkgs.gptEngineerPackages) gpt-engineer;
          # inherit (pkgs.kibitzrPackages) kibitzr;
          # inherit (pkgs.release2405Packages) frackit;
          # inherit (pkgs.release2311Packages)
          #   # tasklite-core
          #   lagrit
          #   dfnworks
          #   fehm
          #   pflotran
          #   petsc
          #   hdf5-full
          #   openmpi
          #   ;
          # inherit (pkgs.release2311Packages.python3Packages)
          #   pydfnworks
          #   # gkeepapi
          #   ;
          # inherit (pkgs.tracerepoPackages) tracerepo;
        }
        //

          # Adds all pre-commit hooks from git-hooks.nix to checks
          # Should I exclude default ones and how?
          (
            let

              excludeOption =
                # TODO: Make exclude smarter. E.g. make perSystem option where I define my own hooks
                # Or mark them in the definition for testing
                lib.filterAttrs
                  (
                    n: _:
                    builtins.elem n
                      # List of pre-commit hook entries that I want to check
                      # I.e. it tests the package build
                      [
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
                    lib.mapAttrs' (name: value: lib.nameValuePair name (pkgs.writeText "${name}-entry" value.entry))

                      config.pre-commit.settings.hooks
                  );

            in
            excludeOption
          )

        ;
        checks = self.packages."${system}";

        treefmt = {
          projectRoot = self;
          programs.nixfmt.enable = true;
          programs.ruff-format.enable = true;
          programs.stylua.enable = true;
          programs.shfmt = {
            enable = true;
            indent_size = 2;
          };
          programs.fish_indent.enable = true;
        };

        pre-commit = {
          check.enable = true;
          settings = {
            hooks = {
              ruff.enable = true;
              treefmt.enable = true;
              treefmt.settings.formatters = [
                config.treefmt.build.wrapper
              ];
              shellcheck.enable = true;
              statix.enable = false;
              deadnix.enable = true;
              luacheck.enable = true;
              yamllint = {
                enable = true;
              };
              fish-lint = {
                enable = true;
              };
            };
          };

        };

        legacyPackages = pkgs;

      };

  }
)
