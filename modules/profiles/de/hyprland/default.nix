{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.machine.de.hyprland.enable {
    programs.hyprland = {
      enable = true;
    };
    services.displayManager.gdm = {
      enable = true;
      settings = { };
    };
    services.displayManager.defaultSession = "hyprland";
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
