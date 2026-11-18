{ self, ... }:
{
  perSystem.treefmt = {
    projectRoot = self;
    programs.nixfmt.enable = true;
    programs.ruff-format.enable = true;
    programs.stylua.enable = true;
    programs.shfmt = {
      enable = true;
      indent_size = 2;
    };
    programs.fish_indent.enable = true;
  };
}
