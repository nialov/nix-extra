{ self, inputs, ... }:

let
  inherit (inputs.nixpkgs) lib;
  localOverlay = import ./_overlays inputs;
  inputOverlay =
    _: prev:
    let
      inherit (prev.stdenv.hostPlatform) system;
    in
    {
      inherit (inputs.deploy-rs-input.packages."${system}") deploy-rs;
    };
  fullOverlay = lib.composeManyExtensions [
    localOverlay
    inputOverlay
    self.overlays.utils
    inputs.fractopo.overlays.packageOverlay
  ];
in
{
  flake.overlays = {
    default = fullOverlay;
    utils = lib.composeManyExtensions [ localOverlay ];
  };
}
