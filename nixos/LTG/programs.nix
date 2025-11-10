# ##################################################################
#  system software and it's configuration
###################################################################

{ config, lib, pkgs, modulesPath, ... }:

{
  # List packages installed in system profile. To search, run:
  # 启用 Flakes 特性以及配套的新 nix 命令行工具
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    python3
    nix-ld
    # direnv
    fish
    # v2raya
    exfat
    # gcc
    # gdb
    pulseaudioFull
    firefox
    tailscale
  ];

  # 启用 OpenSSH 后台服务
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = true; # enable password login
    };
    openFirewall = true;
  };

  #input method
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons ];
  };
  virtualisation.docker = {
    enable = true;
    # speed-up boot process ,maybe `--restart=always` won't work
    enableOnBoot = false;
    rootless.setSocketVariable = true;
    daemon.settings = { data-root = "/etc/docker"; };
  };
}

