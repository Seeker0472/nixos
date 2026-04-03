{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.homeProfiles.launchers.aloha;
  system = pkgs.stdenv.hostPlatform.system;
  launcherCfg = lib.attrByPath [
    "machine"
    "features"
    "launcher"
    "aloha"
  ] { } osConfig;
  hyprlandEnabled = lib.attrByPath [
    "machine"
    "de"
    "hyprland"
    "enable"
  ] false osConfig;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.aloha = lib.recursiveUpdate cfg.settings {
          enable = true;
          package = if cfg.package != null then cfg.package else inputs.aloha.packages.${system}.default;
        };
      }
      (lib.mkIf (hyprlandEnabled && (launcherCfg.enable or false)) {
        wayland.windowManager.hyprland.settings = {
          "$menu" = lib.mkForce launcherCfg.menuCommand;
          windowrule = lib.mkAfter launcherCfg.windowRules;
        };
      })
    ]
  );
}
