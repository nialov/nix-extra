{ inputs, lib, stdenv, gfortran }:

stdenv.mkDerivation rec {
  pname = "pkg-fblaslapack";
  version = "master";

  src = inputs.pkg-fblaslapack-src;

  nativeBuildInputs = [ gfortran ];

  meta = with lib; {
    description = "";
    homepage = "https://bitbucket.org/petsc/pkg-fblaslapack";
    license = with licenses; [ ];
    maintainers = with maintainers; [ nialov ];
  };
}
