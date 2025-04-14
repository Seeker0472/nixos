{ config, lib, pkgs, modulesPath, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];
  # mount data part
  fileSystems."/Data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "exfat";
  };
}
