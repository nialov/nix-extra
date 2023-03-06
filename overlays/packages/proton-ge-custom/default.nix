{ stdenv, fetchurl }:

# From: https://github.com/NixOS/nixpkgs/issues/73323
stdenv.mkDerivation rec {
  pname = "proton-ge-custom";
  version = "GE-Proton7-49";

  src = fetchurl {
    url =
      "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
    sha256 = "sha256-T+7R+zFMd0yQ0v7/WGym2kzMMulUmATS/LCEQS8whiw=";
  };

  buildCommand = ''
    mkdir -p $out
    tar -C $out --strip=1 -x -f $src
  '';
}
