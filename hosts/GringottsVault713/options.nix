{ ... }:
{
  config.seeker = {
    machine_type = "container";
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
