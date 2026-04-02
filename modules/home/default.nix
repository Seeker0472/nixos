{
  lib,
  pkgs,
  ...
}:
let
  customCursor = {
    name = "Bibata-Modern-Amber";
    package = pkgs.bibata-cursors;
    size = 32;
  };
in
{
  imports = [
    ../profiles/de/map.nix
    ../profiles/de/waybar/default.nix
    ../profiles/de/hyprland/conf/appearance.nix
    ../profiles/de/hyprland/conf/hyprland.nix
    ../profiles/de/hyprland/conf/input.nix
    ../profiles/de/hyprland/conf/keybind.nix
    ../profiles/de/hyprland/conf/win_ws.nix
    ../profiles/de/hyprland/conf/hypridle.nix
    ../profiles/de/hyprland/conf/autostart.nix
    ../profiles/impermanence/home.nix
    ../profiles/input/map.nix
    ../profiles/sops/default.nix
    ../profiles/programs/home/bash.nix
    ../profiles/programs/home/claude/default.nix
    ../profiles/programs/home/direnv.nix
    ../profiles/programs/home/fish.nix
    ../profiles/programs/home/geminicli/default.nix
    ../profiles/programs/home/kitty.nix
    ../profiles/programs/home/neteaseMusic.nix
    ../profiles/programs/home/obsidian.nix
    ../profiles/programs/home/qq.nix
    ../profiles/programs/home/tmux/default.nix
    ../profiles/programs/home/vscode.nix
    ../profiles/programs/home/wechat.nix
    ../profiles/programs/home/yazi.nix
    ../profiles/programs/home/zed.nix
    ../profiles/programs/home/zen.nix
    ../profiles/programs/home/zotero.nix
    ./kde-connect.nix
    ./thunar.nix
    (
      {
        config,
        lib,
        osConfig,
        ...
      }:
      let
        deCfg = lib.attrByPath [
          "machine"
          "de"
        ] { } osConfig;
      in
      lib.mkIf (deCfg.hyprland.enable or false) {
        wayland.windowManager.hyprland = {
          enable = true;
          settings.exec-once = [
            "hyprctl setcursor ${customCursor.name} ${builtins.toString customCursor.size}"
          ];
        };

        home.pointerCursor = {
          inherit (customCursor) name package size;
          gtk.enable = true;
          x11.enable = true;
        };

        gtk = {
          enable = true;
          theme = {
            package = pkgs.kdePackages.breeze-gtk;
            name = "Breeze";
          };
          iconTheme = {
            package = pkgs.kdePackages.breeze-icons;
            name = "breeze";
          };
          gtk4.theme = config.gtk.theme;
        };

        services.mako.enable = deCfg.mako.enable or false;
      }
    )
  ];
}
