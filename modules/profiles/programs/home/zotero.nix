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
  options.machine.home.zotero.enable = lib.mkEnableOption "Zotero";
  config = lib.mkMerge [
    (lib.mkIf config.machine.home.zotero.enable {
      home.packages = [
        pkgs.zotero
      ];
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          "workspace special:zotero, match:class (Zotero)"
        ];
        workspace = [
          "special:zotero, on-created-empty: [ ] zotero"
        ];
        bind = [
          "$mainMod, Z, togglespecialworkspace, zotero"
        ];
      };
    })
    (
      if persistDir != null then
        {
          home.persistence."${persistDir}".directories = [
            ".zotero"
            "Zotero"
          ];
        }
      else
        { }
    )
  ];
}
