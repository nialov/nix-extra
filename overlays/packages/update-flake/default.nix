{ writeShellApplication, gum, git, ripgrep }:
writeShellApplication {
  name = "update-flake";
  runtimeInputs = [ gum git ripgrep ];
  text = builtins.readFile ./update-flake.sh;

}
