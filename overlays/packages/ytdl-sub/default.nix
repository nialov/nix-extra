{ inputs, lib, python3, ffmpeg }:

python3.pkgs.buildPythonApplication {
  pname = "ytdl-sub";
  version = inputs.ytdl-sub-src.shortRev;
  format = "pyproject";

  src = inputs.ytdl-sub-src;

  # Add ffmpeg from nix to default path
  postPatch = ''
    substituteInPlace src/ytdl_sub/config/defaults.py \
        --replace-fail 'DEFAULT_FFMPEG_PATH = "/usr/bin/ffmpeg' \
        'DEFAULT_FFMPEG_PATH = "${ffmpeg}/bin/ffmpeg' \
        --replace-fail 'DEFAULT_FFPROBE_PATH = "/usr/bin/ffprobe"' \
        'DEFAULT_FFPROBE_PATH = "${ffmpeg}/bin/ffprobe"'
  '';

  propagatedBuildInputs = with python3.pkgs; [
    mediafile
    mergedeep
    pyyaml
    yt-dlp
    colorama
  ];

  buildInputs = [ ffmpeg ];
  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
    python3.pkgs.pythonRelaxDepsHook
  ];
  pythonRelaxDeps = true;

  pythonImportsCheck = [ "ytdl_sub" ];

  checkInputs = with python3.pkgs; [ pytestCheckHook pytest ];

  disabledTests = [
    "test_logger_always_outputs_to_debug_file"
    "test_logger_can_be_cleaned_during_execution"
    "test_no_config_works"
  ];
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
