{
  inputs,
  lib,
  stdenv,
  gfortran,
}:

stdenv.mkDerivation {
  pname = "fehm";
  version = "3.4.0";

  src = inputs.fehm-src;

  nativeBuildInputs = [ gfortran ];

  configurePhase = ''
    cd src
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "Finite Element Heat and Mass Transfer Code";
    homepage = "https://github.com/lanl/fehm";
    license = licenses.bsd3;
    maintainers = with maintainers; [ nialov ];
  };
}
