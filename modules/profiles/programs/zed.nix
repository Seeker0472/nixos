{ config, lib, ... }:
{
  config = lib.mkMerge [
    {
      home-manager.sharedModules = [
        ./home/zed.nix
      ];
    }
    (lib.mkIf config.machine.users.seeker.enable {
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.login.enableGnomeKeyring = true;
    })
  ];
}
