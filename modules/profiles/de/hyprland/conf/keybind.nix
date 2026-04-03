{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  hyprlandEnabled = lib.attrByPath [
    "machine"
    "de"
    "hyprland"
    "enable"
  ] false osConfig;
  slurp = "${pkgs.slurp}/bin/slurp";
  grim = "${pkgs.grim}/bin/grim";
  wl-copy = "${pkgs.wl-clipboard}/bin/wl-copy";
  notify-send = "${pkgs.libnotify}/bin/notify-send";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  rm = "${pkgs.coreutils}/bin/rm";

  screenshootScript = pkgs.writeShellScriptBin "screenshoot" ''
    # TMP_FILE=$(mktemp --suffix=.png)
    TMP_FILE=/tmp/screenshot.png

    GEOMETRY=$(${slurp})

    # Check whether canceled
    if [ $? -ne 0 ] || [ -z "$GEOMETRY" ]; then
        ${rm} -f "$TMP_FILE"
        ${notify-send} -u low "Screenshot Cancelled"
        exit 1
    fi

    # screenshoot && copy && notify
    if ${grim} -g "$GEOMETRY" "$TMP_FILE"; then
        ${wl-copy} --type image/png < "$TMP_FILE"
        ${notify-send} "Area Screenshot Taken" "Screenshot copied to clipboard,click to edit." --icon="$TMP_FILE" --category=screenshoot
        # ${rm} "$TMP_FILE"
        exit 0
    else
        ${notify-send} -u critical "Screenshot Failed" "Could not capture screen area."
        # ${rm} "$TMP_FILE"
        exit 1
    fi
  '';
  wpaperctl = "${pkgs.wpaperd}/bin/wpaperctl";
in
{
  config = lib.mkIf hyprlandEnabled {
    wayland.windowManager.hyprland.settings = {
      "$mainMod" = "SUPER"; # Sets "Windows" key as main modifier

      # Binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
      bind = [
        "$mainMod CONTROL SHIFT, M, exit"
        "$mainMod, M, exec, systemctl suspend-then-hibernate"
        "$mainMod SHIFT, M, exec, systemctl hibernate"
        "$mainMod CONTROL, M, exec, ${pkgs.hyprlock}/bin/hyprlock"
        "$mainMod, R, exec, $menu"

        # Hitokoto & Wallpaper (Refactored to stable service)
        '', XF86Tools, exec, ${wpaperctl} next-wallpaper; notify-send --category=hitokoto -t 1 "$(curl -sk https://hitokoto.mayx.eu.org/ | jq -r '"\(.hitokoto)\n—— 《\(.from)》"')"''
        ''SHIFT, XF86Tools, exec, ${wpaperctl} next-wallpaper; notify-send --category=hitokoto -t 1 "$(curl -sk https://hitokoto.mayx.eu.org/?c=a | jq -r '"\(.hitokoto)\n—— 《\(.from)》"')"''
        "CONTROL, XF86Tools, exec, ${wpaperctl} next-wallpaper"
        ''CONTROL SHIFT, XF86Tools, exec, ${wpaperctl} next-wallpaper; notify-send --category=hitokoto -t 1 "$(curl -sk https://v1.hitokoto.mangofanfan.cn/?c=a | jq -r '"\(.hitokoto)\n—— 《\(.from)》"')"''

        ", mouse:275, workspace, e+1"
        ", mouse:276, workspace, e-1"

        # Terminals
        "$mainMod, RETURN, exec, $terminal"
        "$mainMod, SPACE, exec, $terminal --class FG"

        # Window Actions
        "$mainMod SHIFT, Q, killactive"
        "$mainMod CONTROL SHIFT, Q, forcekillactive"

        # SUPER T toggle floating & center window
        "$mainMod, T, togglefloating"
        "$mainMod, T, centerwindow"

        # SUPER SHIFT T resize 70% & center window
        "$mainMod SHIFT, T, resizeactive, exact 70% 70%"
        "$mainMod SHIFT, T, centerwindow"

        "$mainMod, F, fullscreen"
        "$mainMod, A, fullscreen, 1"
        "$mainMod, G, pin"

        # Shortcut mainly for libinput-gestures
        "$mainMod SHIFT, F, setfloating"
        "$mainMod SHIFT, F, resizeactive, exact 70% 70%"
        "$mainMod SHIFT, F, centerwindow"
        "$mainMod CONTROL, F, settiled"

        # --- Window Management ---

        # Move workspaces to monitors
        "$mainMod SHIFT, H, movecurrentworkspacetomonitor, l"
        "$mainMod SHIFT, J, movecurrentworkspacetomonitor, d"
        "$mainMod SHIFT, K, movecurrentworkspacetomonitor, u"
        "$mainMod SHIFT, L, movecurrentworkspacetomonitor, r"
        "$mainMod SHIFT, b, movecurrentworkspacetomonitor, +1"
        "$mainMod, b, focusmonitor, +1"

        "$mainMod SHIFT, left, movecurrentworkspacetomonitor, l"
        "$mainMod SHIFT, right, movecurrentworkspacetomonitor, d"
        "$mainMod SHIFT, up, movecurrentworkspacetomonitor, u"
        "$mainMod SHIFT, down, movecurrentworkspacetomonitor, r"

        # Move focus -> HJKL & Arrows & Tab
        "$mainMod, up, cyclenext, prev"
        "$mainMod, down, cyclenext"
        "$mainMod, H, movefocus, l"
        "$mainMod, L, movefocus, r"
        "$mainMod, K, movefocus, u"
        "$mainMod, J, movefocus, d"
        "$mainMod, TAB, cyclenext"

        # Switch workspaces [0-9]
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"

        # Special workspaces
        "$mainMod, C, workspace, 200"

        # "$mainMod, G, togglespecialworkspace, waydroid"

        # Move active window to a workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, C, movetoworkspace, 200"
        "$mainMod SHIFT, V, movetoworkspace, 201"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"

        # Scroll through existing workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod, left, workspace, e-1"
        "$mainMod, right, workspace, e+1"

        # Move/resize windows
        "$mainMod CONTROL, H, moveactive, -100 0"
        "$mainMod CONTROL, L, moveactive, 100 0"
        "$mainMod CONTROL, K, moveactive, 0 -100"
        "$mainMod CONTROL, J, moveactive, 0 100"

        "$mainMod CONTROL, left, moveactive, -100 0"
        "$mainMod CONTROL, right, moveactive, 100 0"
        "$mainMod CONTROL, up, moveactive, 0 -100"
        "$mainMod CONTROL, down, moveactive, 0 100"

        "$mainMod ALT, H, resizeactive, -100 0"
        "$mainMod ALT, L, resizeactive, 100 0"
        "$mainMod ALT, K, resizeactive, 0 -100"
        "$mainMod ALT, J, resizeactive, 0 100"

        "$mainMod ALT, left, resizeactive, -100 0"
        "$mainMod ALT, right, resizeactive, 100 0"
        "$mainMod ALT, up, resizeactive, 0 -100"
        "$mainMod ALT, down, resizeactive, 0 100"

        # --- Other Binds ---

        # launcher
        "$mainMod, P, exec, ${
          if osConfig.networking.hostName == "miLaptop" then
            "aloha --root commands"
          else
            ''notify-send "TODO"''
        }"
        "$mainMod SHIFT, P, exec, ${
          if osConfig.networking.hostName == "miLaptop" then "aloha --root power" else ''notify-send "TODO"''
        }"
        ''$mainMod CONTROL SHIFT, P, exec, notify-send "TODO"''

        # screenshot
        "$mainMod SHIFT, A, exec, ${lib.getExe screenshootScript}"
        "$mainMod SHIFT ALT, A, exec, grim"
        ", Print, exec, ${lib.getExe screenshootScript}"
      ];

      # Mouse bindings
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      # Laptop multimedia keys for volume and LCD brightness
      bindel = [
        ", XF86AudioRaiseVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, ${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

        ", XF86MonBrightnessUp, exec, ${brightnessctl} s 10%+"
        ", XF86MonBrightnessDown, exec, ${brightnessctl} s 10%-"
      ]; # Media keys & Lid Switch
      bindl = [
        ", XF86AudioNext, exec, ${playerctl} next"
        ", XF86AudioPause, exec, ${playerctl} play-pause"
        ", XF86AudioPlay, exec, ${playerctl} play-pause"
        ", XF86AudioPrev, exec, ${playerctl} previous"
      ]
      ++ (lib.optionals (osConfig.networking.hostName == "miLaptop") [
        '', switch:off:Lid Switch, execr, [ $(hyprctl monitors | grep -c "eDP-1") -ne 1 ] && hyprctl keyword monitor eDP-1,2560x1600@120.0,0x237,1.33''
        '', switch:on:Lid Switch, execr, [ $(hyprctl monitors | grep -c "ID") -ne 1 ] && hyprctl keyword monitor eDP-1,disable''
      ]);
    };
  };
}
