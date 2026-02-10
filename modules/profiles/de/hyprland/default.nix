{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.seeker.de.hyprland;
  moduleArgs = { inherit config lib pkgs; };
in
{
  # some hack for infinite recursion
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      (import ./conf/appearance.nix moduleArgs)
      (import ./conf/hyprland.nix moduleArgs)
      (import ./conf/input.nix moduleArgs)
      (import ./conf/keybind.nix moduleArgs)
      (import ./conf/win_ws.nix moduleArgs)
      (import ./conf/hypridle.nix moduleArgs)
      (import ./conf/autostart.nix moduleArgs)
      (import ./conf/xdg.nix moduleArgs)
      ({
        # config xdg-desktop-portal service (front-end)
        xdg.portal = {
          enable = true;
          extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
          config = {
            common = {
              default = [ "hyprland" ];
            };
          };
        };
      })
    ]
  );
}
