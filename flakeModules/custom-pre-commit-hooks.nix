{ inputs, ... }:
{
  systems = [ "x86_64-linux" ];
  imports = [ inputs.git-hooks.flakeModule ];

  flake = { };

  perSystem =
    {
      config,
      pkgs,
      lib,
      ...
    }:

    {
      options =
        let

          inherit (lib) mkOption types;
          inherit (config.pre-commit.settings) hookModule;

        in
        {
          pre-commit.settings.hooks = {
            detect-secrets = mkOption {
              description = "detect-secrets hook";
              type = types.submodule {
                imports = [ hookModule ];
                options.settings = {
                  baselinePath = mkOption {
                    type = types.str;
                    description = "Path to the baseline file.";
                    default = ".secrets.baseline";
                  };
                };
              };
            };

          };

        };
      config =

        {
          pre-commit = {
            settings =

              {
                hooks =

                  let
                    inherit (config.pre-commit.settings) hooks;
                    # let pre-commit-fish-src = inputs.pre-commit-fish-src.outPath;
                    # in
                  in
                  {
                    isort = {
                      enable = lib.mkDefault false;
                      raw = {
                        args = lib.mkDefault [
                          "--profile"
                          "black"
                        ];
                      };
                    };
                    detect-secrets = {
                      name = "detect-secrets";
                      description = "Scan for potential committed secrets";
                      files = ".*";
                      package = pkgs.python3Packages.detect-secrets;
                      enable = lib.mkDefault false;
                      entry =
                        let
                          inherit (hooks.detect-secrets.settings) baselinePath;
                        in
                        "${pkgs.python3Packages.detect-secrets}/bin/detect-secrets-hook --baseline ${baselinePath}";
                    };
                    fish-lint = {
                      name = "fish-lint";
                      description = "Lint fish files.";
                      package = pkgs.fish;
                      entry = ''
                        ${hooks.fish-lint.package}/bin/fish_indent --check
                      '';
                      files = "\\.(fish)$";
                    };
                    fish-format = {
                      name = "fish-format";
                      description = "Format fish files.";
                      package = pkgs.fish;
                      entry = ''
                        ${hooks.fish-format.package}/bin/fish_indent --write
                      '';
                      files = "\\.(fish)$";
                    };
                    pre-commit-hook-ensure-sops = {
                      name = "pre-commit-hook-ensure-sops";
                      description = "Check for committed sops secrets.";
                      package = pkgs.pre-commit-hook-ensure-sops;
                      entry = ''
                        ${hooks.pre-commit-hook-ensure-sops.package}/bin/pre-commit-hook-ensure-sops
                      '';
                      files = "^secrets/";
                    };
                    rstcheck = {
                      name = "rstcheck";
                      description = "Check rst files with rstcheck";
                      package = pkgs.rstcheck;
                      entry = "${hooks.rstcheck.package}/bin/rstcheck --ignore-directives automodule";
                      files = "\\.(rst)$";
                    };
                    cogapp = {
                      name = "cogapp";
                      description = "Execute Python snippets in text files";
                      package = pkgs.python3Packages.cogapp;
                      entry = "${hooks.cogapp.package}/bin/cog -e -r --check -c";
                      pass_filenames = false;
                      always_run = true;
                    };
                    nbstripout = {
                      name = "nbstripout";
                      description = "Strip output from Jupyter notebooks";
                      package = pkgs.nbstripout;
                      entry = "${hooks.nbstripout.package}/bin/nbstripout";
                      files = "\\.(ipynb)$";
                    };
                    ruff = {
                      types = lib.mkForce [ "text" ];
                      types_or = [
                        "python"
                        "jupyter"
                      ];
                    };
                    ruff-format = {
                      types = lib.mkForce [ "text" ];
                      types_or = [
                        "python"
                        "jupyter"
                      ];
                    };
                    sqlfluff-lint = {
                      description = "Lint sql files with `SQLFluff`";
                      types = [ "sql" ];
                      package = pkgs.sqlfluff;
                      entry =
                        let

                          cmdLine = lib.cli.toGNUCommandLineShell { } {
                            processes = 0;
                            disable-progress-bar = true;
                          };

                        in
                        ''
                          ${hooks.sqlfluff-lint.package}/bin/sqlfluff lint ${cmdLine}
                        '';
                    };
                    sqlfluff-fix = {
                      description = "Fix sql lint errors with `SQLFluff`";
                      types = [ "sql" ];
                      package = pkgs.sqlfluff;
                      entry =
                        let

                          cmdLine = lib.cli.toGNUCommandLineShell { } {
                            show-lint-violations = true;
                            processes = 0;
                            disable-progress-bar = true;
                            force = true;
                          };

                        in
                        ''
                          ${hooks.sqlfluff-fix.package}/bin/sqlfluff fix ${cmdLine}
                        '';
                      require_serial = true;
                    };
                    no-pushes-to-branch = {
                      name = "no-pushes-to-branch";
                      description = "No pushes to branch (default)";
                      package = pkgs.writeShellApplication {
                        name = "no-pushes-to-branch";
                        runtimeInputs = [
                          pkgs.git
                          pkgs.gnused
                          pkgs.procps
                        ];
                        # TODO: Fix script using error messages
                        excludeShellChecks = [
                          "SC2016"
                          "SC2086"
                          "SC2027"
                        ];
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

                      entry = ''
                        ${hooks.no-pushes-to-branch.package}/bin/no-pushes-to-branch
                      '';
                      stages = [ "push" ];
                      pass_filenames = false;
                    };

                  };
              };
          };

        };
    };
}
