{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.machine.secrets.deploy {
    sops.secrets."nix_config" = {
      sopsFile = ./sys.secrets.yaml;
      key = "nix_config";
      owner = "root";
      group = "wheel";
      mode = "0440";
      path = "/etc/nix/my_nix.conf";
    };
    nix.extraOptions = ''
      !include ${config.sops.secrets.nix_config.path}
    '';
  };
}
