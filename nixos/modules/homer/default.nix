{ config, pkgs, lib, ... }:
# TODO: All images need to be manually copied to /var/lib/homer
# TODO: Configuration is in yaml. Cannot use same with caddy and homer :/
let

  cfg = config.services.homer;
  format = pkgs.formats.yaml { };

  # Download homer source from GitHub
  # Download javascript dependencies with yarn
  homerBuild = pkgs.homer;

  # serviceGroupModule = { config, ... }: {
  serviceGroupModule = _: {
    options = {

      icon = lib.mkOption { type = lib.types.str; };
      items = lib.mkOption {
        type = lib.types.listOf (lib.types.submoduleWith {
          modules = [

            # ({ config, ... }: {
            (_: {
              options = {
                logo = lib.mkOption { type = lib.types.str; };
                name = lib.mkOption { type = lib.types.str; };
                # logoImage = lib.mkOption { type = lib.types.package; };
                subtitle = lib.mkOption { type = lib.types.str; };
                tag = lib.mkOption { type = lib.types.str; };
                url = lib.mkOption { type = lib.types.str; };
              };
            })
          ];
        });
      };
      name = lib.mkOption {
        type = lib.types.str;

      };

    };
  };

in {
  options = {

    services.homer = {

      enable = lib.mkEnableOption (lib.mdDoc "Homer dashboard");

      port = lib.mkOption {
        type = lib.types.port;
        # default = 6781;

      };
      settings = lib.mkOption { inherit (format) type; };
      package = lib.mkOption {
        type = lib.types.package;
        default = homerBuild;
      };
      services = lib.mkOption {
        type = lib.types.listOf
          (lib.types.submoduleWith { modules = [ serviceGroupModule ]; });
      };
      images = lib.mkOption { type = lib.types.attrsOf lib.types.package; };

    };

  };
  config = lib.mkIf cfg.enable

    (let
      mergedSettings = cfg.settings // { inherit (cfg) services; };
      settingsFile =
        pkgs.writeText "config.yml" (builtins.toJSON mergedSettings);
      # imageLinkCommands = logosDir:

      imageLinkCommandsString = imagesSet: logosDir:
        lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''
          ln -s --force ${value} ${logosDir}/${name}
        '') imagesSet);
    in {

      systemd.services.homer = {
        description = "A very simple static homepage for your server.";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        # Move the frontend files (dist) to service state directory
        # Also move the config for the dashboard
        preStart = let logosDir = "$STATE_DIRECTORY/dist/assets/logos";

        in ''
          cp -r ${cfg.package}/libexec/homer/deps/homer/dist $STATE_DIRECTORY
          cp ${settingsFile} "$STATE_DIRECTORY"/dist/assets/config.yml

          mkdir -p ${logosDir}
          ${imageLinkCommandsString cfg.images logosDir}
        '';
        serviceConfig = {
          Type = "simple";
          StateDirectory = "homer";
          RuntimeDirectory = "homer";
          user = "homer";
          group = "homer";
          ExecStart = ''
            ${pkgs.caddy}/bin/caddy file-server --listen localhost:${
              toString cfg.port
            } --root /var/lib/homer/dist
          '';
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    });

}
