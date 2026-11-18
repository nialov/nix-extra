{ self, inputs, ... }:

let
  inherit (inputs.nixpkgs) lib;
  localOverlay = import ./_overlays inputs;
  fullOverlay = lib.composeManyExtensions [
    localOverlay
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
