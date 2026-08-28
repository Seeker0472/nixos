{
  lib,
  ...
}:
{
  programs = {
    bash.enable = true;
    codex.enable = lib.mkDefault true;
    direnv.enable = true;
    fish.enable = true;
    tmux.enable = true;
    yazi.enable = true;
    zellij.enable = true;
  };
}
