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

  btopScript = pkgs.writeShellScriptBin "niri-shell-btop" ''
    exec ${pkgs.kitty}/bin/kitty --class RTG ${pkgs.btop}/bin/btop
  '';

  todoScript = pkgs.writeShellScriptBin "niri-shell-todo" ''
    exec ${pkgs.kitty}/bin/kitty --class RTG ${pkgs.neovim}/bin/nvim "$HOME/Documents/todo.md"
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

    cpu_frequency=0
    cpu_frequency_sum=0
    cpu_frequency_count=0
    for frequency_file in /sys/devices/system/cpu/cpu[0-9]*/cpufreq/scaling_cur_freq; do
      if [ -r "$frequency_file" ]; then
        frequency="$(${pkgs.coreutils}/bin/cat "$frequency_file" 2>/dev/null || true)"
        if [[ "$frequency" =~ ^[0-9]+$ ]]; then
          cpu_frequency_sum=$((cpu_frequency_sum + frequency))
          cpu_frequency_count=$((cpu_frequency_count + 1))
        fi
      fi
    done
    if (( cpu_frequency_count > 0 )); then
      cpu_frequency=$((cpu_frequency_sum / cpu_frequency_count / 1000))
    else
      cpu_frequency="$(${pkgs.gawk}/bin/awk '/^cpu MHz/ { sum += $4; count++ } END { if (count > 0) printf "%.0f", sum / count; else print 0 }' /proc/cpuinfo)"
    fi
    cpu_cores="$(${pkgs.coreutils}/bin/nproc 2>/dev/null || printf '0')"
    load_average="$(${pkgs.gawk}/bin/awk '{ print $1 + 0 }' /proc/loadavg)"

    memory=0
    memory_used=0
    memory_total=0
    swap_used=0
    swap_total=0
    read -r memory memory_used memory_total swap_used swap_total <<< "$(${pkgs.gawk}/bin/awk '
      /^MemTotal:/ { total = $2 }
      /^MemAvailable:/ { available = $2 }
      /^SwapTotal:/ { swap_total = $2 }
      /^SwapFree:/ { swap_free = $2 }
      END {
        used = total - available;
        swap_used = swap_total - swap_free;
        if (total > 0) memory = (used / total) * 100;
        else memory = 0;
        printf "%.0f %.0f %.0f %.0f %.0f\n", memory, used / 1024, total / 1024, swap_used / 1024, swap_total / 1024;
      }
    ' /proc/meminfo)"

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
    battery_time=""
    battery_line="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.acpi}/bin/acpi -b 2>/dev/null | ${pkgs.coreutils}/bin/head -n1 || true)"
    if [ -n "$battery_line" ]; then
      battery="$(${pkgs.gnugrep}/bin/grep -o '[0-9][0-9]*%' <<< "$battery_line" | ${pkgs.coreutils}/bin/head -n1 | ${pkgs.gnused}/bin/sed 's/%//')"
      battery_status="$(${pkgs.gnused}/bin/sed -n 's/^[^:]*: \([^,]*\).*/\1/p' <<< "$battery_line")"
      battery_time="$(${pkgs.gnused}/bin/sed -n 's/.*,[[:space:]]*[0-9][0-9]*%,[[:space:]]*\([^,]*\).*/\1/p' <<< "$battery_line")"
      battery_time="$(${pkgs.gnused}/bin/sed -E 's/[[:space:]]+(remaining|until[[:space:]]+charged|until[[:space:]]+full)$//' <<< "$battery_time")"
    fi

    network="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.networkmanager}/bin/nmcli -t -f active,ssid dev wifi 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep '^yes:' \
      | ${pkgs.coreutils}/bin/head -n1 \
      | ${pkgs.coreutils}/bin/cut -d: -f2- || true)"
    network_type="none"
    network_signal=0
    network_interface=""
    network_address=""
    network_gateway=""
    network_device_line="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.networkmanager}/bin/nmcli -t -f device,type,state dev 2>/dev/null \
      | ${pkgs.gnugrep}/bin/grep ':connected$' \
      | ${pkgs.coreutils}/bin/head -n1 || true)"
    if [ -n "$network_device_line" ]; then
      network_interface="$(${pkgs.coreutils}/bin/cut -d: -f1 <<< "$network_device_line")"
      network_kind="$(${pkgs.coreutils}/bin/cut -d: -f2 <<< "$network_device_line")"
      case "$network_kind" in
        wifi|wireless) network_type="wifi" ;;
        ethernet) network_type="ethernet" ;;
        *) network_type="$network_kind" ;;
      esac
      network_signal="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.networkmanager}/bin/nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null \
        | ${pkgs.gawk}/bin/awk -F: '$1 == "*" || $1 == "yes" { print $2; exit }' || true)"
      network_address="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.iproute2}/bin/ip -o -4 addr show dev "$network_interface" 2>/dev/null \
        | ${pkgs.gawk}/bin/awk '{ print $4; exit }' || true)"
      network_gateway="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.iproute2}/bin/ip route show default dev "$network_interface" 2>/dev/null \
        | ${pkgs.gawk}/bin/awk '{ print $3; exit }' || true)"
      if [ -z "$network_gateway" ]; then
        network_gateway="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.iproute2}/bin/ip route show default 2>/dev/null \
          | ${pkgs.gawk}/bin/awk '{ print $3; exit }' || true)"
      fi
    fi
    if [ -z "$network" ]; then
      network="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.networkmanager}/bin/nmcli -t -f device,type,state,connection dev 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep ':connected:' \
        | ${pkgs.coreutils}/bin/head -n1 \
        | ${pkgs.coreutils}/bin/cut -d: -f4- || true)"
    fi

    wifi_enabled="false"
    if [ "$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.networkmanager}/bin/nmcli radio wifi 2>/dev/null || true)" = "enabled" ]; then
      wifi_enabled="true"
    fi

    bluetooth_powered="false"
    bluetooth_connected=""
    bluetooth_info="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.bluez}/bin/bluetoothctl show 2>/dev/null || true)"
    if ${pkgs.gnugrep}/bin/grep -q 'Powered: yes' <<< "$bluetooth_info"; then
      bluetooth_powered="true"
    fi
    bluetooth_controller="$(${pkgs.gnused}/bin/sed -n 's/^Name: //p' <<< "$bluetooth_info" | ${pkgs.coreutils}/bin/head -n1)"
    bluetooth_address="$(${pkgs.gnused}/bin/sed -n 's/^Controller \([^ ]*\).*/\1/p' <<< "$bluetooth_info" | ${pkgs.coreutils}/bin/head -n1)"
    bluetooth_connected="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.bluez}/bin/bluetoothctl devices Connected 2>/dev/null \
      | ${pkgs.gnused}/bin/sed 's/^Device [^ ]* //' \
      | ${pkgs.gawk}/bin/awk 'NR > 1 { printf ", " } { printf "%s", $0 } END { if (NR > 0) print "" }' || true)"

    brightness=0
    brightness_line="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.brightnessctl}/bin/brightnessctl -m 2>/dev/null | ${pkgs.coreutils}/bin/head -n1 || true)"
    if [ -n "$brightness_line" ]; then
      brightness="$(${pkgs.coreutils}/bin/cut -d, -f5 <<< "$brightness_line" | ${pkgs.gnused}/bin/sed 's/%//')"
    fi

    on_battery="false"
    ac_power="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.acpi}/bin/acpi -a 2>/dev/null || true)"
    if [[ "$battery_status" =~ [Dd]ischarging ]] || ${pkgs.gnugrep}/bin/grep -qi 'off-line' <<< "$ac_power"; then
      on_battery="true"
    fi

    privacy_json='{"audioIn":false,"screenShare":false,"audioInApps":[],"screenShareApps":[]}'
    privacy_dump="$(${pkgs.coreutils}/bin/timeout 1 ${pkgs.pipewire}/bin/pw-dump 2>/dev/null || true)"
    if [ -n "$privacy_dump" ]; then
      privacy_json="$(${pkgs.jq}/bin/jq -c '
        [ .[]
          | select(.type == "PipeWire:Interface:Node")
          | .info as $info
          | ($info.props // {}) as $props
          | select((($info.state // "") | tostring | ascii_downcase) == "running")
          | select((($props["stream.monitor"] // false) | tostring | ascii_downcase) != "true")
          | select((($props["node.name"] // "") | tostring | ascii_downcase) != "cava")
          | select((($props["application.name"] // "") | tostring | ascii_downcase) != "cava")
          | {class: ($props["media.class"] // ""), name: ([$props["application.name"], $props["node.name"], $props["media.name"]] | map(select(type == "string" and length > 0)) | .[0] // "Unknown")}
        ] as $nodes
        | {
            audioIn: ([$nodes[] | select(.class == "Stream/Input/Audio")] | length > 0),
            screenShare: ([$nodes[] | select(.class == "Stream/Input/Video")] | length > 0),
            audioInApps: ([$nodes[] | select(.class == "Stream/Input/Audio") | .name] | unique),
            screenShareApps: ([$nodes[] | select(.class == "Stream/Input/Video") | .name] | unique)
          }
      ' <<< "$privacy_dump" 2>/dev/null || printf '%s' '{"audioIn":false,"screenShare":false,"audioInApps":[],"screenShareApps":[]}')"
    fi

    ${pkgs.jq}/bin/jq -cn \
      --arg network "$network" \
      --arg networkType "$network_type" \
      --arg networkInterface "$network_interface" \
      --arg networkAddress "$network_address" \
      --arg networkGateway "$network_gateway" \
      --arg batteryTime "$battery_time" \
      --arg batteryStatus "$battery_status" \
      --arg bluetoothController "$bluetooth_controller" \
      --arg bluetoothAddress "$bluetooth_address" \
      --arg bluetoothConnected "$bluetooth_connected" \
      --argjson cpu "''${cpu:-0}" \
      --argjson cpuFrequencyMHz "''${cpu_frequency:-0}" \
      --argjson cpuCores "''${cpu_cores:-0}" \
      --argjson loadAverage "''${load_average:-0}" \
      --argjson memory "''${memory:-0}" \
      --argjson memoryUsed "''${memory_used:-0}" \
      --argjson memoryTotal "''${memory_total:-0}" \
      --argjson swapUsed "''${swap_used:-0}" \
      --argjson swapTotal "''${swap_total:-0}" \
      --argjson temperature "''${temperature:-0}" \
      --argjson battery "''${battery:-0}" \
      --argjson brightness "''${brightness:-0}" \
      --argjson networkSignal "''${network_signal:-0}" \
      --argjson wifiEnabled "$wifi_enabled" \
      --argjson bluetoothPowered "$bluetooth_powered" \
      --argjson onBattery "$on_battery" \
      --argjson privacy "$privacy_json" \
      '{cpu: $cpu, cpuFrequencyMHz: $cpuFrequencyMHz, cpuCores: $cpuCores, loadAverage: $loadAverage, memory: $memory, memoryUsed: $memoryUsed, memoryTotal: $memoryTotal, swapUsed: $swapUsed, swapTotal: $swapTotal, temperature: $temperature, battery: $battery, batteryTime: $batteryTime, brightness: $brightness, network: $network, networkType: $networkType, networkSignal: $networkSignal, networkInterface: $networkInterface, networkAddress: $networkAddress, networkGateway: $networkGateway, batteryStatus: $batteryStatus, wifiEnabled: $wifiEnabled, bluetoothPowered: $bluetoothPowered, bluetoothController: $bluetoothController, bluetoothAddress: $bluetoothAddress, bluetoothConnected: $bluetoothConnected, onBattery: $onBattery} + $privacy'
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
      --subst-var-by btop ${lib.getExe btopScript} \
      --subst-var-by todo ${lib.getExe todoScript} \
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
