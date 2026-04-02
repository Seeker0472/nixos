{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  impermanenceEnabled = lib.attrByPath [
    "machine"
    "impermanence"
    "enable"
  ] false osConfig;
  persistDir = lib.attrByPath [
    "machine"
    "btrfs"
    "impermanence"
    "persistdir"
  ] null osConfig;
in
{
  options.homeProfiles.apps.obsidian.enable = lib.mkEnableOption "Obsidian";
  config = lib.mkMerge [
    (lib.mkIf config.homeProfiles.apps.obsidian.enable {
      home.packages = [
        pkgs.obsidian
      ];
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          "workspace special:obsidian, match:class (obsidian)"
        ];
        workspace = [
          "special:obsidian, on-created-empty: [ ] obsidian"
        ];
        bind = [
          "$mainMod, O, togglespecialworkspace, obsidian"
          "$mainMod, D, togglespecialworkspace, obsidian"
        ];
      };
    })
    (
      if impermanenceEnabled && persistDir != null then
        {
          home.persistence."${persistDir}".directories = [
            ".config/obsidian"
          ];
        }
      else
        { }
    )
  ];
}
