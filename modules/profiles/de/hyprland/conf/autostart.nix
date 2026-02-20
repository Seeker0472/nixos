{
  config,
  lib,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [
    {
      wayland.windowManager.hyprland.settings = {
        exec-once = [
          # TODO: fix these two services
          "systemctl --user restart xdg-desktop-portal.service"
          "systemctl --user restart xdg-desktop-portal-hyprland.service"

          "${pkgs.hypridle}/bin/hypridle" # idle management daemon (TODO screen-lock after wakeup)
          "fcitx5 --replace -d" # if run binary directly,pinyin cannot be activated
          "${pkgs.wpaperd}/bin/wpaperd"
          "systemctl --user start ${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent" # polkit agent (root permission)
          "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store"
          "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store"
          # "ydotoold"
        ]
        ++ lib.lists.optional config.seeker.de.waybar.enable "${pkgs.waybar}/bin/waybar";
      };
    }
  ];
}
