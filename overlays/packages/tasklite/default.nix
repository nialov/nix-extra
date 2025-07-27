{
  inputs,
  lib,
  writeText,
  mkDerivation,
  aeson,
  ansi-terminal,
  beam-core,
  beam-migrate,
  beam-sqlite,
  cassava,
  colour,
  file-embed,
  generic-random,
  githash,
  hourglass,
  hsemail,
  hspec,
  huzzy,
  iso8601-duration,
  optparse-applicative,
  portable-lines,
  pretty-simple,
  prettyprinter,
  prettyprinter-ansi-terminal,
  protolude,
  quickcheck-instances,
  read-editor,
  simple-sql-parser,
  sqlite-simple,
  temporary,
  ulid,
  unordered-containers,
  vector,
  yaml,
}:

let
  versionSlugPatch = ''
    diff --git a/tasklite-core/app/Main.hs b/tasklite-core/app/Main.hs
    index ff66bf4..cdbafb5 100644
    --- a/tasklite-core/app/Main.hs
    +++ b/tasklite-core/app/Main.hs
    @@ -379,14 +379,15 @@ nameToAliasList =
     {- Imitates output from `git describe` -}
     versionSlug :: Text
     versionSlug =
    -  let
    -    gitInfo = $$tGitInfoCwd
    -  in
    -    fromString $
    -      showVersion version
    -        <> "+"
    -        <> take 8 (giHash gitInfo)
    -        <> (if giDirty gitInfo then "-dirty" else "")
    +  "whatever"
    +  -- let
    +  --   gitInfo = $$tGitInfoCwd
    +  -- in
    +  --   fromString $
    +  --     showVersion version
    +  --       <> "+"
    +  --       <> take 8 (giHash gitInfo)
    +  --       <> (if giDirty gitInfo then "-dirty" else "")
     
     
     aliasWarning :: Text -> Doc AnsiStyle
  '';
  versionSlugPatchFile = writeText "versionSlugPatch.patch" versionSlugPatch;

in
mkDerivation {
  pname = "tasklite-core";
  version = inputs.tasklite-src.shortRev;
  isLibrary = false;
  isExecutable = true;
  license = lib.licenses.agpl3Only;
  executableHaskellDepends = [

    aeson
    ansi-terminal
    beam-core
    beam-migrate
    beam-sqlite
    cassava
    colour
    file-embed
    generic-random
    githash
    hourglass
    hsemail
    hspec
    huzzy
    iso8601-duration
    optparse-applicative
    portable-lines
    pretty-simple
    prettyprinter
    prettyprinter-ansi-terminal
    protolude
    quickcheck-instances
    read-editor
    simple-sql-parser
    sqlite-simple
    temporary
    ulid
    unordered-containers
    vector
    yaml

  ];
  # Setup: Encountered missing or private dependencies:
  # QuickCheck,
  # aeson,
  # ansi-terminal,
  # beam-core,
  # beam-migrate,
  # beam-sqlite,
  # cassava,
  # colour,
  # file-embed,
  # generic-random,
  # githash,
  # hourglass,
  # hsemail,
  # hspec,
  # huzzy,
  # iso8601-duration,
  # optparse-applicative,
  # portable-lines,
  # pretty-simple,
  # prettyprinter,
  # prettyprinter-ansi-terminal,
  # protolude,
  # quickcheck-instances,
  # read-editor,
  # simple-sql-parser,
  # sqlite-simple,
  # temporary,
  # ulid,
  # unordered-containers,
  # vector,
  # yaml

  # src = let

  #   fullSrc = inputs.tasklite-src;
  #   patchedFullSrc = applyPatches {
  #     name = "tasklite-core-src-patched";
  #     src = fullSrc;
  #     patches = [ (writeText "versionSlugPatch.patch" versionSlugPatch) ];
  #   };
  # in runCommand "tasklite-core" { } ''
  #   cp -r ${patchedFullSrc}/tasklite-core $out
  # '';

  src = inputs.tasklite-src;
  patches = [ versionSlugPatchFile ];
  postPatch = ''
    cd ./tasklite-core/
  '';

  meta = with lib; {
    description = "The CLI task manager for power users";
    homepage = "https://github.com/ad-si/tasklite";
    maintainers = with maintainers; [ nialov ];
    broken = true;
  };
}
