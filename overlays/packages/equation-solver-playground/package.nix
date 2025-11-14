{
  writeShellApplication,
  python3,
  coreutils,
}:

let
  python3WithJupytext = python3.withPackages (p: [
    p.marimo
    p.sympy
    p.matplotlib
    p.seaborn
  ]);
  app = writeShellApplication {
    name = "equation-solver-playground";
    runtimeInputs = [
      coreutils
      python3WithJupytext
    ];
    text =
      let
        mainScript = builtins.readFile ./equation-solver-playground.sh;
      in
      ''
        export TEMPLATE_PATH="${./template_equation_playground.py}"
        ${mainScript}
      '';
  };
in
app
