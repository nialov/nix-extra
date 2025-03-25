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
  lagrit = prev.callPackage ././packages/lagrit { inherit inputs; };
  dfnworks = prev.callPackage ././packages/dfnworks { inherit inputs; };
  fehm = prev.callPackage ././packages/fehm { inherit inputs; };
  pflotran = final.callPackage ././packages/pflotran { inherit inputs; };
  pkg-fblaslapack =
    prev.callPackage ././packages/pkg-fblaslapack { inherit inputs; };
  petsc = import ./packages/petsc-override.nix { inherit inputs prev final; };
  mosaic = prev.callPackage ./packages/mosaic { inherit inputs; };
  fhs = prev.callPackage ./packages/fhs.nix { };
  fhs-no-ld = final.fhs.override { ldLibraryEnv = false; };

  # Build with cmake
  hdf5-full = (prev.callPackage "${inputs.lmix-flake-src.outPath}/pkgs/hdf5" {
    inherit (prev) stdenv;
    mpiSupport = true;
    mpi = prev.openmpi;
    fortranSupport = true;
    fortran = prev.gfortran;
  }).overrideAttrs (_: _: { src = inputs.hdf5-src; });
  bootstrapSecretsScript = prev.writers.writeFishBin "bootstrap-secrets"
    ./packages/bootstrap-secrets.fish;
  git-branch-clean = prev.writers.writeFishBin "git-branch-clean" (let
    b = lib.getExe;
    gitExe = b prev.git;
    ripgrepExe = b prev.ripgrep;
    parallelExe = lib.getExe' prev.parallel "parallel";
  in lib.concatStringsSep " | "

  [
    "${gitExe} branch --merged"
    "string trim"
    "${ripgrepExe} --invert-match 'master'"
    "${parallelExe} '${gitExe} branch -d {}'"
  ]

  );

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
  update-flake = prev.callPackage ./packages/update-flake { };
  pre-release = prev.callPackage ./packages/pre-release { };
  poetry-run = prev.callPackage ./packages/poetry-run.nix {
    pythons = with prev; [ python39 python310 python311 python312 python313 ];
  };
  jupytext-nb-edit = prev.callPackage ./packages/jupytext-nb-edit { };

  template-check = prev.writeShellApplication {
    name = "template-check";
    text = ''
      temp_dir="$(mktemp -d)"
      pushd "$temp_dir"
      nix flake new -t ${./..} . --refresh
      nix build .#devShells.x86_64-linux.default
    '';

  };

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
      # fractopo =
      #   python-final.callPackage ././packages/fractopo { inherit inputs; };
      # TODO: Update pandera for numpy 2
      # python-final.callPackage ././packages/tracerepo { inherit inputs; };
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
      # pytest-cram =
      # TODO: Error in pytest of the package (24.6.2024):
      # ERROR . - TypeError: Can't instantiate abstract class CramItem with abstract ...
      #        error: pytest-cram-0.2.2 not supported for interpreter python3.12
      # Used by current pandera version, 
      # python-prev.pytest-cram.overridePythonAttrs (_: { doCheck = false; });
      dask-geopandas = python-final.callPackage ././packages/dask-geopandas {
        inherit inputs;
      };
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
  };

  tracerepo = prev.python3Packages.toPythonApplication
    inputs.nix-extra-tracerepo.packages."${prev.system}".tracerepo;

}
