{ self, ... }:
{
  perSystem =
    {
      system,
      pkgs,
      lib,
      ...
    }:
    {
      packages = {
        inherit (pkgs)
          taskfzf
          backupper
          wiki-builder
          wsl-open-dynamic
          pretty-task
          bootstrapSecretsScript
          copier
          rstcheck
          pre-commit-hook-ensure-sops
          git-branch-clean
          allas-cli-utils
          grokker
          poetry-with-c-tooling
          # synonym-cli
          mosaic
          sync-git-tag-with-poetry
          resolve-version
          poetry-run
          python311-with-c-tooling
          python312-with-c-tooling
          python313-with-c-tooling
          jupytext-nb-edit
          template-check
          nvim-nixvim

          gdal
          fhs
          fhs-no-ld
          nix-flake-remote-eval-and-build
          flowmark
          ;
        inherit (pkgs.python3Packages)
          doit-ext
          sphinxcontrib-mermaid
          sphinx-gallery
          # item-synchronizer
          powerlaw
          python-ternary
          mplstereonet
          pyvtk
          drillcore-transformations
          gempy
          # TODO: fractopo needs update upstream
          # fractopo

          # TODO: Update pandera for numpy 2
          # tracerepo pandera
          ;
        # inherit (pkgs.gptEngineerPackages) gpt-engineer;
        # inherit (pkgs.kibitzrPackages) kibitzr;
        # inherit (pkgs.release2405Packages) frackit;
        # inherit (pkgs.release2311Packages)
        #   # tasklite-core
        #   lagrit
        #   dfnworks
        #   fehm
        #   pflotran
        #   petsc
        #   hdf5-full
        #   openmpi
        #   ;
        # inherit (pkgs.release2311Packages.python3Packages)
        #   pydfnworks
        #   # gkeepapi
        #   ;
        # inherit (pkgs.tracerepoPackages) tracerepo;
      };
      checks = lib.filterAttrs (
        name: _:
        !(builtins.elem name [
          "nbstripout"
          "black-nb"
          "cogapp"
          "rstcheck"
          "check-added-large-files"
          "trim-trailing-whitespace"
          "detect-secrets"
          "sqlfluff-lint"
          "sqlfluff-fix"
          "ruff"
          "no-pushes-to-branch"
        ])
      ) self.packages.${system};
      legacyPackages = pkgs;
    };
}
