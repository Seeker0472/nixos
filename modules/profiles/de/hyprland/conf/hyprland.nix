{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  hyprlandEnabled = lib.attrByPath [
    "machine"
    "de"
    "hyprland"
    "enable"
  ] false osConfig;
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
  config = lib.mkIf hyprlandEnabled (
    lib.mkMerge [
      {
        home.packages = [ pkgs.nwg-displays ]; # set display for hyprland
        wayland.windowManager.hyprland = {
          enable = true;
          systemd.enable = true;
          extraConfig = ''
            # source the nwg-displays generated config
            source = ./monitors.conf
          '';
          settings = {
            "$menu" = "wofi --show drun -a";

            env = [
              "QT_QPA_PLATFORM,wayland;xcb"
              "QT_IM_MODULE,fcitx"
              # "HYPRCURSOR_THEME,default"
              # "HYPRCURSOR_SIZE,24"
            ];

            xwayland = {
              force_zero_scaling = true;
            };
          };
        };
      }
      (
        if impermanenceEnabled && persistDir != null then
          {
            home.persistence."${persistDir}".directories = [
              ".config/hypr"
              ".local/share/hyprland"
            ];
          }
        else
          { }
      )
    ]
  );
}
