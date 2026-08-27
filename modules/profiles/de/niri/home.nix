{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  deCfg = lib.attrByPath [ "machine" "de" ] { } osConfig;
  niriEnabled = deCfg.niri.enable or false;
  fcitx5Enabled =
    (lib.attrByPath [ "i18n" "inputMethod" "enable" ] false osConfig)
    && (lib.attrByPath [ "i18n" "inputMethod" "type" ] null osConfig) == "fcitx5";

  focusOrSpawn = pkgs.writeShellApplication {
    name = "niri-focus-or-spawn";
    runtimeInputs = [
      pkgs.jq
      pkgs.niri
    ];
    text = ''
      if (( $# < 2 )); then
        echo "usage: niri-focus-or-spawn APP_ID_PATTERN COMMAND [ARG...]" >&2
        exit 2
      fi

      app_id_pattern="$1"
      shift

      windows="$(niri msg --json windows 2>/dev/null || printf '[]')"
      window_id="$(${pkgs.jq}/bin/jq -r --arg pattern "$app_id_pattern" \
        '[.[] | select((.app_id // "") | test($pattern; "i"))][0].id // empty' \
        <<< "$windows" 2>/dev/null || true)"

      if [[ "$window_id" =~ ^[0-9]+$ ]]; then
        exec niri msg action focus-window --id "$window_id"
      fi

      exec "$@"
    '';
  };

  forceKill = pkgs.writeShellApplication {
    name = "niri-force-kill";
    runtimeInputs = [
      pkgs.jq
      pkgs.niri
    ];
    text = ''
      pid="$(niri msg --json focused-window 2>/dev/null | jq -r '.pid // empty' || true)"
      if [[ "$pid" =~ ^[0-9]+$ ]]; then
        kill -KILL "$pid"
      fi
    '';
  };

  resizeAndCenter = pkgs.writeShellApplication {
    name = "niri-resize-and-center";
    runtimeInputs = [ pkgs.niri ];
    text = ''
      niri msg action set-column-width "70%"
      niri msg action set-window-height "70%"
      niri msg action center-window
    '';
  };

  mediaControl = pkgs.writeShellApplication {
    name = "niri-media-control";
    runtimeInputs = [ pkgs.wireplumber ];
    text = ''
      case "''${1:-}" in
        volume-up) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ ;;
        volume-down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        volume-mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
        microphone-mute) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
        *) echo "usage: niri-media-control {volume-up|volume-down|volume-mute|microphone-mute}" >&2; exit 2 ;;
      esac
    '';
  };

  wallpaperQuote = pkgs.writeShellApplication {
    name = "niri-wallpaper-quote";
    runtimeInputs = [
      pkgs.curl
      pkgs.jq
      pkgs.libnotify
      pkgs.wpaperd
    ];
    text = ''
      case "''${1:-default}" in
        default) url="https://hitokoto.mayx.eu.org/" ;;
        anime) url="https://hitokoto.mayx.eu.org/?c=a" ;;
        alternate) url="https://v1.hitokoto.mangofanfan.cn/?c=a" ;;
        *) echo "unknown quote source: $1" >&2; exit 2 ;;
      esac

      wpaperctl next-wallpaper
      response="$(curl -fsSk "$url" || true)"
      message="$(jq -r 'if type == "object" and .hitokoto then .hitokoto + "\n-- " + (.from // "unknown") else empty end' <<< "$response" 2>/dev/null || true)"
      if [[ -n "$message" ]]; then
        notify-send --category=hitokoto -t 3000 "$message"
      fi
    '';
  };

  swaylockPackage = pkgs.swaylock-effects;
  lockCommand = "${pkgs.procps}/bin/pidof swaylock || ${lib.getExe swaylockPackage} -f";
  onBattery = "${pkgs.acpi}/bin/acpi -a | ${pkgs.gnugrep}/bin/grep -q off-line";

  niriConfig = pkgs.replaceVars ./config.kdl {
    focusOrSpawn = lib.getExe focusOrSpawn;
    forceKill = lib.getExe forceKill;
    mediaControl = lib.getExe mediaControl;
    resizeAndCenter = lib.getExe resizeAndCenter;
    wallpaperQuote = lib.getExe wallpaperQuote;
    aloha = "aloha";
    brightnessctl = lib.getExe pkgs.brightnessctl;
    cliphist = lib.getExe pkgs.cliphist;
    kitty = lib.getExe pkgs.kitty;
    loginctl = "${pkgs.systemd}/bin/loginctl";
    playerctl = lib.getExe pkgs.playerctl;
    systemctl = "${pkgs.systemd}/bin/systemctl";
    thunar = lib.getExe pkgs.thunar;
    wlCopy = "${pkgs.wl-clipboard}/bin/wl-copy";
    wlPaste = "${pkgs.wl-clipboard}/bin/wl-paste";
    wpaperctl = "${pkgs.wpaperd}/bin/wpaperctl";
    xwaylandSatellite = lib.getExe pkgs.xwayland-satellite;
    quickshellStartup = lib.optionalString (deCfg.quickshell.enable or false) ''
      spawn-at-startup "${lib.getExe pkgs.quickshell}" "--config" "niri-shell"
    '';
    waybarStartup =
      lib.optionalString ((deCfg.waybar.enable or false) && !(deCfg.quickshell.enable or false))
        ''
          spawn-at-startup "${lib.getExe pkgs.waybar}"
        '';
    quickshellToggle = lib.optionalString (deCfg.quickshell.enable or false) ''
      Mod+Shift+Space repeat=false hotkey-overlay-title="Toggle Control Center" { spawn "${lib.getExe pkgs.quickshell}" "ipc" "-c" "niri-shell" "call" "shell" "toggle"; }
    '';
    wpaperdStartup = lib.optionalString (deCfg.wpaperd.enable or false) ''
      spawn-at-startup "${lib.getExe pkgs.wpaperd}"
    '';
    fcitx5Startup = lib.optionalString fcitx5Enabled ''
      spawn-at-startup "fcitx5" "--replace" "-d"
    '';
  };
