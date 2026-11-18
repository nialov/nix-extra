{ self, inputs, ... }:

let
  inherit (inputs.nixpkgs) lib;
  # localOverlay = import ./_overlays inputs;
  fullOverlay = lib.composeManyExtensions [
    self.overlays.localOverlay
    inputs.fractopo.overlays.packageOverlay
  ];
in
lib.mkMerge [
  {
    flake.overlays = {
      default = fullOverlay;
    };
  }

]
