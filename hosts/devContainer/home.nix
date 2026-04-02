{
  system = "x86_64-linux";
  hostName = "devContainer";
  stateVersion = "24.05";

  machine = {
    type = "container";
    mainUser = "seeker";

    users = {
      seeker.enable = true;
      hagrid.enable = false;
    };

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