in
{
  config = lib.mkIf niriEnabled {
    xdg.configFile."niri/config.kdl".source = niriConfig;

    home.packages = [
      pkgs.cliphist
      pkgs.wl-clipboard
    ];

    programs.swaylock = {
      enable = true;
      package = swaylockPackage;
      settings = {
        image = ../wallpaper/nix-wallpaper-moonscape.png;
        scaling = "fill";
        color = "303446ff";

        indicator = true;
        indicator-caps-lock = true;
        indicator-radius = 220;
        indicator-thickness = 13;

        clock = true;
        timestr = "%H:%M  ·  %m-%d";
        datestr = "󰌾  %A";
        font = "Maple Mono NF CN";
        font-size = 56;

        inside-color = "303446e6";
        inside-clear-color = "303446e6";
        inside-caps-lock-color = "303446e6";
        inside-ver-color = "303446e6";
        inside-wrong-color = "303446e6";
        ring-color = "ca9ee6ff";
        ring-clear-color = "e5c890ff";
        ring-caps-lock-color = "e5c890ff";
        ring-ver-color = "a6d189ff";
        ring-wrong-color = "e78284ff";
        line-color = "00000000";
        line-clear-color = "00000000";
        line-caps-lock-color = "00000000";
        line-ver-color = "00000000";
        line-wrong-color = "00000000";
        separator-color = "00000000";
        key-hl-color = "f4b8e4ff";
        bs-hl-color = "e78284ff";

        text-color = "c6d0f5ff";
        text-clear = "Enter password";
        text-clear-color = "c6d0f5ff";
        text-caps-lock = "Caps Lock";
        text-caps-lock-color = "e5c890ff";
        text-ver = "Authenticating...";
        text-ver-color = "a6d189ff";
        text-wrong = "Wrong password";
        text-wrong-color = "e78284ff";

        show-keyboard-layout = true;
        show-failed-attempts = true;
      };
    };

    services = {
      polkit-gnome.enable = true;

      swayidle = {
        enable = true;
        events = {
          before-sleep = lockCommand;
          lock = lockCommand;
        };
        timeouts = [
          {
            timeout = 240;
            command = "${onBattery} && ${pkgs.libnotify}/bin/notify-send Zzz";
          }
          {
            timeout = 300;
            command = "${onBattery} && ${pkgs.systemd}/bin/loginctl lock-session";
          }
          {
            timeout = 600;
            command = "${onBattery} && ${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
          }
        ];
      };
    };
  };
}
