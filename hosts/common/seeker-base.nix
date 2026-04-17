{
  system = "x86_64-linux";
  stateVersion = "24.05";

  machine = {
    mainUser = "seeker";

    users = {
      seeker.enable = true;
    };

    secrets = {
      webdav.enable = true;
    };

    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      openFirewall = true;
    };
  };
}
