{ pkgs, lib, ... }:

with lib;

let cfg = config.hardware.flipperzero;

in {
  options = {

    hardware.flipperzero = {
      enable = mkEnableOption (mdDoc "flipperzero support");
      enableu2f = mkEnableOption (mdDoc "u2f support");
      enableu2fLogin = mkEnableOption (mdDoc "u2f login");
      enableu2fSudo = mkEnableOption (mdDoc "u2f sudo");
      enableForUser = mkOption {
        type = types.str;
        default = "nialov";
      };
      u2fKeys = mkOption {
        type = types.listOf types.singleLineStr;
        default = [ ];
      };

    };

  };
  config = mkIf cfg.enable {

    users.users."${cfg.enableForUser}" = {
      extraGroups = [
        # Add user to serial access group
        "dialout"
      ];
    };

    # TODO: hardware.flipperzero.enable should be used in a future release
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
        # let
        #   nixos-desktop = ''
        #     nialov:+a10dMEr1WSB/brokTQ1dK+6d6a3jSgp8iwPsqHKjuADxKXU3vNSXUfIp9A6TCuF8KGmscxeyRdBEXr/UHsCZg==,FQtKk5YfpzYjxVGwQqJ3U5tAwt2f/QkC8F5WsHlZbcJzJfIOIcgnlzywtBKmQRPc6f8BOryKKx2xdNwdYJY9mA==,es256,+presence
        #   '';
        #   nixos-laptop = ''
        #     nialov:EGwOXOljBuen1udTeN8r42WiVn5CVez6iDFAbL+RdypXgzOymGHBGxnTcqS43lK2fzxrKQEpAZ8qZ8tBM0YdWA==,BI5aWZFJ256EoOs8+Jle8H3tzO7pqdyJIo+DS1glqQ1IJYjtomUz9Ae/N3eU0TJr4FFhB6yw3Gg4i8vNDJTZog==,es256,+presence
        #   '';
        # in ''
        #   ${nixos-desktop}
        #   ${nixos-laptop}
        # '';
      };
      # cue = true;
    };

  };
}
