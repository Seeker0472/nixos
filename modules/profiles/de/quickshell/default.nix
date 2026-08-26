{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  deCfg = lib.attrByPath [ "machine" "de" ] { } osConfig;
  enabled = deCfg.quickshell.enable or false;

  focusWorkspaceScript = pkgs.writeShellScriptBin "niri-shell-focus-workspace" ''
    output="''${1:-}"
    index="''${2:-1}"
    if [ -n "$output" ]; then
      ${pkgs.niri}/bin/niri msg action focus-monitor "$output"
    fi
    exec ${pkgs.niri}/bin/niri msg action focus-workspace "$index"
  '';

  metricsScript = pkgs.writeShellScriptBin "niri-shell-metrics" ''
    set -u

    read_cpu() {
      ${pkgs.gawk}/bin/awk '/^cpu / { print $2 + $3 + $4 + $5 + $6 + $7 + $8, $5 + $6; exit }' /proc/stat
    }

    before=( $(read_cpu) )
    ${pkgs.coreutils}/bin/sleep 0.08
    after=( $(read_cpu) )

    total_delta=$(( after[0] - before[0] ))
    idle_delta=$(( after[1] - before[1] ))
    cpu=0
    if (( total_delta > 0 )); then
      cpu=$(${pkgs.gawk}/bin/awk -v busy="$((total_delta - idle_delta))" -v total="$total_delta" 'BEGIN { printf "%.0f", (busy / total) * 100 }')
    fi

    memory=$(${pkgs.gawk}/bin/awk '
      /^MemTotal:/ { total = $2 }
      /^MemAvailable:/ { available = $2 }
      END {
        if (total > 0) printf "%.0f", (1 - available / total) * 100;
        else print 0;
      }
    ' /proc/meminfo)

    temperature=0
    for sensor in /sys/class/thermal/thermal_zone*/temp; do
      if [ -r "$sensor" ]; then
        value="$(${pkgs.coreutils}/bin/cat "$sensor" 2>/dev/null || true)"
        if [[ "$value" =~ ^[0-9]+$ ]]; then
          temperature=$((value / 1000))
          break
        fi
      fi
    done

    battery=0
    battery_status="Unknown"
    battery_line="$(${pkgs.acpi}/bin/acpi -b 2>/dev/null | ${pkgs.coreutils}/bin/head -n1 || true)"
    if [ -n "$battery_line" ]; then
      battery="$(${pkgs.gnused}/bin/sed -n 's/.*: \([0-9][0-9]*\)%.*/\1/p' <<< "$battery_line")"
      battery_status="$(${pkgs.gnused}/bin/sed -n 's/.*: \([^,]*\),.*/\1/p' <<< "$battery_line")"
    fi

    network="$(${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep '^yes:' \
      | ${pkgs.coreutils}/bin/head -n1 \
      | ${pkgs.coreutils}/bin/cut -d: -f2- || true)"
    if [ -z "$network" ]; then
      network="$(${pkgs.networkmanager}/bin/nmcli -t -f device,type,state,connection dev 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep ':connected:' \
        | ${pkgs.coreutils}/bin/head -n1 \
        | ${pkgs.coreutils}/bin/cut -d: -f4- || true)"
    fi

    wifi_enabled="false"
    if [ "$(${pkgs.networkmanager}/bin/nmcli radio wifi 2>/dev/null || true)" = "enabled" ]; then
      wifi_enabled="true"
    fi

    bluetooth_powered="false"
    bluetooth_connected=""
    bluetooth_info="$(${pkgs.bluez}/bin/bluetoothctl show 2>/dev/null || true)"
    if ${pkgs.gnugrep}/bin/grep -q 'Powered: yes' <<< "$bluetooth_info"; then
      bluetooth_powered="true"
    fi
    bluetooth_connected="$(${pkgs.bluez}/bin/bluetoothctl devices Connected 2>/dev/null \
      | ${pkgs.gnused}/bin/sed 's/^Device [^ ]* //' \
      | ${pkgs.coreutils}/bin/paste -sd ', ' - || true)"

    brightness=0
    brightness_line="$(${pkgs.brightnessctl}/bin/brightnessctl -m 2>/dev/null | ${pkgs.coreutils}/bin/head -n1 || true)"
    if [ -n "$brightness_line" ]; then
      brightness="$(${pkgs.coreutils}/bin/cut -d, -f5 <<< "$brightness_line" | ${pkgs.gnused}/bin/sed 's/%//')"
    fi

    on_battery="false"
    if [ "$battery_status" = "Discharging" ]; then
      on_battery="true"
    fi

    ${pkgs.jq}/bin/jq -cn \
      --arg network "$network" \
      --arg batteryStatus "$battery_status" \
      --arg bluetoothConnected "$bluetooth_connected" \
      --argjson cpu "''${cpu:-0}" \
      --argjson memory "''${memory:-0}" \
      --argjson temperature "''${temperature:-0}" \
      --argjson battery "''${battery:-0}" \
      --argjson brightness "''${brightness:-0}" \
      --argjson wifiEnabled "$wifi_enabled" \
      --argjson bluetoothPowered "$bluetooth_powered" \
      --argjson onBattery "$on_battery" \
      '{cpu: $cpu, memory: $memory, temperature: $temperature, battery: $battery, brightness: $brightness, network: $network, batteryStatus: $batteryStatus, wifiEnabled: $wifiEnabled, bluetoothPowered: $bluetoothPowered, bluetoothConnected: $bluetoothConnected, onBattery: $onBattery}'
  '';

  cavaConfig = pkgs.writeText "niri-shell-cava.conf" ''
    [general]
    bars = 12
    framerate = 20
    autosens = 1

    [input]
    method = pipewire
    source = auto

    [output]
    method = raw
    raw_target = /dev/stdout
    data_format = ascii
    ascii_max_range = 8
    bar_delimiter = 59
  '';

  commands = pkgs.runCommand "niri-quickshell-config" { } ''
    mkdir -p "$out"
    cp -r ${./shell}/. "$out/"
    substitute ${./shell}/Commands.qml "$out/Commands.qml" \
      --subst-var-by niri ${lib.getExe pkgs.niri} \
      --subst-var-by focusWorkspace ${lib.getExe focusWorkspaceScript} \
      --subst-var-by metrics ${lib.getExe metricsScript} \
      --subst-var-by nmcli ${pkgs.networkmanager}/bin/nmcli \
      --subst-var-by bluetoothctl ${pkgs.bluez}/bin/bluetoothctl \
      --subst-var-by brightnessctl ${lib.getExe pkgs.brightnessctl} \
      --subst-var-by wpctl ${pkgs.wireplumber}/bin/wpctl \
      --subst-var-by systemctl ${pkgs.systemd}/bin/systemctl \
      --subst-var-by loginctl ${pkgs.systemd}/bin/loginctl \
      --subst-var-by swaylock ${lib.getExe pkgs.swaylock} \
      --subst-var-by pavucontrol ${lib.getExe pkgs.pavucontrol} \
      --subst-var-by nmEditor ${pkgs.networkmanagerapplet}/bin/nm-connection-editor \
      --subst-var-by blueman ${pkgs.blueman}/bin/blueman-manager \
      --subst-var-by wpaperctl ${pkgs.wpaperd}/bin/wpaperctl \
      --subst-var-by playerctl ${lib.getExe pkgs.playerctl} \
      --subst-var-by cava ${lib.getExe pkgs.cava} \
      --subst-var-by cavaConfig ${cavaConfig}
  '';
in
{
  config = lib.mkIf enabled {
    xdg.configFile."quickshell/niri-shell".source = commands;

    home.packages = with pkgs; [
      quickshell
      networkmanagerapplet
      blueman
      pavucontrol
    ];
  };
}
