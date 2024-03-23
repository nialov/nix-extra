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
            pretty-task ytdl-sub bootstrapSecretsScript tasklite-core rstcheck
            copier pre-commit-hook-ensure-sops deploy-rs
            clean-git-branches-script allas-cli-utils grokker
            poetry-with-c-tooling synonym-cli mosaic sync-git-tag-with-poetry
            resolve-version update-changelog pre-release poetry-run tracerepo
            syncall python39-with-c-tooling python310-with-c-tooling
            python311-with-c-tooling jupytext-nb-edit

          ;
          inherit (pkgs.vimPlugins) chatgpt-nvim oil-nvim neoai-nvim cmp-ai;
          inherit (pkgs.python3Packages)
            doit-ext sphinxcontrib-mermaid sphinx-gallery pandera bubop
            item-synchronizer gkeepapi powerlaw fractopo frackit python-ternary;
          inherit (pkgsStable) tmuxp;
          inherit (pkgsGptEngineer) gpt-engineer;
          inherit (pkgsKibitzr) kibitzr;
          inherit (self'.devShells) poetry-devshell;
        };
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
        } [
          self.packages."${system}"
          # { devShell = self.devShells."${system}".default; }
        ];

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

      };

  })
