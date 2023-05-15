{ inputs, lib, buildGoModule, jq }:

buildGoModule {
  pname = "grok";
  version = "latest";
  name = "grokker";

  src = inputs.grokker-src;
  # src = fetchFromGitHub {
  #   owner = "stevegt";
  #   repo = "grokker";
  #   rev = "a5bf805c23212bc40906d5b440d4642b2066f2ee";
  #   hash = "sha256-Z1I9pFygzgEF39p6H34vWMBNcIEyT7wUM66ObtYYDvM=";
  # };
  # All tests use OpenAI API
  doCheck = false;

  vendorHash = "sha256-5xK2HX7RLfR7UGotydpQIids628qONPlgG+pWGpdIqQ=";

  ldflags = [ "-s" "-w" ];

  installCheckPhase = ''
    $out/bin/grok --help > /dev/null
    $out/bin/grok init
    ${jq}/bin/jq empty .grok
  '';

  meta = with lib; {
    description =
      "A tool for interactive conversation with your own documents and code -- for design, research, and rapid learning.  Uses OpenAI API services for backend";
    homepage = "https://github.com/stevegt/grokker";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ nialov ];
  };
}
