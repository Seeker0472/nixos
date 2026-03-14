{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.machine.secrets = {
    ageKeyPath = lib.mkOption {
      type = lib.types.path;
      default = "/home/${config.machine.mainUser}/age/keys";
      description = "Path to the age key file";
    };
  };
  config.sops.age.keyFile = config.machine.secrets.ageKeyPath;
}
