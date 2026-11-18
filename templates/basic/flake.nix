{
  description = "Description for the project";

  inputs = {
    nix-extra = {
      url = "github:nialov/nix-extra";
    };
    nixpkgs.follows = "nix-extra/nixpkgs";
    flake-parts.follows = "nix-extra/flake-parts";
    import-tree.follows = "nix-extra/import-tree";
  };

  outputs =
    inputs:
    let
      flakePart = inputs.flake-parts.lib.mkFlake { inherit inputs; } (
        { inputs, ... }:
        {
          systems = [ "x86_64-linux" ];
          imports = [
            inputs.nix-extra.flakeModules.custom-git-hooks
            (inputs.import-tree ./modules)
          ];
        }
      );

    in
    flakePart;

}
