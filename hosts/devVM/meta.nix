{
  system = "x86_64-linux";
  hostName = "devVM";
  stateVersion = "24.05";

  machine = {
    type = "others";
    mainUser = "seeker";

    users = {
      seeker.enable = true;
      hagrid.enable = false;
    };

    programs.nixvim.development.enable = true;

    secrets = {
      ageKeyPath = "/home/seeker/.config/sops/age/keys.txt";
      webdav.enable = true;
    };

    services.openssh = {
      enable = false;
      passwordAuthentication = false;
      openFirewall = false;
    };
  };
}
