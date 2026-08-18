{
  lib,
  pkgs,
  ...
}:
{
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];

  boot.loader.grub.enable = true;

  networking = {
    hostName = "vps";
    useDHCP = lib.mkDefault true;
    dhcpcd.extraConfig = "noarp";
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN9S/WUjiDke+EhHCWI0ZstCRBwvSljPxWxqbXzrKYDi seeker@DiagonAlley"
  ];

  services.qemuGuest.enable = true;

  nix = {
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = lib.mkForce [
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://cache.nixos.org"
      ];
      connect-timeout = 10;
      fallback = true;
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    git
    vim
  ];

  time.timeZone = "Asia/Shanghai";
  system.stateVersion = "26.05";
}
