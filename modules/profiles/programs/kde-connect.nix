{
  lib,
  config,
  ...
}:
{
  options.machine.programs.kdeconnect.enable = lib.mkEnableOption "KDE Connect";
  config = lib.mkIf config.machine.programs.kdeconnect.enable {
    networking.firewall = rec {
      allowedTCPPortRanges = [
        {
          from = 1714;
          to = 1764;
        }
      ];
      allowedUDPPortRanges = allowedTCPPortRanges;
    };
  };
}
