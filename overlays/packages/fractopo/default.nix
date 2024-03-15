{ inputs, buildPythonPackage, lib, pytestCheckHook, click, pytest, geopandas
, joblib, matplotlib, numpy, pandas, pygeos, rich, scikit-learn, scipy, seaborn
, shapely, typer, pytest-regressions, hypothesis, fetchPypi, poetry-core
, sphinxHook, pandoc, sphinx-autodoc-typehints, sphinx-rtd-theme, sphinx-gallery
, nbsphinx, notebook, ipython, coverage, powerlaw,

}:

let
  python-ternary = buildPythonPackage rec {
    pname = "python-ternary";
    version = "1.0.8";

    src = fetchPypi {
      inherit pname version;
      sha256 =
        "41e7313db74ab2e24280797ed8073eccad4006429dfd87f6e66e7feba2aa64cd";
    };

    propagatedBuildInputs = [ matplotlib ];

    checkInputs = [ pytestCheckHook pytest ];

    pythonImportsCheck = [ "ternary" ];

    meta = with lib; {
      description = "Make ternary plots in python with matplotlib";
      homepage = "https://github.com/marcharper/python-ternary";
      license = licenses.mit;
      maintainers = with maintainers; [ nialov ];
    };
  };
  # powerlaw = buildPythonPackage {
  #   pname = "powerlaw";
  #   version = "1.5";

  #   src = fetchFromGitHub {
  #     owner = "jeffalstott";
  #     repo = "powerlaw";
  #     # The version at this rev should be aligned to the one at pypi according
  #     # to the commit message.
  #     rev = "6732699d790edbe27c2790bf22c3ef7355d2b07e";
  #     sha256 = "sha256-x3jXk+xOQpIeEGlzYqNwuZNPpkesF0IOX8gUhhwHk5Q=";
  #   };

  #   propagatedBuildInputs = [ scipy numpy matplotlib mpmath ];

  #   postPatch = ''
  #     substituteInPlace testing/test_powerlaw.py \
  #         --replace "reference_data/" "testing/reference_data/"
  #   '';

  #   checkInputs = [ pytest pytestCheckHook ];

  #   pytestFlagsArray = [ "testing" ];

  #   pythonImportsCheck = [ "powerlaw" ];

  #   meta = with lib; {
  #     description =
  #       "Toolbox for testing if a probability distribution fits a power law";
  #     homepage = "http://www.github.com/jeffalstott/powerlaw";
  #     license = licenses.mit;
  #     maintainers = with maintainers; [ nialov ];
  #   };
  # };

  self = buildPythonPackage {
    pname = "fractopo";
    version = "0.6.0";

    src = inputs.fractopo-src;
    format = "pyproject";

    nativeBuildInputs = [
      # Uses poetry for install
      poetry-core
    ];

    passthru = {
      # Enables building package without tests
      # nix build .#fractopo.passthru.no-check
      no-check = self.overridePythonAttrs (_: { doCheck = false; });
      # Documentation without tests
      documentation = self.overridePythonAttrs (prevAttrs: {
        doCheck = false;
        nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [
          # Documentation dependencies
          sphinxHook
          pandoc
          sphinx-autodoc-typehints
          sphinx-rtd-theme
          sphinx-gallery
          nbsphinx
          notebook
          ipython
        ];
        sphinxRoot = "docs_src";
        outputs = [ "out" "doc" ];
      });
    };

    propagatedBuildInputs = [
      click
      geopandas
      joblib
      matplotlib
      numpy
      pandas
      powerlaw
      pygeos
      python-ternary
      rich
      scikit-learn
      scipy
      seaborn
      shapely
      typer
    ];

    checkInputs = [ pytest pytest-regressions hypothesis coverage ];

    # TODO: Should this be precheck or does postInstall affect the docs build as well?
    postInstall = ''
      HOME="$(mktemp -d)"
      export HOME
      FRACTOPO_DISABLE_CACHE="1"
      export FRACTOPO_DISABLE_CACHE
    '';

    checkPhase = ''
      runHook preCheck
      python -m coverage run --source fractopo -m pytest --hypothesis-seed=1
      runHook postCheck
    '';

    postCheck = ''
      python -m coverage report --fail-under 70
    '';

    pythonImportsCheck = [ "fractopo" ];

    meta = with lib; {
      homepage = "https://github.com/nialov/fractopo";
      description = "Fracture Network analysis";
      license = licenses.mit;
      maintainers = [ maintainers.nialov ];
    };
  };
in self
