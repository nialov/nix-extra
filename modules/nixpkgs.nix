{ self, inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      mkNixpkgs =
        nixpkgs:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfree = true;
        };
    in
    {
      _module.args.pkgs = mkNixpkgs inputs.nixpkgs;
    };
}
