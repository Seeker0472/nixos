_: {
  machine.disko = {
    enable = true;
    device = "/dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MJ86N833110606T20";
    bootMode = "uefi";
    efiCanTouchVariables = true;
    rootLabel = "nixos-burrow";
  };

  boot.loader.grub.configurationLimit = 5;
}
