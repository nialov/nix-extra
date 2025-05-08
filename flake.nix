{
  description = "My extra nixpkgs and nixos config";

  # warning: input 'flake-utils' has an override for a non-existent input 'nixpkgs'
  # warning: input 'nixos-hardware' has an override for a non-existent input 'nixpkgs'
  # warning: input 'nur' has an override for a non-existent input 'nixpkgs'
  nixConfig.extra-substituters = [ "https://nialov.cachix.org" ];
  nixConfig.extra-trusted-public-keys =
    [ "nialov.cachix.org-1:Z2oarwKpwXCZUZ6OfQx5/Ia2mEC+uizpb+c5lu/gNk4=" ];
  inputs = {
    # Rolling updates
    nixpkgs.url = "github:nixos/nixpkgs/3730d8a";
    nixpkgs-previous.url =
      "github:nixos/nixpkgs/d0797a04b81caeae77bcff10a9dde78bc17f5661";
    # Update follows target when releases get made
    nixpkgs-stable.follows = "nixpkgs-2411";
    nixpkgs-stabler.follows = "nixpkgs-2405";
    # Static
    nixpkgs-2411.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-2405.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-2311.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-petsc.url =
      "github:nixos/nixpkgs/27bd67e55fe09f9d68c77ff151c3e44c4f81f7de";
    nixpkgs-kibitzr.url =
      "github:nixos/nixpkgs/2f9fd351ec37f5d479556cd48be4ca340da59b8f";
    # TODO: Can be removed when tensorflow no longer broken
    #       https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/python-modules/tensorflow/default.nix#L453
    nixpkgs-gpt-engineer.url =
      "github:nixos/nixpkgs/d680ded26da5cf104dd2735a51e88d2d8f487b4d";
    nixpkgs-dfnworks.url =
      "github:nixos/nixpkgs/5efc8ca954272c4376ac929f4c5ffefcc20551d5";
    # For use with pandox-xnos and friends
    nixpkgs-pandoc = { url = "github:nixos/nixpkgs/22.05"; };
    # Use flake-utils for utility functions
    flake-utils = { url = "github:numtide/flake-utils"; };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-index-database = { url = "github:Mic92/nix-index-database"; };
    # TODO: Move nix build definition to nix-extra
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
      flake = false;
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-filter.url = "github:numtide/nix-filter";
    tracerepo-src = {
      url = "github:nialov/tracerepo";
      flake = false;
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    lmix-flake-src = {
      url = "github:kilzm/lmix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    actions-nix = {
      url = "github:nialov/actions.nix";
      inputs = {
        pre-commit-hooks.follows = "git-hooks";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
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
      # TODO: Try to fix later
      url = "github:ad-si/tasklite/1cdded1e915de8d9c2fbd7770f948f33c507d0ce";
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
    dfnworks-src = {
      url = "github:lanl/dfnworks/a76988603770e9f4ab2dfe54ad92ac50f3fcffac";
      flake = false;
    };
    lagrit-src = {
      url = "github:lanl/lagrit/48161bb7115abcdb30c58706b899f71398045024";
      flake = false;
    };
    fehm-src = {
      url = "github:lanl/fehm/5d8d8811bf283fcca0a8a2a1479f442d95371968";
      flake = false;
    };
    pflotran-src = {
      url =
        # TODO: Requires higher petsc version than came from nixpkgs 9.4.2024
        "git+https://bitbucket.org/pflotran/pflotran.git?rev=bf18794418f7646c6143ce47ed678b9c19a0246d";
      flake = false;
    };
    pkg-fblaslapack-src = {
      url = "git+https://bitbucket.org/petsc/pkg-fblaslapack.git";
      flake = false;
    };
    hdf5-src = {
      url = "github:HDFGroup/hdf5/hdf5-1_12_2";
      flake = false;
    };
    mplstereonet-src = {
      url = "github:joferkington/mplstereonet";
      flake = false;
    };
    pyvtk-src = {
      url = "github:pearu/pyvtk";
      flake = false;
    };
    # pandera-src = {
    #   # TODO: modin is not part of python3Packages as of 19.6.2024
    #   # Also: spark-submit binary is not found for some reason
    #   url = "github:unionai-oss/pandera";
    #   flake = false;
    # };
    # TODO: Tracerepo build too old to support newer pandera src
    pandera-src = {
      url =
        "github:unionai-oss/pandera/850dcf8e59632d54bc9a6df47b9ca08afa089a27";
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
    fractopo = { url = "github:nialov/fractopo"; };
    python-ternary-src = {
      url = "github:marcharper/python-ternary";
      flake = false;
    };
    nix-fast-build = {
      url = "github:Mic92/nix-fast-build";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    magazine-nvim-src = {
      url = "github:iguanacucumber/magazine.nvim";
      flake = false;
    };
    dask-geopandas = {
      url =
        "github:geopandas/dask-geopandas/f6294629e53486cb500c22b44baf05a9bfa5ee05";
      flake = false;
    };
    blink-cmp-tmux-src = {
      url = "github:mgalliou/blink-cmp-tmux";
      flake = false;
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

          # Get deploy-rs form its repository flake
          inherit (inputs.deploy-rs-input.packages."${system}") deploy-rs;

          nickel = inputs.nickel-src.packages."${system}".build;
        };
      fullOverlay = lib.composeManyExtensions [
        localOverlay
        inputOverlay
        self.overlays.utils
        inputs.fractopo.overlays.packageOverlay
      ];

      flakePart = inputs.flake-parts.lib.mkFlake { inherit inputs; }
        ({ config, inputs, flake-parts-lib, ... }:
          let
            inherit (flake-parts-lib) importApply;
            flakeModules = let
              custom-pre-commit-hooks =
                importApply ./flakeModules/custom-pre-commit-hooks.nix {
                  inherit inputs;
                };
              poetryDevshell = importApply ./flakeModules/poetry-devshell.nix {
                inherit inputs;
              };
              custom-git-hooks = custom-pre-commit-hooks;
            in {
              inherit custom-pre-commit-hooks poetryDevshell custom-git-hooks;
            };
          in {
            systems = [ "x86_64-linux" ];
            imports = [
              flakeModules.custom-git-hooks
              flakeModules.poetryDevshell
              ./per-system.nix
              inputs.actions-nix.flakeModules.default
              ./nix/actions-nix.nix
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
              nixosModules = { };
              templates = {
                default = {
                  path = ./templates/basic;
                  description = ''
                    A flake using nix-extra overlay with flake-parts.
                  '';
                };
              };
              inherit flakeModules;
              flakePartsConfig = config;
            };

          });

    in lib.foldl' lib.recursiveUpdate { } [ flakePart ];
}
