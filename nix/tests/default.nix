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
                  "${pkgs.diffutils}/bin/diff ${rstTextFile} $out/formatted.rst"
                else
                  "${pkgs.diffutils}/bin/cmp ${rstTextFile} $out/formatted.rst";

            in
            pkgs.runCommand "pandoc-rst-check" { } ''
              mkdir "$out"
              ${pandoc}/bin/pandoc ${rstTextFile} --from rst --to rst --output "$out/formatted.rst"
              echo ${rstTextFile}
              echo "$out/formatted.rst"
              ${cmd}

            '';

        in
        {
          # TODO: pandoc 3.6 introduced regression
          pandoc-rst-check-2411 = mkPandocRstCheck pkgs.release2411Packages.pandoc false;
          pandoc-rst-check-latest = mkPandocRstCheck pkgs.release2411Packages.pandoc true;
        };

    };
}
