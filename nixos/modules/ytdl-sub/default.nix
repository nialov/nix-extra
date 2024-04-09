{ config, pkgs, lib, utils, ... }:

with lib;

let
  cfg = config.services.ytdl-sub;
  format = pkgs.formats.yaml { };
  inherit (utils.systemdUtils.unitOptions) unitOption;

  # remove null values from the final configuration
  finalConfiguration = lib.filterAttrsRecursive (_: v: v != null);
  finalSettings = finalConfiguration cfg.settings;
  finalSubscriptions = finalConfiguration cfg.subscriptions;
  configFile = format.generate "config.yaml" finalSettings;
  subscriptionsFile = format.generate "subscriptions.yaml" finalSubscriptions;
in {
  options = {
    services.ytdl-sub = {
      enable = mkEnableOption (lib.mdDoc "ytdl-sub");

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/ytdl-sub";
        description =
          lib.mdDoc "The directory where ytdl-sub stores its data files.";
      };

      user = mkOption {
        type = types.str;
        default = "ytdl-sub";
        description = lib.mdDoc "User account under which ytdl-sub runs.";
      };

      group = mkOption {
        type = types.str;
        default = "ytdl-sub";
        description = lib.mdDoc "Group under which ytdl-sub runs.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.ytdl-sub;
        defaultText = literalExpression "pkgs.ytdl-sub";
        description = lib.mdDoc ''
          ytdl-sub package to use.
        '';
      };
      timerConfig = mkOption {
        type = types.attrsOf unitOption;
        default = { OnCalendar = "hourly"; };
        description = lib.mdDoc ''
          When to run the backup. See {manpage}`systemd.timer(5)` for details.
        '';
        example = {
          OnCalendar = "00:05";
          RandomizedDelaySec = "5h";
        };
      };
      # timerConfig = {
      #   # Service runs every hour
      #   OnCalendar = "*-*-* 00/1:00:00";
      #   Unit = "ytdl-sub.service";
      # };
      settings = mkOption {
        default = { };
        description = mdDoc ''
          ytdl-sub config.yaml settings
        '';
        type = types.submoduleWith {
          modules = [
            (_: {
              options = {
                configuration = mkOption {
                  type = types.submodule {
                    options = {
                      working_directory = mkOption {
                        type = types.path;
                        default = "${cfg.dataDir}/working_directory";
                      };
                    };
                  };
                  default = { };
                };
                presets = mkOption {
                  type = types.attrsOf (types.submodule {
                    freeformType = format.type;
                    # default = { };
                  });
                };

              };
            })
          ];
        };
      };
      subscriptions = mkOption {
        default = { };
        description = mdDoc ''
          ytdl-sub subscriptions.yaml settings
        '';
        type = types.attrsOf (types.submodule {
          options = {
            preset = mkOption { type = types.listOf types.str; };
            overrides = mkOption {
              type = types.submodule {
                freeformType = format.type;
                options = {
                  tv_show_name = mkOption { type = types.str; };
                  url = mkOption { type = types.str; };
                };
              };
            };

          };
        });
      };

    };
  };

  config = mkIf cfg.enable {
    systemd = {
      tmpfiles.rules =
        [ "d '${cfg.dataDir}' 0700 ${cfg.user} ${cfg.group} - -" ];

      services.ytdl-sub = {
        description = "ytdl-sub";
        # after = [ "network.target" ];
        # wantedBy = [ "multi-user.target" ];
        environment = { "HOME" = "${cfg.dataDir}"; };

        serviceConfig = {
          Type = "oneshot";
          User = cfg.user;
          Group = cfg.group;
          ProtectSystem = "strict";
          PrivateUsers = true;
          PrivateTmp = true;
          StateDirectory = "ytdl-sub";
          RuntimeDirectory = "ytdl-sub";
          ExecStartPre =
            "${cfg.package}/bin/ytdl-sub --config='${configFile}' --dry-run --log-level verbose";
          ExecStart =
            "${cfg.package}/bin/ytdl-sub --config='${configFile}' sub ${subscriptionsFile}";
        };
      };

      timers."ytdl-sub" = {
        wantedBy = [ "timers.target" ];
        partOf = [ "ytdl-sub.service" ];
        inherit (cfg) timerConfig;
      };
    };

    # networking.firewall = mkIf cfg.openFirewall {
    #   allowedTCPPorts = [ 8989 ];
    # };

    users.users = mkIf (cfg.user == "ytdl-sub") {
      ytdl-sub = {
        isSystemUser = true;
        inherit (cfg) group;
        # group = cfg.group;
        home = cfg.dataDir;
        # uid = config.ids.uids.ytdl-sub;
      };
    };

    users.groups = mkIf (cfg.group == "ytdl-sub") { ytdl-sub = { }; };
  };
}
