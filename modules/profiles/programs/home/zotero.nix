{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  options.seeker.home.zotero.enable = lib.mkEnableOption "Zotero";
  config = lib.mkMerge [
    (lib.mkIf config.seeker.home.zotero.enable {
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
    {
      home.persistence."${osConfig.seeker.btrfs.impermanence.persistdir}".directories = [
        ".zotero"
        "Zotero"
      ];
    }
  ];
}
