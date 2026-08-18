import ../lib/mk-host-module.nix {
  metaFile = ./meta.nix;
  extraModules = [
    ./samba.nix
    {
      boot.isContainer = true;
    }
  ];
}
