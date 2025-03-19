({ self, inputs, ... }:

  {
    perSystem = { config, system, pkgs, lib, self', ... }:
      let
        mkNixpkgs = nixpkgs:
          import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
            config = { allowUnfree = true; };
          };

      in {
        _module.args.pkgs = mkNixpkgs inputs.nixpkgs;
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              bash
              # task execution from dodo.py
              git
              # Formatters & linters
              pre-commit
              watchexec
            ];
            # Include pre-commit check shellHook so they can be ran with `pre-commit ...`
            shellHook = config.pre-commit.installationScript;
          };

        };
        packages = {
          inherit (pkgs)
            taskfzf pathnames backupper wiki-builder wsl-open-dynamic
            pretty-task bootstrapSecretsScript rstcheck copier
            pre-commit-hook-ensure-sops deploy-rs git-branch-clean
            allas-cli-utils grokker poetry-with-c-tooling synonym-cli mosaic
            sync-git-tag-with-poetry resolve-version poetry-run
            python39-with-c-tooling python310-with-c-tooling
            python311-with-c-tooling jupytext-nb-edit template-check nvim-nixvim
            git-history-grep gdal update-flake fhs fhs-no-ld;
          inherit (pkgs.python3Packages)
            doit-ext sphinxcontrib-mermaid sphinx-gallery item-synchronizer
            gkeepapi powerlaw frackit python-ternary mplstereonet pyvtk;
          inherit (pkgs.gptEngineerPackages) gpt-engineer;
          inherit (pkgs.kibitzrPackages) kibitzr;
          # TODO: How include this information of using the stable branch in an
          # overlay?
          inherit (pkgs.stablerPackages)
            tasklite-core lagrit dfnworks fehm pflotran petsc hdf5-full openmpi;
          # TODO: Need to be updated upstream for numpy 2
          inherit (pkgs.previousPackages.python3Packages)
            fractopo tracerepo pandera;
          # fractopo-documentation =
          #   pkgs.python3Packages.fractopo.passthru.documentation.doc;
          inherit (pkgs.stablerPackages.python3Packages) pydfnworks;
          # inherit (pkgs.pandocPackages) pandoc-wrapped;
          inherit (self'.devShells) poetry-devshell;
        } //

          # Adds all pre-commit hooks from pre-commit-hooks.nix to checks
          # Should I exclude default ones and how?
          (let

            excludeOption =
              # TODO: Make exclude smarter. E.g. make perSystem option where I define my own hooks
              # Or mark them in the definition for testing
              lib.filterAttrs (n: _:
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
                ]) (lib.mapAttrs' (name: value:
                  lib.nameValuePair name
                  (pkgs.writeText "${name}-entry" value.entry))

                  config.pre-commit.settings.hooks);

            # Custom pre-commit are not enabled by default so
            # they do not get added by this:
            # enableCheckOption = lib.mapAttrs' (name: value:
            #   lib.nameValuePair name
            #   (pkgs.writeText "${name}-entry" value.entry))

            #   builtins.filterAttrs (name: value: value.enable)
            #   config.pre-commit.settings.hooks

            # ;

          in excludeOption)

        ;
        checks = self.packages."${system}";
        # let

        #   nixos-lib = import (inputs.nixpkgs + "/nixos/lib") { };

        #   moduleTest = { imports, defaults ? {
        #     imports = builtins.attrValues self.nixosModules;
        #     nixpkgs.pkgs = pkgs;
        #   }, hostPkgs ? pkgs }:
        #     nixos-lib.runTest { inherit imports defaults hostPkgs; };

        # in lib.foldl' lib.recursiveUpdate {
        #   # preCommitCheck = inputs.pre-commit-hooks.lib.${system}.run (import ././pre-commit.nix { inherit pkgs; });
        #   # homerModule = moduleTest { imports = [ ./nixos/tests/homer.nix ]; };
        # } ;

        pre-commit = {
          check.enable = true;
          settings = {
            hooks = {
              nixfmt.enable = true;
              ruff.enable = true;
              ruff-format = { enable = true; };
              shellcheck.enable = true;
              statix.enable = true;
              deadnix.enable = true;
              luacheck.enable = true;
              stylua.enable = true;
              yamllint = { enable = true; };
              fish-lint = { enable = true; };
              fish-format = { enable = true; };
              shfmt = { enable = true; };
            };
          };

        };

        legacyPackages = pkgs;

      };

  })
