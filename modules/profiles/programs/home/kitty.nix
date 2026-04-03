{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.homeProfiles.terminals.kitty.enable {
    programs.kitty = {
      enable = true;
      themeFile = "Catppuccin-Mocha";
      font = {
        name = "Maple Mono NF CN";
        size = 18;
      };
      settings = {
        mouse_hide_wait = "-1.0";
        remember_window_size = "no";
        cursor_trail = "3";
        shell = "${pkgs.fish}/bin/fish";
        initial_window_width = "90c";
        initial_window_height = "26c";
        background_opacity = "0.92";
      };
      keybindings = {
        # new window
        "ctrl+shift+enter" = "launch --cwd=current --copy-env --copy-cmdline";
        "ctrl+shift+alt+enter" = "launch --cwd=current";
        "ctrl+shift+q" = "close_window";
        "ctrl+shift+w" = "new_window";

        # thinking how to map keys, now same as tmux
        #"ctrl+a>up" = "resize_window taller";
        #"ctrl+a>x" = "close_window";
        #"ctrl+a+down" = "resize_window shorter";
        #"ctrl+a+left" = "resize_window wider";
        #"ctrl+a+right" = "resize_window narrower";
        #"ctrl+a+h" = "neighboring_window left";
        #"ctrl+a+j" = "neighboring_window down";
        #"ctrl+a+k" = "neighboring_window up";
        #"ctrl+a+l" = "neighboring_window right";
      };
      extraConfig = ''
        # right click to select text
        mouse_map right press ungrabbed mouse_select_command_output
      '';
    };

    wayland.windowManager.hyprland.settings = {
      "$terminal" = "kitty";
      windowrule = [
        # float&pin kitty
        "tag +float_term,match:initial_class (.*F.*) ,match:initial_title ^(kitty)$"
        "float on, match:tag float_term*"
        "center on, match:tag float_term*"
        "size (monitor_w*0.7) (monitor_h*0.7), match:tag float_term*"

        "tag +global_term ,match:initial_class (.*G.*), match:initial_title ^(kitty)$"
        "pin on, match:tag global_term*"

        # kitty: right-Up of screen
        "tag +right_top_term, match:initial_class (RT.*), match:initial_title ^(kitty)$"
        "size (monitor_w*0.6) (monitor_h*0.7), match:tag right_top_term*"
        "float on, match:tag right_top_term*"
        "move (monitor_w-window_w) 30, match:tag right_top_term*"
      ];
    };
  };
}
