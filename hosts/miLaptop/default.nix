import ../lib/mk-host-module.nix {
  hostFile = ./home.nix;
  extraModules = [
    ./disk.nix
    ./hardware-configuration.nix
    ./programs.nix
    (
      { pkgs, ... }:
      {
        services.udev.extraRules = ''
          ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_PATH}=="platform-i8042-serio-0", RUN+="${pkgs.kbd}/bin/setkeycodes e072 183"
        '';
      }
    )
  ];
}
