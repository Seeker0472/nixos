{
  lib,
  config,
  ...
}: {
  options.seeker.programs.kdeconnect.enable = lib.mkEnableOption "ked-connect";
  config = lib.mkMerge [
    (lib.mkIf config.seeker.programs.kdeconnect.enable {
      home-manager.sharedModules = [
        {
          services.kdeconnect.enable = true;
        }
      ];

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
