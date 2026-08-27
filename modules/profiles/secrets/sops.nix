{ config, lib, ... }:
{
  options.machine.secrets = {
    deploy = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable secret deployment via sops-nix";
    };
    ageKeyPath = lib.mkOption {
      type = lib.types.path;
      default = "/home/${config.machine.mainUser}/.config/sops/age/keys.txt";
      description = "Path to the age key file";
    };
  };
  config = lib.mkIf config.machine.secrets.deploy {
    sops.age.keyFile = config.machine.secrets.ageKeyPath;
  };
}
