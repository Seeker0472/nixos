{
  system = "x86_64-linux";
  hostName = "devVM";
  stateVersion = "24.05";

  machine = {
    users = {
      seeker.enable = true;
    };

    programs.nixvim.development.enable = true;

    secrets = {
      deploy = true;
      nixConfig.enable = true;
      ageKeyPath = "/home/seeker/.config/sops/age/keys.txt";
      webdav.enable = true;
    };

    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      openFirewall = true;
    };
  };
}
