{ ... }:
{
  # TODO: default option not work!
  config.seeker = {
    machine_type = "laptop";
    cpu = "intel";
    impermanence.enable = true;
    de = {
      hyprland.enable = true;
      waybar.enable = true;
      wofi.enable = true;
      mako.enable = true;
      wpaperd.enable = true;
    };
    users = {
      seeker.enable = true;
    };
    programs = {
      mihomo = {
        enable = true;
        tun.enable = true;
      };
      thunar.enable = true;
      kdeconnect.enable = true;
    };
    secrets = {
      webdav.enable = true;
    };
  };
}
