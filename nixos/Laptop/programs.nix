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
  # From https://nixos.wiki/wiki/Fish
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  #自启动v2rayA
  # systemd.services.v2rayA = {
  #   description = "AutoStart V2rayA";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "simple";
  #     User = "root";
  #     ExecStart = "${pkgs.v2raya}/bin/v2rayA --lite";
  #     Restart = "on-failure";
  #   };
  # };

  systemd.services.clashverges = {
    description = "AutoStart ClashVergeService";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "simple";
      User = "root";
      ExecStart = "${pkgs.clash-verge-rev}/bin/clash-verge-service";
      Restart = "on-failure";
    };
  };
  # programs.direnv = {
  #   enable = true;
  #   silent = true;
  #   direnvrcExtra = "";
  # };

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
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      fcitx5-chinese-addons
    ];
  };
  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker = {
    enable = true;
    rootless.setSocketVariable = true;
    daemon.settings = {
      data-root = "/etc/docker";
    };
  };
  users.extraGroups.vboxusers.members = [ "seeker" ];
}



