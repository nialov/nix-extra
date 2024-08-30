{ stdenv, inputs, lib, rclone, openstackclient, makeWrapper, s3cmd }:

let

  # Meant for execution i.e. `a-check <args>`
  cliTools = [
    "a-check"
    "a-encrypt"
    "a-delete"
    "a-access"
    "a-get"
    "a-find"
    "a-flip"
    "a-info"
    "a-list"
    "a-publish"
    "a-put"
    "a-stream"
    "allas-add-S3-permissions"
    "allas-backup"
    "allas-health-check2"
    "allas-health-check"
    "allas-list-all"
    "allas-mount"
    "allas-share-bucket"
    "allas_list_all"
    "check_atoken"
    "keep_tokens_alive.sh"
    "launch_atoken"
    "md5sum.macosx"
    "run-rclone-mount.sh"
    "rclone-ls-workaround"
    "test-cli"
    "test-allas-tools"
  ];

  # Meant for sourcing with bash i.e. `source allas_conf`
  # sourceTools = [ "allas_conf" ];

  # Patch #!/bin/bash shebangs, make executable and wrap PATH with dependency tools
  wrapToolsString = tool: ''
    ln -s $out/${tool} $out/bin/${tool}
    patchShebangs $out/bin/${tool}
    chmod +x $out/bin/${tool}
    wrapProgram $out/bin/${tool} --prefix PATH : ${
      lib.makeBinPath [ rclone s3cmd ]
    }:${openstackclient}/bin/openstack
  '';
  wrapToolsConcat = tools:
    lib.concatStringsSep "\n" (builtins.map wrapToolsString tools);

in stdenv.mkDerivation

{
  name = "allas-cli-utils";
  src = inputs.allas-cli-utils-src;
  # nativeBuildInputs = [ installShellFiles ];
  nativeBuildInputs = [ makeWrapper ];
  # unpackPhase = "true";
  installPhase = ''
    cp -r ${inputs.allas-cli-utils-src} $out
    chmod +w $out
    mkdir -p $out/bin
    ${wrapToolsConcat cliTools}
  '';
  # postFixup = ''
  # '';
  # doInstallCheck = true;
  # installCheckPhase = ''
  #   $out/bin/pathnames --help

  #   STEM=$($out/bin/pathnames stem /path/to/file.txt)
  #   [ "$STEM" == "file" ]
  # '';

}
