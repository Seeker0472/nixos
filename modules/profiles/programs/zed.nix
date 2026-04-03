{ config, lib, ... }:
{
  config =
    lib.mkIf
      (lib.attrByPath [
        "machine"
        "users"
        config.machine.mainUser
        "enable"
      ] false config)
      {
        services.gnome.gnome-keyring.enable = true;
        security.pam.services.login.enableGnomeKeyring = true;
      };
}
