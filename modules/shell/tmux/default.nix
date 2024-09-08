{pkgs, ...}:{
  programs.tmux = {
    enable = true;
#     # shortcut = "a";
#     terminal = "screen-256color";
#     plugins =[];
#     historyLimit = 10000;
#     extraConfig = ''
# '';
    };
  home.file.".tmux.conf".source = ./.tmux.conf;
  home.file.".tmux.conf.local".source = ./.tmux.conf.local;
  # These files copied from oh-my-tmux
}