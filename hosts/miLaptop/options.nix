{...}: {
  # TODO: default option not work!
  config.seeker = {
    de = {
      hyprland.enable = true;
      waybar.enable = true;
      wofi.enable = true;
      mako.enable = true;
      wpaperd.enable = true;
    };
    type = "laptop";
    programs = {kdeconnect.enable = true;};
  };
}
