{
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  hyprlandEnabled = lib.attrByPath [
    "machine"
    "de"
    "hyprland"
    "enable"
  ] false osConfig;
in
{
  config = lib.mkIf hyprlandEnabled {
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
      ++ lib.lists.optional
        (lib.attrByPath [
          "machine"
          "de"
          "waybar"
          "enable"
        ] false osConfig)
        "${pkgs.waybar}/bin/waybar";
    };
  };
}
