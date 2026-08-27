{ config, lib, ... }:
{
  options.machine.programs.zed.enable = lib.mkEnableOption "Zed desktop integration";

  config = lib.mkIf config.machine.programs.zed.enable {
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true;
  };
}
