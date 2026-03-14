{ pkgs, ... }:
let
  host = import ./home.nix;
in
{
  imports = [
    ./disk.nix
    ./hardware-configuration.nix
    ./options.nix
    ./programs.nix
  ];
  networking.hostName = host.hostName;
  system.stateVersion = host.stateVersion; # DoNot change
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ENV{ID_PATH}=="platform-i8042-serio-0", RUN+="${pkgs.kbd}/bin/setkeycodes e072 183"
  '';
}
