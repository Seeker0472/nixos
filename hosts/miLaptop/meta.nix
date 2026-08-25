{
  system = "x86_64-linux";
  hostName = "miLaptop";
  stateVersion = "24.05";

  machine = {
    type = "laptop";
    cpu = "intel";
    impermanence.enable = true;

    de = {
      hyprland.enable = false;
      niri.enable = true;
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
        enable = false;
        share.enable = true;
        tun.enable = false;
      };
      netbird.enable = true;
      nixvim.development.enable = true;
      thunar.enable = true;
      steam.enable = true;
      tailscale.enable = false;
    };

    secrets = {
      ageKeyPath = "/persist/home/seeker/.config/sops/age/keys.txt";
      webdav.enable = false;
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

}
