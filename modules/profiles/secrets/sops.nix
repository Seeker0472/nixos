{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.machine.secrets = {
    deploy = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable secret deployment via sops-nix";
    };
    ageKeyPath = lib.mkOption {
      type = lib.types.path;
      default = "/home/${config.machine.mainUser}/age/keys";
      description = "Path to the age key file";
    };
  };
  config = lib.mkIf config.machine.secrets.deploy {
    sops.age.keyFile = config.machine.secrets.ageKeyPath;
  };
}
