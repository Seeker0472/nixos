{ lib, ... }:
{
  homeProfiles = {
    ai.gemini.enable = lib.mkDefault true;
    cli = {
      bash.enable = lib.mkDefault true;
      tmux.enable = lib.mkDefault true;
    };
  };
}
