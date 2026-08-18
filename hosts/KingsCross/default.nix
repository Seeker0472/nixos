{
  lib,
  ...
}:
let
  host = import ./meta.nix;
  adminSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9S/WUjiDke+EhHCWI0ZstCRBwvSljPxWxqbXzrKYDi seeker@DiagonAlley";
in
{
  networking = {
    hostName = host.hostName;
    useDHCP = lib.mkDefault true;
    dhcpcd.extraConfig = "noarp";
    firewall.enable = true;
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

  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = "!";
        openssh.authorizedKeys.keys = [ adminSshKey ];
      };
      seeker = {
        isNormalUser = true;
        uid = 1000;
        description = "Seeker";
        extraGroups = [ "wheel" ];
        hashedPassword = "!";
        openssh.authorizedKeys.keys = [ adminSshKey ];
      };
    };
  };
  security.sudo.wheelNeedsPassword = false;

  environment.defaultPackages = lib.mkForce [ ];
  documentation.enable = false;
  programs.command-not-found.enable = false;

  nix = {
    channel.enable = false;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      auto-optimise-store = true;
      connect-timeout = 10;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      fallback = true;
      substituters = lib.mkForce [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
    };
  };

  time.timeZone = "Asia/Shanghai";
}
