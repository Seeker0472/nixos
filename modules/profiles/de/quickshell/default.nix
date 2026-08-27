{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  deCfg = lib.attrByPath [ "machine" "de" ] { } osConfig;
  enabled = deCfg.quickshell.enable or false;
  swaylockCommand =
    if (deCfg.niri.enable or false) then lib.getExe pkgs.swaylock-effects else lib.getExe pkgs.swaylock;

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

  taskTerminalScript = pkgs.writeShellScriptBin "niri-shell-taskwarrior" ''
    exec ${pkgs.kitty}/bin/kitty --class RTG ${pkgs.fish}/bin/fish -C '${lib.getExe pkgs.taskwarrior3} next'
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
    cp ${./sampler.py} "$out/sampler.py"
    chmod 0555 "$out/sampler.py"
    substitute ${./shell}/Commands.qml "$out/Commands.qml" \
      --subst-var-by niri ${lib.getExe pkgs.niri} \
      --subst-var-by focusWorkspace ${lib.getExe focusWorkspaceScript} \
      --subst-var-by btop ${lib.getExe btopScript} \
      --subst-var-by task ${lib.getExe pkgs.taskwarrior3} \
      --subst-var-by taskTerminal ${lib.getExe taskTerminalScript} \
      --subst-var-by python ${lib.getExe pkgs.python3} \
      --subst-var-by sampler "$out/sampler.py" \
      --subst-var-by pwDump ${pkgs.pipewire}/bin/pw-dump \
      --subst-var-by ip ${pkgs.iproute2}/bin/ip \
      --subst-var-by nmcli ${pkgs.networkmanager}/bin/nmcli \
      --subst-var-by bluetoothctl ${pkgs.bluez}/bin/bluetoothctl \
      --subst-var-by brightnessctl ${lib.getExe pkgs.brightnessctl} \
      --subst-var-by wpctl ${pkgs.wireplumber}/bin/wpctl \
      --subst-var-by systemctl ${pkgs.systemd}/bin/systemctl \
      --subst-var-by loginctl ${pkgs.systemd}/bin/loginctl \
      --subst-var-by swaylock ${swaylockCommand} \
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

    programs.taskwarrior = {
      enable = true;
      package = pkgs.taskwarrior3;
      dataLocation = "${config.xdg.dataHome}/task";
      config.weekstart = "monday";
    };

    home.packages = with pkgs; [
      quickshell
      networkmanagerapplet
      blueman
      pavucontrol
    ];
  };
}
