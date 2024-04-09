{ writeShellApplication, fish, python3, coreutils }:

let
  python3WithJupytext = python3.withPackages (p: [ p.jupytext ]);
  app = writeShellApplication {
    name = "jupytext-nb-edit";
    runtimeInputs = [ fish coreutils python3WithJupytext ];
    text = ''
      fish ${./edit.fish} "$@"
    '';

  };
in app.overrideAttrs (_: _: {

  postCheck = ''
    HOME="$(mktemp -d)"
    export HOME
    echo "import importlib" > script.py
    ${python3WithJupytext}/bin/jupytext --to ipynb script.py
    EDITOR="echo" ${app}/bin/jupytext-nb-edit script.ipynb
  '';
})
