{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.machine.de.niri.enable {
    programs.niri.enable = true;

    services.displayManager = {
      defaultSession = "niri";
      gdm.enable = true;
    };

    environment = {
      sessionVariables.NIXOS_OZONE_WL = "1";
      systemPackages = [ pkgs.xwayland-satellite ];
    };
  };
}
