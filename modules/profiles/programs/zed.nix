{ config, lib, ... }:
{
  config = lib.mkIf config.machine.users.seeker.enable {
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.login.enableGnomeKeyring = true;
  };
}
