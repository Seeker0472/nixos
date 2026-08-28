import ../lib/mk-host-module.nix {
  metaFile = ./meta.nix;
  extraModules = [
    ./disk.nix
    ./hardware-configuration.nix
    ./networking.nix
    {
      programs.nixvim = {
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
      };
    }
  ];
}
