{
  system = "x86_64-linux";
  hostName = "gpu02";
  stateVersion = "24.05";

  machine = {
    type = "server";
    mainUser = "seeker4721";

    users = {
      seeker.enable = false;
      hagrid.enable = false;
    };

    secrets = {
      ageKeyPath = "/home/seeker4721/.config/sops/age/keys.txt";
    };
  };
}
