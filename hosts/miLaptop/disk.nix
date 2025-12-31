{ ... }:
{
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };

  boot.supportedFilesystems = [ "ntfs" ];
  # mount data part
  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "exfat";
    options = [
      "noatime"
      "x-systemd.automount"
    ];
  };

  # FIXME:use TPM for auth
}
