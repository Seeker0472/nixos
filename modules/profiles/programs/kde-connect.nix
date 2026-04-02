{
  lib,
  config,
  ...
}:
{
  options.machine.programs.kdeconnect.enable = lib.mkEnableOption "ked-connect";
  config = lib.mkMerge [
    (lib.mkIf config.machine.programs.kdeconnect.enable {
      networking.firewall = rec {
        allowedTCPPortRanges = [
          {
            from = 1714;
            to = 1764;
          }
        ];
        allowedUDPPortRanges = allowedTCPPortRanges;
      };
      # TODO:maybe a special workspace here
    })
  ];
}
