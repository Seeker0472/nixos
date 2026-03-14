let
  machine = {
    type = "container";
    mainUser = "hagrid";
    users = {
      seeker.enable = false;
      hagrid.enable = true;
    };
  };
in
{
  system = "x86_64-linux";

  inherit machine;

  standalone = {
    osConfig = {
      networking.hostName = "GringottsVault713";
      inherit machine;
    };

    syntheticConfig = {
      networking.hostName = "GringottsVault713";
      inherit machine;
      home-manager.users = { };
    };
  };
}
