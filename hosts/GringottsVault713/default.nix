import ../lib/mk-host-module.nix {
  hostFile = ./home.nix;
  extraModules = [
    ./samba.nix
    {
      boot.isContainer = true;
    }
  ];
}
