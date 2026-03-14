{
  system = "x86_64-linux";
  hostName = "GringottsVault713";
  stateVersion = "25.11";

  machine = {
    type = "container";
    mainUser = "hagrid";

    users = {
      seeker.enable = false;
      hagrid.enable = true;
    };

    secrets = {
      webdav.enable = true;
      ageKeyPath = "/root/age/keys";
    };
  };
}
