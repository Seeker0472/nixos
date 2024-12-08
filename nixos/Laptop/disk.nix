{ config, lib, pkgs, modulesPath, ... }:
{
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {

      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      # Win10 Disk
      extraEntries = ''
        menuentry "Windows 10" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --fs-uuid --set=root F260-6DA1 
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };
  boot.supportedFilesystems = [ "ntfs" ];
  # mount data part
  fileSystems."/Data" =
    {
      device = "/dev/disk/by-label/Data";
      fsType = "exfat";
    };
}
