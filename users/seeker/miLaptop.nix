{
  config,
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  impermanenceEnabled = lib.attrByPath [ "machine" "impermanence" "enable" ] false osConfig;
  persistDir = lib.attrByPath [ "machine" "btrfs" "impermanence" "persistdir" ] null osConfig;
in
{
  imports = [
    ./desktop.nix
    ./ssh-secrets.nix
  ];

  config = lib.mkMerge [
    {
      programs.aloha = {
        enable = true;
        package = inputs.aloha.packages.${pkgs.stdenv.hostPlatform.system}.default;
        kitty = {
          title = "Aloha";
          class = "AlohaLauncher";
        };
        fzf.extraOptions = [
          "--layout=reverse"
          "--height=60%"
        ];
        roots = {
          apps = {
            prompt = "Apps> ";
            sources = [ { type = "desktop"; } ];
          };
          commands = {
            prompt = "Commands> ";
            sources = [
              {
                type = "static";
                items = [
                  {
                    id = "command-terminal";
                    label = "Terminal";
                    action = "exec";
                    command = "${pkgs.kitty}/bin/kitty";
                  }
                  {
                    id = "command-display-settings";
                    label = "Display Settings";
                    action = "exec";
                    command = "${pkgs.nwg-displays}/bin/nwg-displays";
                  }
                  {
                    id = "command-next-wallpaper";
                    label = "Next Wallpaper";
                    action = "exec";
                    command = "${pkgs.wpaperd}/bin/wpaperctl next-wallpaper";
                  }
                  {
                    id = "command-reload-hyprland";
                    label = "Reload Hyprland";
                    action = "exec";
                    command = "${pkgs.hyprland}/bin/hyprctl reload";
                  }
                  {
                    id = "command-brightness";
                    label = "Brightness";
                    action = "provider-submenu";
                    provider = "brightness";
                    providerArgs.levels = [
                      10
                      25
                      50
                      75
                      100
                    ];
                  }
                ];
              }
            ];
          };
          power = {
            prompt = "Power> ";
            sources = [
              {
                type = "static";
                items = [
                  {
                    id = "power-lock";
                    label = "Lock";
                    action = "exec";
                    command = "${pkgs.hyprlock}/bin/hyprlock";
                  }
                  {
                    id = "power-poweroff";
                    label = "Poweroff";
                    action = "builtin-action";
                    builtin = "poweroff";
                  }
                  {
                    id = "power-reboot";
                    label = "Reboot";
                    action = "builtin-action";
                    builtin = "reboot";
                  }
                  {
                    id = "power-suspend";
                    label = "Suspend";
                    action = "builtin-action";
                    builtin = "suspend";
                  }
                  {
                    id = "power-hibernate";
                    label = "Hibernate";
                    action = "builtin-action";
                    builtin = "hibernate";
                  }
                  {
                    id = "power-suspend-then-hibernate";
                    label = "Suspend Then Hibernate";
                    action = "builtin-action";
                    builtin = "suspend-then-hibernate";
                  }
                ];
              }
            ];
          };
        };
      };

      wayland.windowManager.hyprland.settings = {
        "$menu" = lib.mkForce "aloha --root apps";
        bind = lib.mkAfter [
          "$mainMod, P, exec, aloha --root commands"
          "$mainMod SHIFT, P, exec, aloha --root power"
        ];
        bindl = lib.mkAfter [
          '', switch:off:Lid Switch, execr, [ $(hyprctl monitors | grep -c "eDP-1") -ne 1 ] && hyprctl keyword monitor eDP-1,2560x1600@120.0,0x237,1.33''
          '', switch:on:Lid Switch, execr, [ $(hyprctl monitors | grep -c "ID") -ne 1 ] && hyprctl keyword monitor eDP-1,disable''
        ];
        windowrule = lib.mkAfter [
          "tag +aloha_launcher, match:initial_class ^(AlohaLauncher)$"
          "float on, match:tag aloha_launcher*"
          "center on, match:tag aloha_launcher*"
          "size (monitor_w*0.7) (monitor_h*0.6), match:tag aloha_launcher*"
        ];
      };
    }

    (lib.mkIf (impermanenceEnabled && persistDir != null) {
      home.persistence."${persistDir}" = {
        directories = [
          "Downloads"
          "Documents"
          "Pictures"
          "Videos"
          ".ssh"
          ".gnupg"
          ".factorio"
          ".local/share/fish"
          ".local/share/direnv"
          ".local/share/fcitx5"
          ".config/fcitx5"
          ".config/dconf"
          ".config/hypr"
          ".local/share/hyprland"
          ".local/state/nvim"
          ".config/kdeconnect"
          ".config/obsidian"
          ".vscode"
          ".config/Code"
          ".local/share/keyrings"
          ".local/share/zed"
          ".config/zen"
          ".zotero"
          "Zotero"
        ];
        files = [
          ".gtkwaverc"
          ".local/bin/bitlesson-selector"
        ];
      };
    })
  ];
}
