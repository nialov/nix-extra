{ inputs, lib, stdenv, gfortran, cmake }:

stdenv.mkDerivation {
  pname = "lagrit";
  version = "3.3.2";

  src = inputs.lagrit-src;

  nativeBuildInputs = [ gfortran cmake ];

  meta = with lib; {
    description =
      "Los Alamos Grid Toolbox (LaGriT) is a library of user callable tools that provide mesh generation, mesh optimization and dynamic mesh maintenance in two and three dimensions";
    homepage = "https://github.com/lanl/lagrit";
    license = with licenses; [ bsd3 ];
    maintainers = with maintainers; [ nialov ];
  };
}
