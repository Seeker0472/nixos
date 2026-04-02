{
  system = "x86_64-linux";
  hostName = "miLaptop";
  stateVersion = "24.05";

  machine = {
    type = "laptop";
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
      kdeconnect.enable = true;
      mihomo = {
        enable = true;
        tun.enable = true;
      };
      thunar.enable = true;
      steam.enable = true;
      tailscale.enable = true;
    };

    secrets = {
      ageKeyPath = "/persist/home/seeker/age/keys";
      webdav.enable = true;
    };

    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      openFirewall = true;
    };

    virtualization = {
      docker.enable = true;
      virtualbox.enable = true;
    };
  };

  standalone.extraConfig = {
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
    };
  };
}
