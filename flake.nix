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
    # TODO: Failed 15.1.2024. Probably will be fixed soon.
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    tracerepo = {
      url = "github:nialov/tracerepo";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
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
    # TODO: Failing as of 14.1.2024
    grokker-src = {
      url = "github:stevegt/grokker/7e4259c3c21951e70dd7f12d6bf7ceda09af7a81";
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
    # TODO: Failing as of 14.1.2024
    item-synchronizer-src = {
      url =
        "github:bergercookie/item_synchronizer/6c8302f1c0118ab60e72030c834e8cf8ced00577";
      flake = false;
    };
    gkeepapi-src = {
      # TODO: Newer build with flit did not work. Take a look in 2024 if the package is added to nixpkgs
      url = "github:kiwiz/gkeepapi/3d91b57e44e38f964309113974cf01a190b26c39";
      flake = false;
    };
    powerlaw-src = {
      # TODO: Newer build with flit did not work. Take a look in 2024 if the package is added to nixpkgs
      url =
        "github:jeffalstott/powerlaw/6732699d790edbe27c2790bf22c3ef7355d2b07e";
      flake = false;
    };
    fractopo-src = {
      url = "github:nialov/fractopo";
      flake = false;
      # inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs:

    let
      inherit (inputs.nixpkgs) lib;

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
          inherit (inputs.tracerepo.packages."${system}") tracerepo;
        };
      fullOverlay = lib.composeManyExtensions [
        localOverlay
        inputOverlay
        self.overlays.utils
      ];

      flakePart = inputs.flake-parts.lib.mkFlake { inherit inputs; }
        ({ inputs, flake-parts-lib, ... }:
          let
            inherit (flake-parts-lib) importApply;
            flakeModules = {
              custom-pre-commit-hooks =
                importApply ./flakeModules/custom-pre-commit-hooks.nix {
                  inherit inputs;
                };
              poetryDevshell = importApply ./flakeModules/poetry-devshell.nix {
                inherit inputs;
              };
            };
          in {
            systems = [ "x86_64-linux" ];
            imports = [
              flakeModules.custom-pre-commit-hooks
              flakeModules.poetryDevshell
              ./per-system.nix
            ];

            flake = {
              overlays = {
                default = fullOverlay;
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
              templates = {
                default = {
                  path = ./templates/basic;
                  description = ''
                    A flake using nix-extra overlay with flake-parts.
                  '';
                };
              };
              inherit flakeModules;
            };

            # perSystem = { self', pkgs, ... }:
          });

    in lib.foldl' lib.recursiveUpdate { } [ flakePart ];
}
