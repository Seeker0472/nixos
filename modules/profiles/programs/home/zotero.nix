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
  options.homeProfiles.apps.zotero.enable = lib.mkEnableOption "Zotero";
  config = lib.mkMerge [
    (lib.mkIf config.homeProfiles.apps.zotero.enable {
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
      if impermanenceEnabled && persistDir != null then
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
