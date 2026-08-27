{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  host = import ./meta.nix;
  sshKeys = import ../../users/seeker/ssh-public-keys.nix;
  adminSshKeys = [ sshKeys.admin ];
in
{
  imports = [
    ./netbird.nix
    ./taskchampion.nix
    inputs.nixvim.nixosModules.nixvim
    ../../modules/profiles/programs/nixvim/default.nix
  ];

  machine.programs.nixvim.enable = true;

  networking = {
    inherit (host) hostName;
    useDHCP = lib.mkDefault true;
    dhcpcd.extraConfig = "noarp";
  };
  system.stateVersion = host.stateVersion;

  machine.disko = host.disk // {
    enable = true;
  };

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];

  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
    qemuGuest.enable = true;
  };

  programs = {
    fish.enable = true;
    nixvim = {
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = "!";
        openssh.authorizedKeys.keys = adminSshKeys;
      };
      seeker = {
        isNormalUser = true;
        uid = 1000;
        description = "Seeker";
        extraGroups = [ "wheel" ];
        hashedPassword = "!";
        shell = pkgs.fish;
        openssh.authorizedKeys.keys = adminSshKeys;
      };
    };
  };
  security.sudo.wheelNeedsPassword = false;

  environment.defaultPackages = lib.mkForce [ ];
  environment.systemPackages = with pkgs; [
    btop
    fd
    file
    htop
    jq
    less
    mtr
    ncdu
    ripgrep
    rsync
    tmux
    tree
    unzip
    zip
  ];
  documentation.enable = false;
  programs.command-not-found.enable = false;

  nix = {
    channel.enable = false;
    settings = {
      connect-timeout = 10;
      fallback = true;
      substituters = lib.mkForce [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
    };
  };

  time.timeZone = "Asia/Shanghai";
}
