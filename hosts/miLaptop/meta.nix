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
      quickshell.enable = true;
      waybar.enable = false;
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
        share.enable = true;
        tun.enable = true;
        web.enable = true;
      };
      netbird.enable = true;
      nixvim.development.enable = true;
      zed.enable = true;
      gpg.enable = true;
      thunar.enable = true;
      steam.enable = true;
      tailscale.enable = false;
    };

    secrets = {
      deploy = true;
      nixConfig.enable = true;
      ageKeyPath = "/persist/home/seeker/.config/sops/age/keys.txt";
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
