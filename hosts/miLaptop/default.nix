{ pkgs, ... }:
{
  imports = [
    ./disk.nix
    ./hardware-configuration.nix
    ./options.nix
  ];
  networking.hostName = "miLaptop";
  system.stateVersion = "24.05"; # DoNot change
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_PATH}=="platform-i8042-serio-0", RUN+="${pkgs.kbd}/bin/setkeycodes e072 148"
  '';
}
