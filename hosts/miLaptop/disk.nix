{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{

  config = {
    machine.btrfs.impermanence = {
      enable = true;
      luksName = "crypted";
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NU0W123827";
      retentionDays = 30;
      allowDiscards = true;
      resumeDevice = "/dev/mapper/crypted";
      resumeOffset = 533760;
      luksKeyFile = "/tmp/secret.key";
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

    fileSystems."${config.machine.btrfs.impermanence.persistdir}".neededForBoot = true;
    environment.persistence."${config.machine.btrfs.impermanence.persistdir}" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/var/lib/docker"
        "/var/lib/private/mihomo"
        "/etc/ssh"
      ];
      files = [
        "/etc/machine-id"
      ];
      users.${config.machine.mainUser} = {
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
