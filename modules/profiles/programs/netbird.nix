{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.machine.programs.netbird;
  client = config.services.netbird.clients.default;
  persistDir = lib.attrByPath [ "machine" "btrfs" "impermanence" "persistdir" ] "/persist" config;
in
{
  options.machine.programs.netbird = {
    enable = lib.mkEnableOption "NetBird";

    managementUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://netbird.vps.seekerer.com:28443";
      description = "URL of the NetBird management service.";
    };
  };

  config = lib.mkIf cfg.enable (
    {
      services = {
        netbird = {
          useRoutingFeatures = "client";
          ui.enable = false;

          clients.default = {
            port = 51820;
            name = "netbird";
            interface = "wt0";
            hardened = true;
            environment = {
              NB_MANAGEMENT_URL = cfg.managementUrl;
              NB_ADMIN_URL = cfg.managementUrl;
            };
          };
        };

        resolved.enable = true;
      };

      users.users.${config.machine.mainUser}.extraGroups = [ client.user.group ];
    }
    // lib.optionalAttrs (options ? environment.persistence) {
      environment.persistence = lib.mkIf config.machine.impermanence.enable {
        "${persistDir}".directories = [ client.dir.state ];
      };
    }
  );
}
