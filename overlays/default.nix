# final is the final product, prev is before applying this overlay
# final: prev: {
inputs: final: prev:

# let inherit (prev) system; in 
{
  # Added to nixpkgs
  # gitmux = prev.callPackage ././packages/gitmux { };
  homer = prev.callPackage ././packages/homer { inherit inputs; };
  taskfzf = prev.callPackage ././packages/taskfzf { inherit inputs; };
  pathnames = prev.callPackage ././packages/pathnames { };
  backupper = prev.callPackage ././packages/backupper { };
  wiki-builder = prev.callPackage ././packages/wiki-builder { };
  wsl-open-dynamic = prev.callPackage ././packages/wsl-open-dynamic { };
  pretty-task = prev.callPackage ././packages/pretty-task { };
  proton-ge-custom = prev.callPackage ././packages/proton-ge-custom { };
  inherit (final.python3Packages) synonym-cli kibitzr;
  ytdl-sub = prev.callPackage ././packages/ytdl-sub { inherit inputs; };
  allas-cli-utils =
    prev.callPackage ././packages/allas-cli-utils { inherit inputs; };
  grokker = prev.callPackage ././packages/grokker { inherit inputs; };
  poetry-with-c-tooling =
    prev.callPackage ././packages/poetry-with-c-tooling { };
  gpt-engineer = prev.callPackage ././packages/gpt-engineer { inherit inputs; };
  frackit = prev.callPackage ././packages/frackit { inherit inputs; };
  lagrit = prev.callPackage ././packages/lagrit { inherit inputs; };
  dfnworks = prev.callPackage ././packages/dfnworks { inherit inputs; };
  fehm = prev.callPackage ././packages/fehm { inherit inputs; };
  pflotran = final.callPackage ././packages/pflotran { inherit inputs; };
  pkg-fblaslapack =
    prev.callPackage ././packages/pkg-fblaslapack { inherit inputs; };
  petsc = let
    petscStable = inputs.nixpkgs-petsc.legacyPackages."${prev.system}".petsc;
    petscStableMpi = petscStable.override { inherit (final) mpi; };
  in petscStableMpi.overrideAttrs (_: prevAttrs: {
    buildInputs = prevAttrs.buildInputs
      ++ [ prev.metis final.hdf5-full prev.zlib prev.parmetis ];
    # RUN ./configure --CFLAGS='-O3' --CXXFLAGS='-O3' --FFLAGS='-O3' --with-debugging=no --download-mpich=yes --download-hdf5=yes --download-hdf5-fortran-bindings=yes --download-fblaslapack=yes --download-metis=yes --download-parmetis=yes
    # make PETSC_DIR=/build/petsc-3.19.2 PETSC_ARCH=arch-linux-c-opt all
    # export FC="${prev.gfortran}/bin/gfortran" F77="${prev.gfortran}/bin/gfortran"
    preConfigure = ''
      patchShebangs ./lib/petsc/bin
    '';
    configureFlags = [
      "F77=${prev.gfortran}/bin/gfortran"
      "AR=${prev.gfortran}/bin/ar"
      "CC=${prev.openmpi}/bin/mpicc"
      "--with-hdf5=1"
      "--with-hdf5-fortran-bindings=1"
      "--CFLAGS='-O3'"
      "--CXXFLAGS='-O3'"
      "--FFLAGS='-O3'"
      "--with-debugging=no"
      "--with-metis=1"
      # "--with-fblaslapack=1"
      # "--with-hdf5-include=${prev.hdf5-fortran.dev.outPath}/include"
      # "--with-hdf5-lib=-L${prev.hdf5-fortran.out.outPath}/lib -lz"
      # "--with-mpi=0"
      # '' else ''
      # "--CC=mpicc"
      "--with-cxx=mpicxx"
      "--with-fc=mpif90"
      "--with-mpi=1"
      "--with-zlib=1"
      # ''}
      # ${if withp4est then ''
      "--with-p4est=1"
      # "--with-zlib-include=${prev.zlib.dev}/include"
      # "--with-zlib-lib=-L${prev.zlib}/lib -lz"
      "--with-blas=1"
      "--with-lapack=1"
      "--with-parmetis=1"
    ];
    # postPatch = ''
    #   substituteInPlace config/BuildSystem/config/base.py \
    #     --replace "return not (returnCode or len(output))" \
    #     "return True"
    # '';
    doCheck = false;
    mpiSupport = true;
    makeFlags = [ "PETSC_ARCH=arch-linux-c-opt" ];
    # NIX_DEBUG = 1;
    # TODO: Only for debugging
    nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [ prev.breakpointHook ];
  });
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
  hdf5-full = (prev.callPackage "${inputs.lmix-flake-src.outPath}/pkgs/HDF5" {
    inherit (prev) stdenv;
    mpiSupport = true;
    mpi = prev.openmpi;
    fortranSupport = true;
    fortran = prev.gfortran;
  }).overrideAttrs (_: _: { src = inputs.hdf5-src; });
  # hdf5-full =
  #   inputs.lmix-flake-src.packages."${prev.system}".hdf5_gcc11_ompi_4_1_4;
  # mpi = prev.openmpi;
  inherit (inputs.mosaic-src.packages."${prev.system}") mosaic;
  # python3.pkgs.sphinx-design =
  #sphinx-design = prev.callPackage ././packages/sphinx-design { };
  # Overlay structure from: https://discourse.nixos.org/t/add-python-package-via-overlay/19783/3
  bootstrapSecretsScript = prev.writers.writeFishBin "bootstrap-secrets"
    ./packages/bootstrap-secrets.fish;
  clean-git-branches-script = prev.writers.writeFishBin "clean-git-branches"
    (let b = prev.lib.getExe;
    in with prev; ''
      ${b git} branch --merged | string trim | ${
        b ripgrep
      } --invert-match 'master' | ${b parallel} '${b git} branch -d {}'
    '');

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (python-final: _: {
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
      sphinx-gallery = python-final.callPackage ././packages/sphinx-gallery {
        inherit inputs;
      };
      inherit (final) frackit;
      mplstereonet =
        python-final.callPackage ././packages/mplstereonet { inherit inputs; };
      pyvtk = python-final.callPackage ././packages/pyvtk { inherit inputs; };
      pydfnworks =
        python-final.callPackage ././packages/dfnworks/pydfnworks.nix {
          inherit inputs;
        };

    })
  ];

  haskellPackages = prev.haskellPackages.override {
    overrides = self: super: {
      easyplot = null;
      huzzy =
        super.callPackage ./packages/tasklite/huzzy.nix { inherit inputs; };
      # tasty = super.tasty.overrideAttrs (finalAttrs: prevAttrs: {
      #   version
      # });
      # easyplot = super.easyplot.overrideAttrs (finalAttrs: prevAttrs: {
      #   broken = false;
      #   meta.broken = false;
      # });
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

  vimPlugins = prev.lib.recursiveUpdate prev.vimPlugins {
    tmux-nvim = prev.vimUtils.buildVimPlugin {
      name = "tmux-nvim";
      src = inputs.tmux-nvim-src;
      patches = [ ./tmux-nvim-sync.patch ];
    };
    chatgpt-nvim = prev.vimUtils.buildVimPlugin {
      name = "chatgpt-nvim";
      src = inputs.chatgpt-nvim-src;
    };
    oil-nvim = prev.vimUtils.buildVimPlugin {
      name = "oil.nvim";
      src = inputs.oil-nvim-src;
    };
    neoai-nvim = prev.vimUtils.buildVimPlugin {
      name = "neoai.nvim";
      src = inputs.neoai-nvim-src;
    };
    cmp-ai = prev.vimUtils.buildVimPlugin {
      name = "cmp-ai";
      src = inputs.cmp-ai-src;
    };
  };

}
