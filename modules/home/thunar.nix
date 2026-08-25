{
  lib,
  osConfig,
  ...
}:
let
  thunarEnabled = lib.attrByPath [
    "machine"
    "programs"
    "thunar"
    "enable"
  ] false osConfig;
  hyprlandEnabled = lib.attrByPath [
    "machine"
    "de"
    "hyprland"
    "enable"
  ] false osConfig;
in
{
  config = lib.mkIf (thunarEnabled && hyprlandEnabled) {
    wayland.windowManager.hyprland.settings = {
      "$fileManager" = "thunar";
      windowrule = [
        "tag +thunar, match:class (thunar)"
        "float on, match:tag thunar*"
        "center on, match:tag thunar*"
        "size (monitor_w*0.7) (monitor_h*0.7), match:tag thunar*"
        "size (monitor_w*0.5) (monitor_h*0.5), match:tag thunar*,match:title ^(File Operation Progress)$"
        "size (monitor_w*0.5) (monitor_h*0.5), match:tag thunar*,match:title (.*Properties)"
      ];
      bind = [
        "$mainMod, E, exec, $fileManager"
      ];
    };
  };
}
