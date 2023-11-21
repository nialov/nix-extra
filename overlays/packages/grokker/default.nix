{ inputs, lib, buildGoModule, jq }:

buildGoModule {
  pname = "grok";
  version = "latest";
  name = "grokker";

  src = inputs.grokker-src;
  # All tests use OpenAI API
  doCheck = false;

  vendorHash = "sha256-jmKy1GnGmbwcQNDjQoBkUil/xo5dykwzhYjNmlxkYDs=";

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
