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
    machine_type = "laptop";
    cpu = "intel";
    programs = {kdeconnect.enable = true;};
  };
}
