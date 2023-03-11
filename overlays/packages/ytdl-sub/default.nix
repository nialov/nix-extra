{ inputs, lib, python3, ffmpeg }:

python3.pkgs.buildPythonApplication {
  pname = "ytdl-sub";
  version = inputs.ytdl-sub-src.shortRev;
  format = "setuptools";

  src = inputs.ytdl-sub-src;
  # src = fetchFromGitHub {
  #   owner = "jmbannon";
  #   repo = "ytdl-sub";
  #   rev = version;
  #   hash = "sha256-E6FrlB+MDGWh5yi+ZYoi5Jk6KrQ0XIxU8LgySViLx6Y=";
  # };
  # Add dummy setup.py, remove argparse and strict dependency versions
  patches = [ ./setup.patch ];

  # Add ffmpeg from nix to default path
  postPatch = ''
    substituteInPlace src/ytdl_sub/config/config_validator.py \
        --replace '_DEFAULT_FFMPEG_PATH = "/usr/bin/ffmpeg' \
        '_DEFAULT_FFMPEG_PATH = "${ffmpeg}/bin/ffmpeg' \
        --replace '_DEFAULT_FFPROBE_PATH = "/usr/bin/ffprobe"' \
        '_DEFAULT_FFPROBE_PATH = "${ffmpeg}/bin/ffprobe"'
  '';

  propagatedBuildInputs = with python3.pkgs; [
    mediafile
    mergedeep
    pyyaml
    yt-dlp
  ];

  buildInputs = [ ffmpeg ];

  pythonImportsCheck = [ "ytdl_sub" ];

  checkInputs = with python3.pkgs; [ pytestCheckHook pytest ];

  disabledTests = [ "test_logger_always_outputs_to_debug_file" ];
  # Skip tests that use the network
  pytestFlagsArray = [ "--ignore=tests/e2e" ];

  meta = with lib; {
    description = "Automate downloading and metadata generation with YoutubeDL";
    homepage = "https://github.com/jmbannon/ytdl-sub";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ nialov ];
  };
}
