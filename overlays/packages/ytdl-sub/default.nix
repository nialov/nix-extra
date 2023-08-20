{ inputs, lib, python3, ffmpeg, writeText }:

python3.pkgs.buildPythonApplication {
  pname = "ytdl-sub";
  version = inputs.ytdl-sub-src.shortRev;
  format = "setuptools";

  src = inputs.ytdl-sub-src;

  # Add dummy setup.py, remove argparse and strict dependency versions
  # Add ffmpeg from nix to default path
  postPatch = let
    setupPyText = ''
      from setuptools import setup

      setup()
    '';
    setupPy = writeText "setup.py" setupPyText;
  in ''
    substituteInPlace src/ytdl_sub/config/defaults.py \
        --replace 'DEFAULT_FFMPEG_PATH = "/usr/bin/ffmpeg' \
        'DEFAULT_FFMPEG_PATH = "${ffmpeg}/bin/ffmpeg' \
        --replace 'DEFAULT_FFPROBE_PATH = "/usr/bin/ffprobe"' \
        'DEFAULT_FFPROBE_PATH = "${ffmpeg}/bin/ffprobe"'
    substituteInPlace setup.cfg \
        --replace 'argparse==1.4.0' "" \
        --replace 'mergedeep==1.3.4' 'mergedeep' \
        --replace 'mediafile==0.12.0' 'mediafile' \
        --replace 'PyYAML==5.3.1' 'PyYAML' \
        --replace 'yt-dlp==2023.7.6' 'yt-dlp' \
        --replace 'colorama==0.4.6,' 'colorama'
    cp ${setupPy} setup.py
  '';

  propagatedBuildInputs = with python3.pkgs; [
    mediafile
    mergedeep
    pyyaml
    yt-dlp
    colorama
  ];

  buildInputs = [ ffmpeg ];

  pythonImportsCheck = [ "ytdl_sub" ];

  checkInputs = with python3.pkgs; [ pytestCheckHook pytest ];

  disabledTests = [ "test_logger_always_outputs_to_debug_file" ];
  # Skip tests that use the network
  pytestFlagsArray = [
    "--ignore=tests/e2e"
    "--ignore=tests/unit/prebuilt_presets/test_prebuilt_presets.py"
  ];

  meta = with lib; {
    description = "Automate downloading and metadata generation with YoutubeDL";
    homepage = "https://github.com/jmbannon/ytdl-sub";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ nialov ];
  };
}
