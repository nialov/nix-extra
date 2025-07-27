{ pkgs, python3ToWrap, ... }:
pkgs.symlinkJoin {
  name = "python-with-c-tooling";
  nativeBuildInputs = [ pkgs.makeWrapper ];
  paths = [ python3ToWrap ];
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
      wrapProgram $out/bin/python3 ${builtins.concatStringsSep " " wraps}
      cp $out/bin/python3 $out/bin/python3-with-c-tooling
      $out/bin/python3-with-c-tooling --help
    '';
}
