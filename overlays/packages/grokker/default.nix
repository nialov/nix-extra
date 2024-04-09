{ inputs, lib, buildGoModule, jq }:

buildGoModule {
  pname = "grok";
  version = "latest";
  name = "grokker";

  src = inputs.grokker-src;
  # All tests use OpenAI API
  postPatch = ''
    cd v3/
  '';
  doCheck = false;

  vendorHash = "sha256-AEZzHNHSkAF1GG9PXh92oMQMtLUeAXbXxjGg0v7K/u8=";

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
