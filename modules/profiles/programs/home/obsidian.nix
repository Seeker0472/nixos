{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  options.seeker.home.obsidian.enable = lib.mkEnableOption "Obsidian";
  config = lib.mkMerge [
    (lib.mkIf config.seeker.home.obsidian.enable {
      home.packages = [
        pkgs.obsidian
      ];
      wayland.windowManager.hyprland.settings = {
        windowrulev2 = [
          "workspace special:obsidian, class:(obsidian)"
        ];
        workspace = [
          "special:obsidian, on-created-empty: [ ] obsidian"
        ];
        bind = [
          "$mainMod, O, togglespecialworkspace, obsidian"
        ];
      };
    })
    {
      home.persistence."${osConfig.seeker.btrfs.impermanence.persistdir}/home/${config.home.username}".directories =
        [
          ".config/obsidian"
        ];
    }
  ];
}
