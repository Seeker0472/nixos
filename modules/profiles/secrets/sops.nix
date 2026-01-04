{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.seeker.secrets = {
    ageKeyPath = lib.mkOption {
      type = lib.types.path;
      default = "/home/${config.users.users.seeker.home}/age/keys";
      description = "Path to the age key file";
    };
  };
  config.sops.age.keyFile = config.seeker.secrets.ageKeyPath;
}
