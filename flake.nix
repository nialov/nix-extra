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
    nixpkgs-frackit.url = "nixpkgs/nixos-21.11";
    nixpkgs-kibitzr.url =
      "github:nixos/nixpkgs/2f9fd351ec37f5d479556cd48be4ca340da59b8f";
    # TODO: Can be removed when tensorflow no longer broken
    #       https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/python-modules/tensorflow/default.nix#L453
    nixpkgs-gpt-engineer.url =
      "github:nixos/nixpkgs/d680ded26da5cf104dd2735a51e88d2d8f487b4d";
    # Use flake-utils for utility functions
    flake-utils = { url = "github:numtide/flake-utils"; };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-index-database = { url = "github:Mic92/nix-index-database"; };
    gotta-scrape-em-all = {
      url = "github:nialov/gotta-scrape-em-all";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nickel-src = {
      url = "github:tweag/nickel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doit-ext-src = {
      url = "github:nialov/doit-ext";
      flake = false;
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs-input = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mosaic-src = {
      url = "github:nialov/mosaic";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-filter.url = "github:numtide/nix-filter";
    fractopo = {
      url = "github:nialov/fractopo";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    tracerepo = {
      url = "github:nialov/tracerepo";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
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
    ytdl-sub-src = {
      url = "github:jmbannon/ytdl-sub";
      flake = false;
    };
    sphinxcontrib-mermaid-src = {
      url = "github:mgaitan/sphinxcontrib-mermaid";
      flake = false;
    };
    sphinx-gallery-src = {
      url = "github:sphinx-gallery/sphinx-gallery";
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
    # TODO: Check fix-attempt-gpt-engineer-fix branch for building newer versions
    gpt-engineer-src = {
      url =
        "github:AntonOsika/gpt-engineer/2a66dd57f6e32940b7e783ab3cd5fe6a19461d6b";
      flake = false;
    };
    frackit-src = {
      url =
        "git+https://git.iws.uni-stuttgart.de/tools/frackit?ref=feature/geodataframes-parser";
      flake = false;
    };
    pandera-src = {
      url = "github:unionai-oss/pandera";
      flake = false;
    };
    syncall-src = {
      # url = "github:bergercookier/syncall";
      # TODO: New versions use poetry_dynamic_versioning as build tool in pyproject.toml
      url =
        "git+https://github.com/bergercookie/syncall?rev=ccfeb306c5ceeee509b2aed4ae12da710e3f1b35&submodules=1";
      flake = false;
    };
    bubop-src = {
      url = "github:bergercookie/bubop";
      flake = false;
    };
    item-synchronizer-src = {
      url = "github:bergercookie/item_synchronizer";
      flake = false;
    };
    gkeepapi-src = {
      # TODO: Newer build with flit did not work. Take a look in 2024 if the package is added to nixpkgs
      url = "github:kiwiz/gkeepapi/3d91b57e44e38f964309113974cf01a190b26c39";
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
          inherit (inputs.gotta-scrape-em-all.packages."${system}")
            gotta-scrape-em-all;

          # Get deploy-rs form its repository flake
          inherit (inputs.deploy-rs-input.packages."${system}") deploy-rs;

          nickel = inputs.nickel-src.packages."${system}".build;
          # numtide/nix-filter library used for filtering local packages sources
          # filter = inputs.nix-filter.lib;
          inherit (inputs.fractopo.packages."${system}") fractopo;
          inherit (inputs.tracerepo.packages."${system}") tracerepo;
        };
      fullOverlay = lib.composeManyExtensions [
        localOverlay
        inputOverlay
        self.overlays.utils
      ];

      perSystem = inputs.flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:

        let
          mkPkgs = nixpkgs:
            import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          pkgs = mkPkgs inputs.nixpkgs;
          pkgsFrackit = mkPkgs inputs.nixpkgs-frackit;
          pkgsStable = mkPkgs inputs.nixpkgs-stable;
          pkgsGptEngineer = mkPkgs inputs.nixpkgs-gpt-engineer;
          pkgsKibitzr = mkPkgs inputs.nixpkgs-kibitzr;
          # pkgs = import inputs.nixpkgs {
          #   inherit system;
          #   overlays = [ self.overlays.default ];
          # };
          # pkgsFrackit = import inputs.nixpkgs-frackit {
          #   inherit system;
          #   overlays = [ self.overlays.default ];
          # };
          # pkgsStable = import inputs.nixpkgs-stable {
          #   inherit system;
          #   overlays = [self.overlays.default];
          # };
        in {

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
              inherit (self.checks."${system}".preCommitCheck) shellHook;
            };
            frackit-python = pkgsFrackit.mkShell {
              buildInputs = with pkgsFrackit;
                [
                  python3

                ] ++ (with pkgsFrackit.python3Packages; [
                  networkx
                  geopandas
                  jupyterlab
                  matplotlib
                  scipy
                  frackit
                ]);
            };
          };

          # Filter out packages which have meta.broken == true
          checks = let

            moduleTest = { imports, defaults ? {
              imports = builtins.attrValues self.nixosModules;
              nixpkgs.pkgs = pkgs;
            }, hostPkgs ? pkgs }:
              nixos-lib.runTest { inherit imports defaults hostPkgs; };

          in lib.foldl' lib.recursiveUpdate {
            preCommitCheck = inputs.pre-commit-hooks.lib.${system}.run
              (import ././pre-commit.nix { inherit pkgs; });
            homerModule = moduleTest { imports = [ ./nixos/tests/homer.nix ]; };
            flipperzeroModule =
              moduleTest { imports = [ ./nixos/tests/flipperzero.nix ]; };
          } [
            self.packages."${system}"
            { devShell = self.devShells."${system}".default; }
          ];

          packages = {
            inherit (pkgs)
              homer taskfzf pathnames backupper wiki-builder wsl-open-dynamic
              pretty-task ytdl-sub bootstrapSecretsScript tasklite-core rstcheck
              copier pre-commit-hook-ensure-sops deploy-rs
              clean-git-branches-script allas-cli-utils grokker
              poetry-with-c-tooling synonym-cli mosaic sync-git-tag-with-poetry
              resolve-version update-changelog pre-release poetry-run fractopo
              tracerepo syncall;
            inherit (pkgs.vimPlugins) chatgpt-nvim oil-nvim neoai-nvim cmp-ai;
            inherit (pkgs.python3Packages)
              doit-ext sphinxcontrib-mermaid sphinx-gallery pandera bubop
              item-synchronizer gkeepapi;
            inherit (pkgsFrackit) frackit;
            inherit (pkgsStable) tmuxp;
            inherit (pkgsGptEngineer) gpt-engineer;
            inherit (pkgsKibitzr) kibitzr;
          };
        });

    in lib.recursiveUpdate {
      overlays = {
        default = fullOverlay;
        # Overlay for only e.g. library utils such as filter and local packages
        # Can use this overlay instead of the default one to avoid (some) circular dependencies
        utils = lib.composeManyExtensions [
          (_: _: {
            # numtide/nix-filter library used for filtering local packages sources
            filter = inputs.nix-filter.lib;
          })
          localOverlay
        ];
      };
      nixosModules = {
        ytdl-sub = import ./nixos/modules/ytdl-sub;
        homer = import ./nixos/modules/homer;
        flipperzero = import ./nixos/modules/flipperzero.nix;
      };
    } perSystem;
}
