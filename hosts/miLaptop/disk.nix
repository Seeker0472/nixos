{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  mainUser = config.machine.mainUser;
  mainUserGroup = config.users.users.${mainUser}.group;
  persistHome = "${config.machine.btrfs.impermanence.persistdir}/home/${mainUser}";
in
{

  config = {
    machine.btrfs.impermanence = {
      luksName = "crypted";
      device = "/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNA0K906073";
      retentionDays = 30;
      allowDiscards = true;
      resumeDevice = null;
      resumeOffset = null;
      luksKeyFile = null;
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
        "/var/lib/NetworkManager"
        "/var/lib/cups"
        "/etc/NetworkManager/system-connections"
        "/var/lib/docker"
        "/var/lib/private/mihomo"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
      users.${config.machine.mainUser} = {
        directories = [
          "nixos-config"
          {
            directory = ".config";
            mode = "0755";
          }
          {
            directory = ".config/sops";
            mode = "0700";
          }
          {
            directory = ".config/sops/age";
            mode = "0700";
          }
          ".local/share/z"
          "Develop"
          # QQ/Wechat

          ".mozilla"
        ];
      };
    };

    # Existing persistence trees keep their old ownership; repair only the
    # user-owned SOPS/config boundary before Home Manager starts.
    systemd.tmpfiles.rules = [
      "d ${persistHome}/.config 0755 ${mainUser} ${mainUserGroup} -"
      "z ${persistHome}/.config 0755 ${mainUser} ${mainUserGroup} -"
      "d ${persistHome}/.config/sops 0700 ${mainUser} ${mainUserGroup} -"
      "z ${persistHome}/.config/sops 0700 ${mainUser} ${mainUserGroup} -"
      "d ${persistHome}/.config/sops/age 0700 ${mainUser} ${mainUserGroup} -"
      "z ${persistHome}/.config/sops/age 0700 ${mainUser} ${mainUserGroup} -"
      "z ${persistHome}/.config/sops/age/keys.txt 0600 ${mainUser} ${mainUserGroup} -"
    ];

  };
}
