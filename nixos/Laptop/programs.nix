###################################################################
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
    direnv
    v2raya
    exfat
    # freetype
    gcc
    pulseaudioFull

    # nur.repos.linyinfeng.wemeet
  ];
  #seems Fingerprint didn't work
  #   services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix; #(If the vfs0090 Driver does not work, use the following driver)

  #自启动v2rayA
  systemd.services.v2rayA = {
    description = "AutoStart V2rayA";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      ExecStart = "${pkgs.v2raya}/bin/v2rayA --lite";
      Restart = "on-failure";
    };
  };
  # programs.direnv = {
  #   enable = true;
  #   silent = true;
  #   direnvrcExtra = "";
  # };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  # nixpkgs.config.allowUnfree = true;
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
    # 如果用 fcitx5
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-chinese-addons
    ];
  };
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "seeker" ];
}



