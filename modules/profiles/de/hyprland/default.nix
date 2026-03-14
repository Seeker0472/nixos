{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.de.hyprland;
  moduleArgs = { inherit config lib pkgs; };
  hyprlandModule = import ./conf/hyprland.nix moduleArgs;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home-manager.sharedModules = lib.concatLists [
          (import ./conf/appearance.nix moduleArgs).home-manager.sharedModules
          hyprlandModule.home-manager.sharedModules
          (import ./conf/input.nix moduleArgs).home-manager.sharedModules
          (import ./conf/keybind.nix moduleArgs).home-manager.sharedModules
          (import ./conf/win_ws.nix moduleArgs).home-manager.sharedModules
          (import ./conf/hypridle.nix moduleArgs).home-manager.sharedModules
          (import ./conf/autostart.nix moduleArgs).home-manager.sharedModules
        ];
      }
      (removeAttrs hyprlandModule [ "home-manager" ])
    ]
  );
}
