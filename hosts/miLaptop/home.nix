let
  machine = {
    type = "laptop";
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
      kdeconnect.enable = true;
    };
    secrets = {
      ageKeyPath = "/persist/home/seeker/age/keys";
    };
  };
in
{
  system = "x86_64-linux";

  inherit machine;

  standalone = {
    osConfig = {
      networking.hostName = "miLaptop";
      inherit machine;
    };

    syntheticConfig = {
      networking.hostName = "miLaptop";
      inherit machine;
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
      };
      home-manager.users = { };
    };
  };
}
