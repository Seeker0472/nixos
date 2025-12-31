{
  pkgs,
  lib,
  config,
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
        windowrulev2 = [
          "workspace special:zotero, class:(Zotero)"
        ];
        workspace = [
          "special:zotero, on-created-empty: [ ] zotero"
        ];
        bind = [
          "$mainMod, Z, togglespecialworkspace, zotero"
        ];
      };
    })
  ];
}
