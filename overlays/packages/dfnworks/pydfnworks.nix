{ inputs, lib, stdenv, python3, lagrit, fehm, pflotran, symlinkJoin, makeWrapper
, runCommand }:

let
  # TODO: Make a patch instead of this mess of edits...
  # In the patch, revise the subprocess.call to subprocess.run and make
  # a proper error print logic
  # TODO: Revise plain excepts
  patchedSrc = runCommand "patched-src" { } ''
    cp --dereference --no-preserve all --recursive ${inputs.dfnworks-src} $out
    substituteInPlace $out/pydfnworks/pydfnworks/dfnGen/meshing/mesh_dfn/run_meshing.py \
        --replace "    quiet=True)" "    quiet=True).returncode != 0"  \
        --replace "except:" "except Exception:"  
    substituteInPlace $out/pydfnworks/pydfnworks/dfnGen/meshing/mesh_dfn/mesh_dfn_helper.py \
        --replace "failure = subprocess.call(cmd, shell=True)" "failure = subprocess.run(cmd, shell=True, capture_output=True, check=True); print(failure)"  \
        --replace "if failure" "if False"  
    substituteInPlace $out/pydfnworks/pydfnworks/dfnFlow/pflotran.py \
        --replace "except:" "except Exception:" \
        --replace "subprocess.call(cmd, shell=True)" "subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)" \
        --replace "if failure > 0" "if False" \
        --replace "-np ' + str(self.ncpu)" "'" \
        --replace "error =" "raise; error ="
  '';

  self = python3.pkgs.buildPythonPackage {
    pname = "pydfnworks";
    version = inputs.dfnworks-src.shortRev;

    src = patchedSrc;
    passthru.src = patchedSrc;

    nativeBuildInputs = [ python3.pkgs.setuptools ];

    propagatedBuildInputs = with python3.pkgs; [
      numpy
      scipy
      matplotlib
      mplstereonet
      fpdf
      pyvtk
      pflotran.passthru.h5py
      networkx
      seaborn
      mpmath
    ];

    checkInputs = with python3.pkgs; [ nose ];

    postPatch = ''
      substituteInPlace ./pydfnworks/pydfnworks/release.py \
        --replace "datetime" ""
      cd ./pydfnworks
    '';

    meta = with lib; {
      description = "";
      homepage = "https://dfnworks.lanl.gov/";
      license = licenses.gpl3Only;
      maintainers = with maintainers; [ nialov ];
    };
  };

in self
