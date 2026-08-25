import ../lib/mk-host-module.nix {
  metaFile = ./meta.nix;
  extraModules = [
    ./disk.nix
    ./hardware-configuration.nix
  ];
}
