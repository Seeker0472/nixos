import ../lib/mk-host-module.nix {
  metaFile = ./meta.nix;
  extraModules = [
    {
      boot.loader.grub = {
        enable = true;
        device = "nodev";
      };

      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      virtualisation.vmVariantWithBootLoader.virtualisation = {
        cores = 4;
        diskSize = 32 * 1024;
        graphics = false;
        memorySize = 4096;
      };
    }
  ];
}
