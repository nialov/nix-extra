{ pkgs, ... }:
pkgs.symlinkJoin rec {
  description = "Poetry package manager wrapped with common C library tooling for Python development";
  name = "poetry-with-c-tooling";
  nativeBuildInputs = [ pkgs.makeWrapper ];
  paths = with pkgs; [ poetry ];
  postBuild =
    let

      caBundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
      ccLib = "${pkgs.stdenv.cc.cc.lib}/lib";
      zlibLib = "${pkgs.zlib}/lib";
      expatLib = "${pkgs.expat}/lib";
      ldPath = "${ccLib}:${zlibLib}:${expatLib}";
      wraps = [
        "--set GIT_SSL_CAINFO ${caBundle}"
        "--set SSL_CERT_FILE ${caBundle}"
        "--set CURL_CA_BUNDLE ${caBundle}"
        "--set LD_LIBRARY_PATH ${ldPath}"
      ];

    in
    ''
      wrapProgram $out/bin/poetry ${builtins.concatStringsSep " " wraps}
      $out/bin/poetry --help
    '';
}
