{
  description = "My extra nixpkgs and nixos config";

  # warning: input 'flake-utils' has an override for a non-existent input 'nixpkgs'
  # warning: input 'nixos-hardware' has an override for a non-existent input 'nixpkgs'
  # warning: input 'nur' has an override for a non-existent input 'nixpkgs'
  nixConfig.extra-substituters = [ "https://nialov.cachix.org" ];
  nixConfig.extra-trusted-public-keys =
    [ "nialov.cachix.org-1:Z2oarwKpwXCZUZ6OfQx5/Ia2mEC+uizpb+c5lu/gNk4=" ];
  inputs = {
    # Use unstable nixpkgs channel
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-22.11";
    nixpkgs-kibitzr.url =
      "github:nixos/nixpkgs/2f9fd351ec37f5d479556cd48be4ca340da59b8f";
    # TODO: Remove when pr is merged.
    nixpkgs-pre-commit-hook-ensure-sops.url =
      "github:nialov/nixpkgs/6a3811938f0bb0ac439ffe44ffe6c40f374a96d6";
    # Use flake-utils for utility functions
    flake-utils = { url = "github:numtide/flake-utils"; };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-index-database = { url = "github:Mic92/nix-index-database"; };
    # TODO: When gets merged into master (and nixpkgs-unstable), can use that instead
    comma-update-flag = {
      url = "github:patricksjackson/comma/update-flag";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gotta-scrape-em-all = {
      url = "github:nialov/gotta-scrape-em-all";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nickel-src = {
      url = "github:tweag/nickel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    copier-src = { url = "github:nialov/nialov-py-template"; };
    doit-ext-src = {
      url = "github:nialov/doit-ext/refactor-remove-python-build-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs-input = { url = "github:serokell/deploy-rs"; };

    # Custom non-flake sources
    tmux-nvim-src = {
      url = "github:aserowy/tmux.nvim";
      flake = false;
    };
    cmp-tmux = {
      url = "github:andersevenrud/cmp-tmux";
      flake = false;
    };
    vim-nickel-src = {
      url = "github:nickel-lang/vim-nickel";
      flake = false;
    };
    tmux-open-src = {
      url = "github:tmux-plugins/tmux-open";
      flake = false;
    };
    chatgpt-nvim-src = {
      url = "github:nialov/ChatGPT.nvim";
      flake = false;
    };
    oil-nvim-src = {
      url = "github:stevearc/oil.nvim";
      flake = false;
    };
    ytdl-sub-src = {
      url = "github:jmbannon/ytdl-sub";
      flake = false;
    };
    sphinxcontrib-mermaid-src = {
      url = "github:mgaitan/sphinxcontrib-mermaid";
      flake = false;
    };
    synonym-cli-src = {
      url = "github:agmmnn/synonym-cli";
      flake = false;
    };
    gazpacho-src = {
      url = "github:maxhumber/gazpacho";
      flake = false;
    };
    gazpacho-1-1-src = {
      url = "github:maxhumber/gazpacho/v1.1";
      flake = false;
    };
    tasklite-src = {
      url = "github:ad-si/tasklite";
      flake = false;
    };
    taskfzf-src = {
      url = "gitlab:doronbehar/taskwarrior-fzf";
      flake = false;
    };
    kibitzr-src = {
      url = "github:kibitzr/kibitzr";
      flake = false;
    };
    homer-src = {
      url = "github:bastienwirtz/homer";
      flake = false;
    };
    allas-cli-utils-src = {
      url = "github:CSCfi/allas-cli-utils";
      flake = false;
    };
    neoai-nvim-src = {
      url = "github:Bryley/neoai.nvim";
      flake = false;
    };
    cmp-ai-src = {
      url = "github:tzachar/cmp-ai";
      flake = false;
    };
    grokker-src = {
      url = "github:stevegt/grokker";
      flake = false;
    };
    gpt-engineer-src = {
      url = "github:AntonOsika/gpt-engineer";
      flake = false;
    };
  };

  outputs = { self, ... }@inputs:

    let
      inherit (inputs.nixpkgs) lib;
      nixos-lib = import (inputs.nixpkgs + "/nixos/lib") { };
      # lib = inputs.nixpkgs.lib;

      localOverlay = import ./overlays inputs;
      inputOverlay = _: prev:
        let inherit (prev) system;
        in {

          # Some custom packages or overrides to add/fix functionality
          comma-update-flag =
            inputs.comma-update-flag.packages."${system}".comma;
          inherit (inputs.gotta-scrape-em-all.packages."${system}")
            gotta-scrape-em-all;

          # Modify rstcheck to include sphinx as a buildInput
          rstcheck = prev.rstcheck.overrideAttrs (_: prevAttrs: {
            propagatedBuildInputs = prevAttrs.propagatedBuildInputs
              ++ [ prev.python3Packages.sphinx ];
          });

          # Get copier from nialov-py-template flake
          inherit (inputs.copier-src.packages."${system}") copier;

          # Get deploy-rs form its repository flake
          inherit (inputs.deploy-rs-input.packages."${system}") deploy-rs;

          nickel = inputs.nickel-src.packages."${system}".build;
          # Use stable version of tmuxp

          inherit (inputs.nixpkgs-pre-commit-hook-ensure-sops.legacyPackages."${system}".python3Packages)
            pre-commit-hook-ensure-sops;
        };
      stableOverlay = _: prev:
        let
          inherit (prev) system;
          # pkgsStable has the local overlay added
          pkgsStable = import inputs.nixpkgs-stable {
            inherit system;
            overlays = [ localOverlay inputOverlay ];
          };
        in {

          # vimPlugins =
          # Update the unstable set with stable nvim-treesitter plugins using recursiveUpdate
          # lib.recursiveUpdate
          # Unstable vimPlugins
          # prev.vimPlugins
          # Stable nvim-treesitter from stable nixpkgs
          # { inherit (pkgsStable.vimPlugins) nvim-treesitter; };
          # Use stable version of tmuxp
          inherit (pkgsStable) tmuxp;

        };
      kibitzrOverlay = _: prev:
        let
          inherit (prev) system;
          # pkgsStable has the local overlay added
          pkgsKibitzr = import inputs.nixpkgs-kibitzr {
            inherit system;
            overlays = [ localOverlay inputOverlay ];
          };
        in { inherit (pkgsKibitzr) kibitzr; };
      fullOverlay = lib.composeManyExtensions [
        localOverlay
        inputOverlay
        stableOverlay
        kibitzrOverlay
        inputs.doit-ext-src.overlays.default
      ];

      perSystem = inputs.flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:

        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in {

          devShells.default = pkgs.mkShell {
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
            inherit (self.checks."${system}".preCommitCheck) shellHook;
          };

          # Filter out packages which have meta.broken == true
          checks = let

            moduleTest = { imports, defaults ? {
              imports = builtins.attrValues self.nixosModules;
              nixpkgs.pkgs = pkgs;
            }, hostPkgs ? pkgs }:
              nixos-lib.runTest { inherit imports defaults hostPkgs; };

          in lib.recursiveUpdate {
            preCommitCheck = inputs.pre-commit-hooks.lib.${system}.run
              (import ././pre-commit.nix { inherit pkgs; });
            homerModule = moduleTest { imports = [ ./nixos/tests/homer.nix ]; };
            flipperzeroModule =
              moduleTest { imports = [ ./nixos/tests/flipperzero.nix ]; };
          } self.packages."${system}"

          ;

          packages = {
            inherit (pkgs)
              homer taskfzf pathnames backupper wiki-builder wsl-open-dynamic
              pretty-task kibitzr ytdl-sub bootstrapSecretsScript tasklite-core
              comma-update-flag rstcheck copier tmuxp
              pre-commit-hook-ensure-sops deploy-rs clean-git-branches-script
              allas-cli-utils grokker poetry-with-c-tooling gpt-engineer
              synonym-cli;
            inherit (pkgs.vimPlugins) chatgpt-nvim oil-nvim neoai-nvim cmp-ai;
            inherit (pkgs.python3Packages) doit-ext sphinxcontrib-mermaid;
          };
        });

    in lib.recursiveUpdate {
      overlays.default = fullOverlay;
      nixosModules = {
        ytdl-sub = import ./nixos/modules/ytdl-sub;
        homer = import ./nixos/modules/homer;
        flipperzero = import ./nixos/modules/flipperzero.nix;
      };
    } perSystem;
}
