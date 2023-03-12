{ pkgs, lib, config, ... }:

with lib;

let cfg = config.hardware.flipperzero;

in {
  options = {

    hardware.flipperzero = {
      # enable = mkEnableOption (mdDoc "flipperzero support");
      enableu2f = mkEnableOption (mdDoc "u2f support");
      enableu2fLogin = mkEnableOption (mdDoc "u2f login");
      enableu2fSudo = mkEnableOption (mdDoc "u2f sudo");
      enableForUser = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      u2fKeys = mkOption {
        type = types.listOf types.singleLineStr;
        default = [ ];
      };

    };

  };
  config = mkIf cfg.enable {

    users.users = optionalAttrs (builtins.isString cfg.enableForUser) {
      "${cfg.enableForUser}" = {
        extraGroups = [
          # Add user to serial access group
          "dialout"
        ];
      };
    };

    environment.systemPackages = [ pkgs.qFlipper ];
    services.udev.packages = [ pkgs.qFlipper ];

    # Disable u2f login
    security.pam.services.login.u2fAuth = cfg.enableu2fLogin;
    # Enable (enabled by default) u2f sudo prompt
    security.pam.services.sudo.u2fAuth = cfg.enableu2fSudo;
    security.pam.u2f = {
      enable = cfg.enableu2f;
      authFile = pkgs.writeTextFile {
        name = "u2f_keys";
        text = concatStringsSep "\n" cfg.u2fKeys;
      };
    };

  };
}
