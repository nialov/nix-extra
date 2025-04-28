{ writeShellApplication, jq }:

let
  app = writeShellApplication {
    name = "nix-flake-remote-eval-and-build";
    runtimeInputs = [ jq ];
    text = ''
      flakepath="$(nix flake metadata --json | jq -r '.path')"
      host="$1"
      buildtarget="$2"
      nix flake archive --to ssh://"$host"
      ssh "$host" -- nix build "$flakepath"#"$buildtarget"
    '';

  };
in app
