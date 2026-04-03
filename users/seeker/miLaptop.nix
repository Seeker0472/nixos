{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  launcherCfg = lib.attrByPath [
    "machine"
    "features"
    "launcher"
    "aloha"
  ] { } osConfig;
in
{
  config = lib.mkIf (launcherCfg.enable or false) {
    homeProfiles.launchers.aloha = {
      enable = true;
      package = inputs.aloha.packages.${pkgs.stdenv.hostPlatform.system}.default;
      settings = {
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
    };
  };
}
