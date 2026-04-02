{ config, lib, ... }:
let
  cfg = config.machine.services.openssh;
in
{
  options.machine.services.openssh = {
    enable = lib.mkEnableOption "OpenSSH daemon";
    passwordAuthentication = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether OpenSSH accepts password logins.";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for OpenSSH.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings = {
        X11Forwarding = true;
        PermitRootLogin = "no";
        PasswordAuthentication = cfg.passwordAuthentication;
      };
      openFirewall = cfg.openFirewall;
    };
  };
}
