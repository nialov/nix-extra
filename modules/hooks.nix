{
  inputs,
  flake-parts-lib,
  ...
}:

let
  inherit (flake-parts-lib) importApply;
  custom-pre-commit-hooks = importApply ./_flake-modules/pre-commit-custom.nix {
    inherit inputs;
  };
  custom-git-hooks = custom-pre-commit-hooks;
in
{
  imports = [ custom-git-hooks ];
  flake.flakeModules = {
    inherit custom-pre-commit-hooks custom-git-hooks;
  };
}
