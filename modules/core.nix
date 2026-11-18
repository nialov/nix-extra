{
  self,
  config,
  inputs,
  ...
}:
{
  systems = [ "x86_64-linux" ];
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.actions-nix.flakeModules.default
  ];

  flake = {
    nixosModules = { };
    templates.default = {
      path = ../templates/basic;
      description = ''
        A flake using nix-extra overlay with flake-parts.
      '';
    };
    flakePartsConfig = config;
    inherit self;
  };
}
