{ inputs, lib, mkDerivation, runCommand, base, protolude, easyplot
, monoid-subclasses, HUnit }:

mkDerivation {
  # pname = "tasklite-core";
  # version = "0.3.0.0+develop";
  # isLibrary = false;
  # isExecutable = true;
  # license = lib.licenses.agpl3Only;
  pname = "huzzy";
  version = inputs.tasklite-src.shortRev;
  # sha256 = "0i8h380nszd7hk7x6l7qx0ri6k12551li2m77gspzakcf47l6ldp";
  libraryHaskellDepends = [ base easyplot monoid-subclasses protolude HUnit ];
  # base
  # , monoid-subclasses
  # , protolude
  description = "Fuzzy logic library with support for T1, IT2, GT2";
  license = lib.licenses.mit;
  hydraPlatforms = lib.platforms.none;
  # executableHaskellDepends = [ ];

  src = let

    fullSrc = inputs.tasklite-src;
  in runCommand "huzzy" { } ''
    cp -r ${fullSrc}/huzzy $out
  '';

}
