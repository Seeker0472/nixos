# Rename into rules
{ ... }:
{
  home-manager.sharedModules = [
    {
      # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules
      # TODO!

      wayland.windowManager.hyprland.settings = {
        windowrulev2 = [
          # FIXME:move them out!!!

          # Fcitx / Input
          "pin, initialClass:(.*fcitx.*)"

          # 无边框/阴影规则 (HMCL, Wemeet)

          "noborder, initialClass:^(org\\.jackhuang\\.hmcl\\.Launcher)$"
          "noshadow, initialClass:^(org\\.jackhuang\\.hmcl\\.Launcher)$"
          "noblur, initialClass:^(org\\.jackhuang\\.hmcl\\.Launcher)$"
          # "noborder, initialClass:^(wemeetapp)$"
          # "noshadow, initialClass:^(wemeetapp)$"
          # "noblur, initialClass:^(wemeetapp)$"
          # "pin, initialClass:^(wemeetapp)$"

          # 其他
          "suppressevent maximize, class:.*"
          # "fullscreen, class:Waydroid"
          # "fullscreen, class:waydroid.*"

          # 将特定应用分配到特殊工作区
          # "workspace special:waydroid, class:(Waydroid)"
          # "workspace special:waydroid, class:(waydroid.*)"
        ];

        windowrule = [
          # "noinitialfocus, class:(jetbrains-.*), title:^win(.*)"
          # "noinitialfocus, class:(org.jackhuang.hmcl.Launcher)"
        ];

        workspace = [
          "1, defaultName: 1, border:1, rounding:0, gapsin:0, gapsout:0, on-created-empty: [ ] kitty"
          "2, defaultName: 2, border:1, rounding:0, gapsin:0, gapsout:0, on-created-empty: [ ] kitty"
          "3, defaultName:󰭠 3"
          "4, defaultName:󰭠 4"
          "5, defaultName:󰭠 5"
          "6, defaultName:󰭠 6"
          "7, defaultName:󰭠 7"
          "8, defaultName:󰭠 8"
          "9, defaultName:󰭠 9"

          "200, defaultName:󰰷, on-created-empty: [ ] zen"
          "201, defaultName:󰨞, on-created-empty: [ ] code"

          # "special:waydroid, on-created-empty: [ ] waydroid show-full-ui"
        ];
      };
    }
  ];
}
