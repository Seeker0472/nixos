{ pkgs,lib, ... }: {
  #kitty terminal
  programs.kitty = lib.mkForce{
    enable = true;
    # kitty has catppuccin theme built-in,
    # all the built-in themes are packaged into an extra package named `kitty-themes`
    # and it's installed by home-manager if `theme` is specified.
    themeFile = "Catppuccin-Mocha";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 22;
    };
    settings = {
      mouse_hide_wait = "-1.0";
          remember_window_size = "no";
    initial_window_width="90c";
    initial_window_height="26c";
    };


  };
  # home.file.".config/kitty/float_middle".text = ''
  #   # new_os_window
  #   resize_window wider 2
  #   os_window_size 180c 34c
  #   os_window_class FG
  #   os_window_state normal
  # '';

}

