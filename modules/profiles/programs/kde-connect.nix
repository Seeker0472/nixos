{
  lib,
  config,
  ...
}:
{
  options.machine.programs.kdeconnect.enable = lib.mkEnableOption "ked-connect";
  config = lib.mkMerge [
    {
      home-manager.sharedModules = lib.optionals config.machine.programs.kdeconnect.enable [
        (
          { lib, osConfig, ... }:
          let
            persistDir = lib.attrByPath [
              "machine"
              "btrfs"
              "impermanence"
              "persistdir"
            ] null osConfig;
          in
          {
            services.kdeconnect.enable = true;
          }
          // (
            if persistDir != null then
              {
                home.persistence."${persistDir}".directories = [
                  ".config/kdeconnect/"
                ];
              }
            else
              { }
          )
        )
      ];
    }
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
