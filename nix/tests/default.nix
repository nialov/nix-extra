{
  perSystem =
    { pkgs, ... }:
    {

      checks =
        let
          mkPandocRstCheck =
            pandoc: fails:
            let
              rstTextFile = pkgs.writeText "original.rst" ''
                -  Hello
                -  There

                   -  And here
              '';
              cmd =
                if fails then
                  "! ${pkgs.diffutils}/bin/diff ${rstTextFile} $out/formatted.rst"
                else
                  "${pkgs.diffutils}/bin/diff ${rstTextFile} $out/formatted.rst";

            in
            pkgs.runCommand "pandoc-rst-check"
              {
                preferLocalBuild = true;
              }
              ''
                mkdir "$out"
                ${pandoc}/bin/pandoc ${rstTextFile} --from rst --to rst --output "$out/formatted.rst"
                echo ${rstTextFile}
                echo "$out/formatted.rst"
                echo ${cmd}
                ${cmd}

              '';

        in
        {
          pandoc-rst-check-latest = mkPandocRstCheck pkgs.pandoc true;
        };

    };
}
