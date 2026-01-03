{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{

  config = {
    seeker.btrfs.impermanence = {
      enable = true;
      luksName = "crypted";
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NU0W123827";
      retentionDays = 30;
      allowDiscards = true;
    };
    boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
    };
    boot.initrd.availableKernelModules = [
      "tpm_crb"
    ];

    boot.supportedFilesystems = [
      "ntfs"
      "exfat"
    ];

    fileSystems."${config.seeker.btrfs.impermanence.persistdir}".neededForBoot = true;
    environment.persistence."${config.seeker.btrfs.impermanence.persistdir}" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/var/lib/docker"
        "/var/lib/private/mihomo"
      ];
      files = [
        "/etc/machine-id"
      ];
      users.seeker = {
        directories = [
          "nixos-config"
          "age"
          ".local/share/z"
          "Develop"
          # QQ/Wechat

          ".mozilla"
        ];
      };
    };
  };
}
