{
  description = "My extra nixpkgs and nixos config";

  inputs = {
    # Rolling updates
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix/e96d59dff5c0d7fddb9d113ba108f03c3ef99eca";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    doit-ext-src = {
      url = "github:nialov/doit-ext";
      flake = false;
    };
    mosaic-src = {
      url = "github:nialov/mosaic";
      flake = false;
    };
    tracerepo-src = {
      url = "github:nialov/tracerepo";
      flake = false;
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    lmix-flake-src = {
      url = "github:kilzm/lmix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.flake-parts.follows = "flake-parts";
    };
    actions-nix = {
      url = "github:nialov/actions.nix";
      inputs = {
        git-hooks.follows = "git-hooks";
        flake-parts.follows = "flake-parts";
        nixpkgs.follows = "nixpkgs";
      };
    };
    sphinx-gallery-src = {
      url = "github:sphinx-gallery/sphinx-gallery";
      flake = false;
    };
    synonym-cli-src = {
      url = "github:agmmnn/synonym-cli/722b209eb6b313fa1f0ffabf54fc6c515da1d81a";
      flake = false;
    };
    gazpacho-src = {
      url = "github:maxhumber/gazpacho/7cc94880d3c967c7fb4321eee22f3cfb83615484";
      flake = false;
    };
    gazpacho-1-1-src = {
      url = "github:maxhumber/gazpacho/fddedfde9a9d5345de12cc349c5c194517965c91";
      flake = false;
    };
    tasklite-src = {
      url = "github:ad-si/tasklite/1cdded1e915de8d9c2fbd7770f948f33c507d0ce";
      flake = false;
    };
    taskfzf-src = {
      url = "gitlab:doronbehar/taskwarrior-fzf";
      flake = false;
    };
    kibitzr-src = {
      url = "github:kibitzr/kibitzr/22ee1df54c790dab8a59f356d269713c26ca0545";
      flake = false;
    };
    allas-cli-utils-src = {
      url = "github:CSCfi/allas-cli-utils";
      flake = false;
    };
    grokker-src = {
      url = "github:stevegt/grokker/7e4259c3c21951e70dd7f12d6bf7ceda09af7a81";
      flake = false;
    };
    frackit-src = {
      url = "git+https://git.iws.uni-stuttgart.de/tools/frackit?ref=feature/geodataframes-parser";
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
    pandera-src = {
      url = "github:unionai-oss/pandera/850dcf8e59632d54bc9a6df47b9ca08afa089a27";
      flake = false;
    };
    gkeepapi-src = {
      url = "github:kiwiz/gkeepapi/3d91b57e44e38f964309113974cf01a190b26c39";
      flake = false;
    };
    powerlaw-src = {
      url = "github:jeffalstott/powerlaw/6732699d790edbe27c2790bf22c3ef7355d2b07e";
      flake = false;
    };
    fractopo.url = "github:nialov/fractopo";
    python-ternary-src = {
      url = "github:marcharper/python-ternary";
      flake = false;
    };
    dask-geopandas = {
      url = "github:geopandas/dask-geopandas/f6294629e53486cb500c22b44baf05a9bfa5ee05";
      flake = false;
    };
    blink-cmp-tmux-src = {
      url = "github:mgalliou/blink-cmp-tmux";
      flake = false;
    };
    drillcore-transformations-src = {
      url = "github:nialov/drillcore-transformations";
      flake = false;
    };
    filesender-src = {
      url = "github:filesender/filesender/filesender-2.57";
      flake = false;
    };
    harper-src = {
      url = "github:automattic/harper/v1.12.0";
      flake = false;
    };
    gempy-src = {
      url = "github:gempy-project/gempy/v2026.2.0a4";
      flake = false;
    };
    gempy-engine-src = {
      url = "github:gempy-project/gempy_engine/v2026.2.0a4";
      flake = false;
    };
    gempy-viewer-src = {
      url = "github:gempy-project/gempy_viewer/v2026.0.5";
      flake = false;
    };
    subsurface-src = {
      url = "github:terranigma-solutions/subsurface/v2026.2.6post1";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ (inputs.import-tree ./modules) ];
    };
}
