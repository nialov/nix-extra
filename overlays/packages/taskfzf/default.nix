{ inputs, lib, stdenv }:

stdenv.mkDerivation {
  pname = "taskfzf";
  version = "1.0.0";

  src = inputs.taskfzf-src;
  # src = fetchFromGitLab {
  #   owner = "doronbehar";
  #   repo = "taskwarrior-fzf";
  #   rev = "fde0794ac5785801004a5bf7bd4120c8138bf519";
  #   sha256 = "sha256-kWCIZyK9k0vWaHCTOcmki+ZoLecD/J0P4LpaiQoB+9g=";
  # };

  nativeBuildInputs = [ ];

  # postPatch = ''
  # sed -ie 's|/var/lib/wifish|${placeholder "out"}/var/lib/wifish|' wifish
  # '';

  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/bin
    cp taskfzf $out/bin/taskfzf
  '';

  # postFixup = ''
  # wrapProgram ${placeholder "out"}/bin/taskfzf
  # '';

  meta = with lib; {
    homepage = "https://gitlab.com/doronbehar/taskwarrior-fzf";
    description = "Fzf bindings for taskwarrior";
    license = licenses.mit;
    maintainers = with maintainers; [ nialov ];
    platforms = with platforms; linux;
  };
}
