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
  gpt-engineer =
    final.callPackage ././packages/gpt-engineer { inherit inputs; };
  frackit = prev.callPackage ././packages/frackit { inherit inputs; };
  syncall = prev.callPackage ././packages/syncall { inherit inputs; };
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
  pre-release = prev.callPackage ./packages/pre-release.nix { };
  poetry-run = prev.callPackage ./packages/poetry-run.nix {
    pythons = with prev; [ python39 python310 python311 ];
  };

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
      bubop = python-final.callPackage ././packages/bubop { inherit inputs; };
      item-synchronizer =
        python-final.callPackage ././packages/item-synchronizer {
          inherit inputs;
        };
      gkeepapi =
        python-final.callPackage ././packages/gkeepapi { inherit inputs; };
      doit-ext =
        python-final.callPackage ././packages/doit-ext { inherit inputs; };
      llama-index =
        python-final.callPackage ././packages/llama-index { inherit inputs; };
      inherit (final) frackit;
      # TODO: psycopg overrides can be removed after a while and test gpt-engineer build
      psycopg2 =
        python-prev.psycopg2.overridePythonAttrs (_: { doCheck = false; });
      psycopg = python-prev.psycopg.overridePythonAttrs (_: {
        doCheck = false;
        pythonImportsCheck = [ "psycopg" ];
      });
      asana = python-prev.asana.overridePythonAttrs (prevAttrs: {
        propagatedBuildInputs = prevAttrs.propagatedBuildInputs
          ++ [ python-prev.six ];
      });
      fiona = python-prev.fiona.overridePythonAttrs (prevAttrs: {
        disabledTests = prevAttrs.disabledTests ++ [ "test_issue1169" ];
      });

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
