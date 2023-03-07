# final is the final product, prev is before applying this overlay
# final: prev: {
inputs: final: prev: {
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
  # TODO: move to pythonPackagesOverlays and then reference result from there
  inherit (final.python3Packages) synonym-cli kibitzr;
  ytdl-sub = prev.callPackage ././packages/ytdl-sub { inherit inputs; };
  # python3.pkgs.sphinx-design =
  #sphinx-design = prev.callPackage ././packages/sphinx-design { };
  # Overlay structure from: https://discourse.nixos.org/t/add-python-package-via-overlay/19783/3
  bootstrapSecretsScript = prev.writers.writeFishBin "bootstrap-secrets"
    ./packages/bootstrap-secrets.fish;
  pythonPackagesOverlays = (prev.pythonPackagesOverlays or [ ]) ++ [
    (python-final: _: {
      # cviz = python-final.callPackage cvizPkg { };
      # sphinx-design = python-final.callPackage ././packages/sphinx-design { };
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
    })
  ];
  python3 = let
    self = prev.python3.override {
      inherit self;
      packageOverrides =
        prev.lib.composeManyExtensions final.pythonPackagesOverlays;
    };
  in self;

  python3Packages = final.python3.pkgs;

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
  };

}
