{ ... }:
{
  config.machine = {
    type = "container";
    mainUser = "hagrid";
    cpu = "others";
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
