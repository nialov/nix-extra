({ inputs, ... }: {
  systems = [ "x86_64-linux" ];
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  flake = { };

  # perSystem = { self', pkgs, ... }:
  perSystem = { pkgs, lib, ... }: {
    # _module.args.pkgs = lib.mkDefault (import inputs.nixpkgs {
    #   inherit system;
    #   overlays = [ self.overlays.default ];
    #   config = { };
    # });
    pre-commit = {
      check.enable = lib.mkDefault false;
      # TODO: Could I use option paradigm here rather than making default configuration?
      # Yes, see: pre-commit-hooks.nix/flake-module.nix
      settings =

        {
          hooks =
            # let pre-commit-fish-src = inputs.pre-commit-fish-src.outPath;
            # in
            {
              isort = {
                enable = lib.mkDefault false;
                raw = { args = lib.mkDefault [ "--profile" "black" ]; };
              };
              detect-secrets = {
                enable = lib.mkDefault false;
                name = "detect-secrets";
                entry =
                  "${pkgs.python3Packages.detect-secrets}/bin/detect-secrets-hook";
                files = ".*";
                raw = { args = [ "--baseline" ".secrets.baseline" ]; };
              };
              # commitizen = {
              # enable = true;
              # name = "commitizen";
              # entry = "${pkgs.commitizen}/bin/cz check --commit-msg-file";
              # stages = [ "commit-msg" ];
              # };
              fish-lint = {
                enable = lib.mkDefault false;
                name = "fish-lint";
                entry =
                  # let
                  #   script =
                  #     "${pre-commit-fish-src}/pre-commit-hooks/fish_indent_lint.fish";
                  # in 
                  ''
                    ${pkgs.fish}/bin/fish_indent --check
                  '';
                files = "\\.(fish)$";
              };
              fish-format = {
                enable = lib.mkDefault false;
                name = "fish-format";
                entry =
                  # let
                  #   script =
                  #     "${pre-commit-fish-src}/pre-commit-hooks/fish_indent_format.fish";
                  # in
                  ''
                    ${pkgs.fish}/bin/fish_indent --write
                  '';
                files = "\\.(fish)$";
              };
              pre-commit-hook-ensure-sops = {
                enable = lib.mkDefault false;
                name = "pre-commit-hook-ensure-sops";
                entry = ''
                  ${pkgs.pre-commit-hook-ensure-sops}/bin/pre-commit-hook-ensure-sops
                '';
                files = "^secrets/";
              };
              sync-git-tag-with-poetry = {
                enable = lib.mkDefault false;
                name = "sync-git-tag-with-poetry";
                description = "sync-git-tag-with-poetry";
                entry = ''
                  ${pkgs.sync-git-tag-with-poetry}/bin/sync-git-tag-with-poetry
                '';
                # stages = [ "push" "manual" ];
                pass_filenames = false;
              };
              trim-trailing-whitespace = {
                enable = lib.mkDefault false;

                name = "trim-trailing-whitespace";
                description = "This hook trims trailing whitespace.";
                entry =
                  "${pkgs.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
                types = [ "text" ];
              };
              check-added-large-files = {
                enable = lib.mkDefault false;
                name = "check-added-large-files";
                description = "This hook checks for large added files.";
                entry =
                  "${pkgs.python3Packages.pre-commit-hooks}/bin/check-added-large-files --maxkb=5000";
              };
              rstcheck = {
                enable = lib.mkDefault false;
                name = "rstcheck";
                description = "Check documentation with rstcheck";
                entry = "${pkgs.rstcheck}/bin/rstcheck";
                files = "\\.(rst)$";
                raw = { args = [ "--ignore-directives" "automodule" ]; };
              };
              cogapp = {
                enable = lib.mkDefault false;
                name = "cogapp";
                description = "Execute Python snippets in text files";
                entry = "${pkgs.python3Packages.cogapp}/bin/cog";
                pass_filenames = false;
                raw = {
                  args = lib.mkBefore [ "-e" "-r" "--check" "-c" ];
                  always_run = true;
                };
              };
              black-nb = {
                enable = lib.mkDefault false;
                name = "black-nb";
                entry = let
                  black-nb =

                    pkgs.python3Packages.black.overrideAttrs (_: prevAttrs: {

                      propagatedBuildInputs = prevAttrs.propagatedBuildInputs
                        ++ prevAttrs.passthru.optional-dependencies.jupyter;
                    });
                in "${black-nb}/bin/black";

                files = "\\.ipynb$";
              };
              nbstripout = {
                enable = lib.mkDefault false;
                name = "nbstripout";
                description = "Strip output from Jupyter notebooks";
                entry = let inherit (pkgs) nbstripout;

                in "${nbstripout}/bin/nbstripout";
                files = "\\.(ipynb)$";
              };
              ruff = {
                enable = lib.mkDefault false;
                types = lib.mkForce [ "text" ];
                files = "\\.(ipynb|py)$";
              };
              yamllint = { enable = lib.mkDefault false; };
              sqlfluff-lint = {
                enable = lib.mkDefault false;
                description = "Lints sql files with `SQLFluff`";
                types = [ "sql" ];
                entry = ''
                  ${pkgs.sqlfluff}/bin/sqlfluff lint
                '';
                raw = {
                  args =
                    lib.mkBefore [ "--processes" "0" "--disable-progress-bar" ];
                  require_serial = true;
                };
              };
              sqlfluff-fix = {
                enable = lib.mkDefault false;
                description = "Fixes sql lint errors with `SQLFluff`";
                types = [ "sql" ];
                entry = ''
                  ${pkgs.sqlfluff}/bin/sqlfluff fix
                '';
                raw = {
                  args = lib.mkBefore [
                    "--show-lint-violations"
                    "--processes"
                    "0"
                    "--disable-progress-bar"
                    "--force"
                  ];
                  require_serial = true;
                };
              };
              no-pushes-to-branch = {
                enable = lib.mkDefault false;
                name = "no-pushes-to-branch";
                description = "No pushes to branch (default)";

                entry = let
                  prePush = pkgs.writeShellApplication {
                    name = "no-pushes-to-branch";
                    runtimeInputs = [ pkgs.git pkgs.gnused pkgs.procps ];
                    # TODO: Fix script using error messages
                    excludeShellChecks = [ "SC2016" "SC2086" "SC2027" ];
                    text = ''
                      # @link https://gist.github.com/mattscilipoti/8424018
                      #
                      # Called by "git push" after it has checked the remote status,
                      # but before anything has been pushed.
                      #
                      # If this script exits with a non-zero status nothing will be pushed.
                      #
                      # Steps to install, from the root directory of your repo...
                      # 1. Copy the file into your repo at `.git/hooks/pre-push`
                      # 2. Set executable permissions, run `chmod +x .git/hooks/pre-push`
                      # 3. Or, use `rake hooks:pre_push` to install
                      #
                      # Try a push to master, you should get a message `*** [Policy] Never push code directly to...`
                      #
                      # The commands below will not be allowed...
                      # `git push origin master`
                      # `git push --force origin master`
                      # `git push --delete origin master`


                      protected_branch='master'

                      policy="\n\n[Policy] Never push code directly to the "$protected_branch" branch! (Prevented with pre-push hook.)\n\n"

                      current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

                      push_command=$(ps -ocommand= -p $PPID)

                      is_destructive='force|delete|\-f'

                      will_remove_protected_branch=':'$protected_branch

                      do_exit(){
                        echo -e $policy
                        exit 1
                      }

                      if [[ $push_command =~ $is_destructive ]] && [ $current_branch = $protected_branch ]; then
                        do_exit
                      fi

                      if [[ $push_command =~ $is_destructive ]] && [[ $push_command =~ $protected_branch ]]; then
                        do_exit
                      fi

                      if [[ $push_command =~ $will_remove_protected_branch ]]; then
                        do_exit
                      fi

                      # Prevent ALL pushes to protected_branch
                      if [[ $push_command =~ $protected_branch ]] || [ $current_branch = $protected_branch ]; then
                        do_exit
                      fi

                      unset do_exit

                      exit 0

                    '';
                  };
                in ''
                  ${prePush}/bin/no-pushes-to-branch
                '';
                stages = [ "push" ];
                pass_filenames = false;
              };
            };
        };
    };

  };
})
