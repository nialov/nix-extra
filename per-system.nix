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
        # pkgsFrackit = mkNixpkgs inputs.nixpkgs-frackit;
        pkgsStable = mkNixpkgs inputs.nixpkgs-stable;
        pkgsGptEngineer = mkNixpkgs inputs.nixpkgs-gpt-engineer;
        pkgsKibitzr = mkNixpkgs inputs.nixpkgs-kibitzr;
        pkgsFractopo = mkNixpkgs inputs.nixpkgs-fractopo;
        # pkgsDfnworks = mkNixpkgs inputs.nixpkgs-dfnworks;

      in {
        _module.args.pkgs = mkNixpkgs inputs.nixpkgs;
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              bash
              # task execution from dodo.py
              git
              nixVersions.stable
              # Formatters & linters
              pre-commit
              watchexec
            ];
            # Include pre-commit check shellHook so they can be ran with `pre-commit ...`
            shellHook = config.pre-commit.installationScript;
          };
          python39-with-c-tooling-env = pkgs.mkShell {
            buildInputs = with pkgs; [ python39-with-c-tooling ];
          };
          python310-with-c-tooling-env = pkgs.mkShell {
            buildInputs = with pkgs; [ python310-with-c-tooling ];
          };

        };
        packages = {
          inherit (pkgs)
            homer taskfzf pathnames backupper wiki-builder wsl-open-dynamic
            pretty-task ytdl-sub bootstrapSecretsScript rstcheck copier
            pre-commit-hook-ensure-sops deploy-rs clean-git-branches-script
            allas-cli-utils grokker poetry-with-c-tooling synonym-cli mosaic
            sync-git-tag-with-poetry resolve-version poetry-run tracerepo
            syncall python39-with-c-tooling python310-with-c-tooling
            python311-with-c-tooling jupytext-nb-edit template-check
            nvim-nixvim;
          inherit (pkgs.vimPlugins) neoai-nvim;
          inherit (pkgs.python3Packages)
            doit-ext sphinxcontrib-mermaid sphinx-gallery pandera bubop
            item-synchronizer gkeepapi powerlaw frackit python-ternary;
          inherit (pkgsGptEngineer) gpt-engineer;
          inherit (pkgsKibitzr) kibitzr;
          inherit (pkgsStable) lagrit dfnworks fehm pflotran petsc hdf5-full;
          inherit (pkgs.python3Packages) mplstereonet pyvtk pydfnworks;
          # TODO: How include this information of using the stable branch in an
          # overlay?
          inherit (pkgsFractopo) tasklite-core;
          # TODO: pygeos no longer in nixpkgs as it was merged to shapely 2.0
          # 19.6.2024
          inherit (pkgsFractopo.python3Packages) fractopo;
          inherit (self'.devShells) poetry-devshell;
        } //

          # Adds all pre-commit hooks from pre-commit-hooks.nix to checks
          # Should I exclude default ones and how?
          (

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
              ]) (lib.mapAttrs' (name: value:
                lib.nameValuePair name
                (pkgs.writeText "${name}-entry" value.entry))

                config.pre-commit.settings.hooks))

        ;
        checks = let

          nixos-lib = import (inputs.nixpkgs + "/nixos/lib") { };

          moduleTest = { imports, defaults ? {
            imports = builtins.attrValues self.nixosModules;
            nixpkgs.pkgs = pkgs;
          }, hostPkgs ? pkgs }:
            nixos-lib.runTest { inherit imports defaults hostPkgs; };

        in lib.foldl' lib.recursiveUpdate {
          # preCommitCheck = inputs.pre-commit-hooks.lib.${system}.run (import ././pre-commit.nix { inherit pkgs; });
          homerModule = moduleTest { imports = [ ./nixos/tests/homer.nix ]; };
          flipperzeroModule =
            moduleTest { imports = [ ./nixos/tests/flipperzero.nix ]; };
        } [ self.packages."${system}" ];

        pre-commit = {
          check.enable = true;
          settings = {
            hooks = {
              nixfmt.enable = true;
              black.enable = true;
              isort = { enable = true; };
              shellcheck.enable = true;
              statix.enable = true;
              deadnix.enable = true;
              luacheck.enable = true;
              stylua.enable = true;
              yamllint = { enable = true; };
              fish-lint = { enable = true; };
              fish-format = { enable = true; };
            };
          };

        };

        legacyPackages = pkgs;

      };

  })
