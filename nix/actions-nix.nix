{

  flake.actions-nix = {
    pre-commit.enable = true;
    defaultValues = {
      jobs = {
        timeout-minutes = 60;
        runs-on = "ubuntu-latest";
      };
    };
    workflows =

      let
        checkoutStep = {
          uses = "actions/checkout@v4";
        };
        installNixStep = {
          uses = "DeterminateSystems/nix-installer-action@v9";
        };
        maximizeBuildSpaceStep = {
          uses = "easimon/maximize-build-space@master";
          "with" = {
            "remove-dotnet" = true;
            "remove-android" = true;
            "remove-haskell" = true;
            "remove-codeql" = true;
            "remove-docker-images" = true;
            "build-mount-path" = "/nix";
            "temp-reserve-mb" = 1024;
            "root-reserve-mb" = 1024;
            "swap-size-mb" = 2048;
          };
        };
        reOwnNixStep = {
          name = "Reown /nix to root";
          run = "sudo chown -R root /nix";

        };
        nixFlakeCheckNoBuildStep = {
          name = "Check flake";
          run = "nix -Lv flake check --no-build";
        };
        cachixStep = {
          uses = "cachix/cachix-action@v14";
          "with" = {
            authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
            name = "nialov";
          };
          continue-on-error = true;
        };
        nixFastBuildStep = {
          name = "Evaluate and build checks faster";
          run = "nix run .#nix-fast-build-ci";
        };

      in
      {
        ".github/workflows/main.yaml" = {

          jobs = {
            "nix-flake-check-no-build" = {
              steps = [
                checkoutStep
                installNixStep
                nixFlakeCheckNoBuildStep
              ];
            };
            "nix-fast-build" = {
              steps = [
                maximizeBuildSpaceStep
                reOwnNixStep
                checkoutStep
                installNixStep
                cachixStep
                installNixStep
                nixFastBuildStep
              ];
            };
          };

        };

      };
  };
}
