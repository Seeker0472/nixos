{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.seeker.de.hyprland;
  moduleArgs = {inherit config lib pkgs;};
in {
  # some hack for infinite recursion
  config = lib.mkIf cfg.enable (lib.mkMerge [
    (import ./appearance.nix moduleArgs)
    (import ./hyprland.nix moduleArgs)
    (import ./input.nix moduleArgs)
    (import ./keybind.nix moduleArgs)
    (import ./win_ws.nix moduleArgs)
    (import ./hypridle.nix moduleArgs)
    (import ./autostart.nix moduleArgs)
  ]);
}
