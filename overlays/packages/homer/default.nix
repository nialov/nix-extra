{ inputs, mkYarnPackage

}:

let

  src = inputs.homer-src;

in mkYarnPackage {
  name = "homer";
  inherit src;
  packageJSON = "${src}/package.json";
  yarnLock = "${src}/yarn.lock";
  #yarnNix = ./yarndeps.nix;
  postPhases = [ "finalPhase" ];
  # Build the frontend with the installed yarn environment
  finalPhase = ''
    yarn --offline build
  '';
}
