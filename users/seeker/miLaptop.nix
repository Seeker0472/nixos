{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  isMiLaptop = osConfig.networking.hostName == "miLaptop";
  hyprlandEnabled = lib.attrByPath [
    "machine"
    "de"
    "hyprland"
    "enable"
  ] false osConfig;
in
{
  config = lib.mkIf isMiLaptop (
    lib.mkMerge [
      {
        programs.aloha = {
          enable = true;

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
              sources = [
                {
                  type = "desktop";
                }
              ];
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
                      providerArgs = {
                        levels = [
                          10
                          25
                          50
                          75
                          100
                        ];
                      };
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
      }
      (lib.mkIf hyprlandEnabled {
        wayland.windowManager.hyprland.settings = {
          "$menu" = lib.mkForce "aloha --root apps";

          windowrule = lib.mkAfter [
            "tag +aloha_launcher, match:initial_class ^(AlohaLauncher)$"
            "float on, match:tag aloha_launcher*"
            "center on, match:tag aloha_launcher*"
            "size (monitor_w*0.7) (monitor_h*0.6), match:tag aloha_launcher*"
          ];
        };
      })
    ]
  );
}
