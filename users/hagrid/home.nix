{ pkgs, ... }:
{
  home.username = "hagrid";
  home.homeDirectory = "/home/hagrid";
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    age
    btop
    curl
    dnsutils
    fastfetch
    fd
    jq
    lazygit
    ncdu
    nix-output-monitor
    ripgrep
    rsync
    sops
    tree
    unzip
    wget
    zip
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    PAGER = "less -FR";
  };

  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "eza -lh --group-directories-first";
      la = "eza -lah --group-directories-first";
      lt = "eza --tree --level=2";
      gs = "git status -sb";
      gl = "git log --oneline --decorate -n 20";
      hm-switch = "home-manager switch --flake ~/nixos-config#hagrid@GringottsVault713";
    };
  };

  programs.bat.enable = true;
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  programs.eza.enable = true;
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };
  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    terminal = "screen-256color";
    extraConfig = ''
      set -g base-index 1
      set -g pane-base-index 1
      set -g history-limit 100000
      setw -g mode-keys vi
      bind r source-file ~/.tmux.conf \; display "tmux reloaded"
    '';
  };
  programs.yazi = {
    enable = true;
    shellWrapperName = "y";
  };
  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };
}
