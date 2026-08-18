{ config, lib, ... }:
{
  config = lib.mkIf config.programs.tmux.enable {
    home.file = {
      ".tmux.conf".source = ./tmux.conf;
      ".tmux.conf.local".source = ./tmux.conf.local;
    };
  };
}
