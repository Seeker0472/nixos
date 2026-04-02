import ../lib/mk-host-module.nix {
  hostFile = ./home.nix;
  extraModules = [
    {
      boot.isContainer = true;
    }
  ];
}
