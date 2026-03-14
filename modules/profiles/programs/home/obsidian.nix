{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  persistDir = lib.attrByPath [
    "machine"
    "btrfs"
    "impermanence"
    "persistdir"
  ] null osConfig;
in
{
  options.machine.home.obsidian.enable = lib.mkEnableOption "Obsidian";
  config = lib.mkMerge [
    (lib.mkIf config.machine.home.obsidian.enable {
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
      if persistDir != null then
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
