{ config, ... }:
{
  plugins.treesitter = {
    enable = true;
    folding.enable = true;
    highlight.enable = true;
    indent.enable = true;
    grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
      bash
      json
      lua
      markdown
      markdown_inline
      nix
      query
      regex
      toml
      vim
      vimdoc
      yaml
    ];
  };

  opts = {
    foldenable = true;
    foldlevel = 99;
    foldlevelstart = 99;
  };
}
