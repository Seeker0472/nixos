{
  config,
  pkgs,
  ...
}: let
in {
  home-manager.sharedModules = [
    ({config, ...}: let
      tmux_conf_base = "${config.home.homeDirectory}/nixos-config/modules/shell/tmux";
      tmuxconfig_path = "${tmux_conf_base}/tmux.conf";
      tmuxlocal_path = "${tmux_conf_base}/tmux.conf.local";
    in {
      programs.tmux = {
        enable = true;
        #     # shortcut = "a";
        #     terminal = "screen-256color";
        #     plugins =[];
        #     historyLimit = 10000;
        #     extraConfig = ''
        # '';
      };

      home.file.".tmux.conf".source =
        config.lib.file.mkOutOfStoreSymlink tmuxconfig_path;
      home.file.".tmux.conf.local".source =
        config.lib.file.mkOutOfStoreSymlink tmuxlocal_path;
    })
  ];
}
