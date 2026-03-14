{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.machine.home.neteaseMusic.enable = lib.mkEnableOption "Netease Music";
  config = lib.mkMerge [
    (lib.mkIf config.machine.home.neteaseMusic.enable {
      home.packages = [
        pkgs.netease-cloud-music-gtk
      ];
      wayland.windowManager.hyprland.settings = {
        windowrule = [
          "workspace special:music, match:class (com.gitee.gmg137.NeteaseCloudMusicGtk4)"
        ];
        workspace = [
          "special:music, on-created-empty: [ ] netease-cloud-music-gtk4"
        ];
        bind = [
          "$mainMod, N, togglespecialworkspace, music"
        ];
      };
    })
  ];
}
