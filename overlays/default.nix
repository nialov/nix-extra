# final is the final product, prev is before applying this overlay
# final: prev: {
inputs: final: prev:

let

  mkNixpkgsBase = { nixpkgs, system }:
    import nixpkgs {
      inherit system;
      overlays = [ inputs.self.overlays.default ];
      config = { allowUnfree = true; };
    };

  inherit (prev) lib;

in {
  previousPackages = mkNixpkgsBase {
    inherit (prev) system;
    nixpkgs = inputs.nixpkgs-previous;
  };
  stablePackages = mkNixpkgsBase {
    inherit (prev) system;
    nixpkgs = inputs.nixpkgs-stable;
  };
  stablerPackages = mkNixpkgsBase {
    inherit (prev) system;
    nixpkgs = inputs.nixpkgs-stabler;
  };
  dfnworksPackages = mkNixpkgsBase {
    inherit (prev) system;
    nixpkgs = inputs.nixpkgs-dfnworks;
  };
  petscPackages = mkNixpkgsBase {
    inherit (prev) system;
    nixpkgs = inputs.nixpkgs-petsc;
  };
  kibitzrPackages = mkNixpkgsBase {
    inherit (prev) system;
    nixpkgs = inputs.nixpkgs-kibitzr;
  };
  gptEngineerPackages = mkNixpkgsBase {
    inherit (prev) system;
    nixpkgs = inputs.nixpkgs-gpt-engineer;
  };

  # Added to nixpkgs
  # gitmux = prev.callPackage ././packages/gitmux { };
  # homer = prev.callPackage ././packages/homer { inherit inputs; };
  taskfzf = prev.callPackage ././packages/taskfzf { inherit inputs; };
  pathnames = prev.callPackage ././packages/pathnames { };
  backupper = prev.callPackage ././packages/backupper { };
  wiki-builder = prev.callPackage ././packages/wiki-builder { };
  wsl-open-dynamic = prev.callPackage ././packages/wsl-open-dynamic { };
  pretty-task = prev.callPackage ././packages/pretty-task { };
  git-history-grep = prev.callPackage ././packages/git-history-grep { };
  nix-flake-metadata-inputs =
    prev.callPackage ././packages/nix-flake-metadata-inputs { };
  proton-ge-custom = prev.callPackage ././packages/proton-ge-custom { };
  inherit (final.python3Packages) synonym-cli kibitzr;
  allas-cli-utils =
    prev.callPackage ././packages/allas-cli-utils { inherit inputs; };
  grokker = prev.callPackage ././packages/grokker { inherit inputs; };
  poetry-with-c-tooling =
    prev.callPackage ././packages/poetry-with-c-tooling { };
  # TODO: Generate more succinctly
  python39-with-c-tooling =
    prev.callPackage ././packages/python-with-c-tooling {
      python3ToWrap = prev.python39;
    };
  python310-with-c-tooling =
    prev.callPackage ././packages/python-with-c-tooling {
      python3ToWrap = prev.python310;
    };
  python311-with-c-tooling =
    prev.callPackage ././packages/python-with-c-tooling {
      python3ToWrap = prev.python311;
    };

  gpt-engineer =
    final.callPackage ././packages/gpt-engineer { inherit inputs; };
  frackit = prev.callPackage ././packages/frackit { inherit inputs; };
  # syncall = prev.callPackage ././packages/syncall { inherit inputs; };
  lagrit = prev.callPackage ././packages/lagrit { inherit inputs; };
  dfnworks = prev.callPackage ././packages/dfnworks { inherit inputs; };
  fehm = prev.callPackage ././packages/fehm { inherit inputs; };
  pflotran = final.callPackage ././packages/pflotran { inherit inputs; };
  pkg-fblaslapack =
    prev.callPackage ././packages/pkg-fblaslapack { inherit inputs; };
  petsc = import ./packages/petsc-override.nix { inherit inputs prev final; };
  # TODO: Uses nixpkgs of a merged pull request. Can be removed soon.
  mosaic = prev.callPackage ./packages/mosaic { inherit inputs; };
  fhs = prev.callPackage ./packages/fhs/fhs.nix { };

  # hdf5-full = prev.hdf5.override {
  #   fortranSupport = true;
  #   mpiSupport = true;
  #   cppSupport = false;
  #   mpi = prev.openmpi;
  # };
  # openmpi_4_1_4_gcc11 = prev.callPackage
  #   "${inputs.lmix-flake-src.outPath}/pkgs/openmpi/default.nix" {
  #     stdenv = prev.gcc11Stdenv;
  #     gfortran = prev.gfortran11;
  #   };
  # Build with cmake
  hdf5-full = (prev.callPackage "${inputs.lmix-flake-src.outPath}/pkgs/hdf5" {
    inherit (prev) stdenv;
    mpiSupport = true;
    mpi = prev.openmpi;
    fortranSupport = true;
    fortran = prev.gfortran;
  }).overrideAttrs (_: _: { src = inputs.hdf5-src; });
  # hdf5-full =
  #   inputs.lmix-flake-src.packages."${prev.system}".hdf5_gcc11_ompi_4_1_4;
  # mpi = prev.openmpi;
  # inherit (inputs.mosaic-src.packages."${prev.system}") mosaic;
  # python3.pkgs.sphinx-design =
  #sphinx-design = prev.callPackage ././packages/sphinx-design { };
  # Overlay structure from: https://discourse.nixos.org/t/add-python-package-via-overlay/19783/3
  bootstrapSecretsScript = prev.writers.writeFishBin "bootstrap-secrets"
    ./packages/bootstrap-secrets.fish;
  clean-git-branches-script = prev.writers.writeFishBin "clean-git-branches"
    (let b = lib.getExe;
    in with prev; ''
      ${b git} branch --merged | string trim | ${
        b ripgrep
      } --invert-match 'master' | ${lib.getExe' parallel "parallel"} '${
        b git
      } branch -d {}'
    '');
  relax-pyproject-dependencies = prev.writeShellApplication {
    name = "relax-pyproject-dependencies";
    runtimeInputs = [ (prev.python3.withPackages (p: with p; [ tomlkit ])) ];
    text = ''
      python3 ${./pyproject.py} "$@"
    '';

  };

  # TODO: clog-cli-0.9.3 marked as broken as of at least 24.6.2024
  inherit (inputs.nixpkgs-fractopo.legacyPackages.x86_64-linux) clog-cli;

  # TODO: This needs to be upstreamed. After v1.2 release in main repo, pr in nixpkgs
  pre-commit-hook-ensure-sops =
    prev.pre-commit-hook-ensure-sops.overridePythonAttrs (prevAttrs: {

      src = prev.fetchFromGitHub {
        owner = "yuvipanda";
        repo = prevAttrs.pname;
        rev = "fb9c7108c6c62aaf05441daa97ace3f40e840ac3";
        hash = "sha256-CPCCNZBWzaeDfNMNI99ALzE02oM9Mfr4pyW2ag8dk7U=";
      };
      patches = [ ];
      nativeCheckInputs = with prev.python3Packages; [ pytest ];
      checkPhase = ''
        runHook preCheck
        pytest
        runHook postCheck
      '';

    });
  # Modify rstcheck to include sphinx as a buildInput
  rstcheck = prev.rstcheck.overrideAttrs (_: prevAttrs: {
    propagatedBuildInputs = prevAttrs.propagatedBuildInputs
      ++ [ prev.python3Packages.sphinx ];
  });

  sync-git-tag-with-poetry =
    prev.callPackage ./packages/sync-git-tag-with-poetry.nix { };
  resolve-version = prev.callPackage ./packages/resolve-version.nix { };
  update-changelog = prev.callPackage ./packages/update-changelog.nix { };
  update-flake = prev.callPackage ./packages/update-flake { };
  pre-release = prev.callPackage ./packages/pre-release.nix { };
  poetry-run = prev.callPackage ./packages/poetry-run.nix {
    pythons = with prev; [ python39 python310 python311 python312 python313 ];
  };
  jupytext-nb-edit = prev.callPackage ./packages/jupytext-nb-edit { };

  nbstripout =
    # TODO: Error in pytest-cram propagates to nbstripout
    prev.nbstripout.overridePythonAttrs (_: { doCheck = false; });

  template-check = prev.writeShellApplication {
    name = "template-check";
    # runtimeInputs = [ (prev.python3.withPackages (p: with p; [ tomlkit ])) ];
    text = ''
      temp_dir="$(mktemp -d)"
      pushd "$temp_dir"
      nix flake new -t ${./..} . --refresh
      nix build .#devShells.x86_64-linux.default
    '';

  };
  # nix-fast-build = inputs.nix-fast-build.packages."${prev.system}".default;

  gdal-mdb = prev.gdal.overrideAttrs (_: prevAttrs: {
    buildInputs = prevAttrs.buildInputs
      ++ [ prev.mdbtools-unixodbc prev.unixODBC ];
  });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: python-prev: {
      sphinxcontrib-mermaid =
        python-final.callPackage ././packages/sphinxcontrib-mermaid {
          inherit inputs;
        };
      # ...
      # pre-commit-hook-ensure-sops =
      #   python-final.callPackage ././packages/pre-commit-hook-ensure-sops { };
      kr-cli = python-final.callPackage ././packages/kr-cli { };
      synonym-cli =
        python-final.callPackage ././packages/synonym-cli { inherit inputs; };
      gazpacho =
        python-final.callPackage ././packages/gazpacho { inherit inputs; };
      kibitzr =
        python-final.callPackage ././packages/kibitzr { inherit inputs; };
      pandera =
        python-final.callPackage ././packages/pandera { inherit inputs; };
      sphinx-gallery = python-final.callPackage ././packages/sphinx-gallery {
        inherit inputs;
      };
      # bubop = python-final.callPackage ././packages/bubop { inherit inputs; };

      gkeepapi =
        python-final.callPackage ././packages/gkeepapi { inherit inputs; };
      doit-ext =
        python-final.callPackage ././packages/doit-ext { inherit inputs; };
      frackit = python-prev.toPythonModule
        (python-final.pkgs.frackit.override { pythonPackages = python-final; });
      powerlaw =
        python-final.callPackage ././packages/powerlaw { inherit inputs; };
      fractopo =
        python-final.callPackage ././packages/fractopo { inherit inputs; };
      tracerepo =
        python-final.callPackage ././packages/tracerepo { inherit inputs; };
      python-ternary = python-final.callPackage ././packages/python-ternary {
        inherit inputs;
      };
      mplstereonet =
        python-final.callPackage ././packages/mplstereonet { inherit inputs; };
      pyvtk = python-final.callPackage ././packages/pyvtk { inherit inputs; };
      pydfnworks =
        python-final.callPackage ././packages/dfnworks/pydfnworks.nix {
          inherit inputs;
        };
      pytest-cram =
        # TODO: Error in pytest of the package (24.6.2024):
        # ERROR . - TypeError: Can't instantiate abstract class CramItem with abstract ...
        python-prev.pytest-cram.overridePythonAttrs (_: { doCheck = false; });
      # notion-client = python-prev.notion-client.overridePythonAttrs
      #   (_: { disabledTests = [ "test_api_http_response_error" ]; });
      dask-geopandas = python-final.callPackage ././packages/dask-geopandas {
        inherit inputs;
      };
      branca =
        # TODO: Error in pytest of the package (13.3.2025):
        # > E   ModuleNotFoundError: No module named 'selenium.webdriver.common.fedcm'
        python-prev.branca.overridePythonAttrs (_: { doCheck = false; });
    })
  ];

  haskellPackages = prev.haskellPackages.override {
    overrides = self: super: {
      easyplot = null;
      huzzy =
        super.callPackage ./packages/tasklite/huzzy.nix { inherit inputs; };
      iso8601-duration = super.iso8601-duration.overrideAttrs (_: _: {
        meta.broken = false;
        postPatch = ''
          substituteInPlace iso8601-duration.cabal \
            --replace "attoparsec        >= 0.13.1 && < 0.14" "attoparsec" \
            --replace "base              >= 4.7    && < 4.12" "base" \
            --replace "bytestring        >= 0.10   && < 0.11" "bytestring" \
            --replace "time              >= 1.8    && < 1.9" "time"
          substituteInPlace src/Data/Time/ISO8601/Interval.hs \
            --replace "scientific" "AP.scientific"
        '';
      });
      simple-sql-parser = super.simple-sql-parser.overrideAttrs (_: _: {
        meta.broken = false;
        postPatch = ''
          substituteInPlace simple-sql-parser.cabal \
            --replace "tasty >= 1.1 && < 1.3" "tasty >= 1.1"
        '';

      });
      tasklite-core = self.callPackage ./packages/tasklite { inherit inputs; };

    };
  };
  tasklite-core =
    final.haskell.lib.justStaticExecutables final.haskellPackages.tasklite-core;

  nvim-nixvim =

    let
      nixvim' = inputs.nixvim.legacyPackages."${prev.system}";

      # This function takes an attribute set of the form: {pkgs,
      # extraSpecialArgs, module}. The only required argument is module, being
      # a nixvim module. This gives access to the imports, options, config
      # variables, and using functions like {config, ...}: { ... }.
    in nixvim'.makeNixvimWithModule {
      module = ./packages/nvim-nixvim;
      pkgs = prev;
      extraSpecialArgs = { inherit inputs; };
    };

  vimPlugins = prev.lib.recursiveUpdate prev.vimPlugins {
    tmux-nvim = prev.vimUtils.buildVimPlugin {
      name = "tmux-nvim";
      src = inputs.tmux-nvim-src;
      patches = [ ./tmux-nvim-sync.patch ];
    };
    # chatgpt-nvim = prev.vimUtils.buildVimPlugin {
    #   name = "chatgpt-nvim";
    #   src = inputs.chatgpt-nvim-src;
    # };
    # neoai-nvim = prev.vimUtils.buildVimPlugin {
    #   name = "neoai.nvim";
    #   src = inputs.neoai-nvim-src;
    # };
    # cmp-ai = prev.vimUtils.buildVimPlugin {
    #   name = "cmp-ai";
    #   src = inputs.cmp-ai-src;
    # };
  };

}
