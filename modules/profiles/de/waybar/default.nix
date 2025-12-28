{ config, pkgs, ... }:

let
  # 预定义所有用到的二进制文件路径
  grep = "${pkgs.gnugrep}/bin/grep";
  awk = "${pkgs.gawk}/bin/awk";
  xargs = "${pkgs.findutils}/bin/xargs";
  kill = "${pkgs.coreutils}/bin/kill";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  kitty = "${pkgs.kitty}/bin/kitty";
  nmcli = "${pkgs.networkmanager}/bin/nmcli";
  nmtui = "${pkgs.networkmanager}/bin/nmtui-connect";
  btop = "${pkgs.btop}/bin/btop";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  nvim = "${pkgs.neovim}/bin/nvim";
  bluetuith = "${pkgs.bluetuith}/bin/bluetuith";
  wpaperctl = "${pkgs.wpaperctl}/bin/wpaperctl";

  killRTG = "${hyprctl} clients | ${grep} 'class: RTG$' -A 5 | ${grep} 'pid:' | ${awk} '{print $2}' | ${xargs} -r ${kill} -9";
in
{
  home.file.".config/waybar/style.css".source = "./style.css";
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ ];
        modules-right = [
          "custom/lrc"
          "cava"
          "custom/gotobed"
          "group/sysinfo"
          "group/control"
          "pulseaudio"
          "clock"
          "tray"
        ];

        "group/sysinfo" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 500;
            children-class = "not-power";
            transition-left-to-right = false;
          };
          modules = [
            "battery"
            "temperature"
            "cpu"
            "memory"
          ];
        };

        "group/control" = {
          orientation = "inherit";
          drawer = {
            transition-duration = 500;
            children-class = "not-power";
            transition-left-to-right = false;
          };
          modules = [
            "network"
            "custom/wallpaper"
            "bluetooth"
            "backlight"
          ];
        };

        # TODO:add self-defined symbol to show machine status bluetooth,etc.
        # module configs

        "pulseaudio" = {
          scroll-step = 1;
          format = "{volume}% {icon}";
          format-alt = "{format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = "  {icon} {format_source}";
          format-muted = "  {format_source}";
          format-source = "{volume}% ";
          format-source-muted = " ";
          format-icons = {
            headphone = " ";
            hands-free = " ";
            headset = "󰋌 ";
            phone = " ";
            "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink" = [
              "  "
              "  "
              "  "
            ];
            default = [
              "  "
              "  "
              "  "
            ];
          };
          on-click-right = "${pavucontrol}";
        };

        "cava" = {
          # "cava_config" = "/home/seeker/.config/cava/config_bar";
          framerate = 30;
          autosens = 1;
          sensitivity = 5;
          bars = 14;
          lower_cutoff_freq = 100;
          higher_cutoff_freq = 1000;
          method = "pulse";
          source = "auto";
          stereo = true;
          reverse = false;
          bar_delimiter = 0;
          monstercat = false;
          waves = false;
          noise_reduction = 0.77;
          input_delay = 2;
          format-icons = [ "▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
          actions = {
            on-click-right = "mode";
          };
        };

        "network" = {
          format-wifi = "{essid} ({signalStrength}%)  ";
          format-ethernet = "{ipaddr}/{cidr}  ";
          tooltip-format = "{ifname} via {gwaddr} 󰩠 {ipaddr}";
          format-linked = "{ifname} (No IP) 󰛵 ";
          format-disconnected = "Disconnected  ";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          # 使用绝对路径引用所有命令
          on-click-right = "${killRTG} && ${nmcli} device wifi rescan && ${kitty} -o font_size=14 -o confirm_os_window_close=0 --class RTG ${nmtui}";
        };

        "cpu" = {
          states = {
            warning = 50;
            high = 80;
          };
          format = "{usage}%  ";
          tooltip = false;
          on-click-right = "${killRTG} && ${kitty} -o font_size=14 -o confirm_os_window_close=0 --class RTG ${btop}";
        };

        "memory" = {
          states = {
            warning = 50;
            high = 80;
          };
          format = "{}%  ";
          tooltip-format = "{used:0.1f}/{total:0.1f}GiB Mem \n{swapUsed:0.1f}/{swapTotal:0.1f}GiB Swap";
          on-click-right = "${killRTG} && ${kitty} -o font_size=14 -o confirm_os_window_close=0 --class RTG ${btop}";
        };

        "temperature" = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = [ "" " " ];
        };

        "backlight" = {
          format = "{percent}% {icon}";
          format-icons = [ "" "" "" "" "" "" "" "" "" ];
        };

        "battery" = {
          states = {
            warning = 40;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% ";
          format-alt = "{time} {icon}";
          format-icons = [ " " " " " " " " " " ];
        };

        "clock" = {
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format-alt = "{:%Y-%m-%d}";
          on-click-right = "${killRTG} && ${kitty} -o font_size=14  -o confirm_os_window_close=0 --class RTG ${nvim} ~/.todo.md";
        };

        "tray" = {
          spacing = 5;
        };

        "bluetooth" = {
          format = " {status}";
          format-connected = " {num_connections}";
          format-alt = " {device_alias}";
          tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
          on-click-right = "${killRTG} && ${kitty} -o font_size=14  -o confirm_os_window_close=0 --class RTG ${bluetuith}";
        };

        "custom/gotobed" = {
          format = "{}";
          return-type = "json";
          interval = 60;
          # 如果你的脚本在 ~/scripts，这部分通常保持原样，
          # 除非你把脚本也写进 Nix (例如使用 pkgs.writeShellScript)
          exec = "~/scripts/gotobed.sh";
        };

        "custom/wallpaper" = {
          format = "󰸉 ";
          on-click = "${wpaperctl} next-wallpaper";
        };

        "custom/lrc" = {
          interval = 1;
          exec = "~/scripts/waybarlrc.sh";
          format-alt = "󰝛 zzz";
        };
      };
    };
  };
}
