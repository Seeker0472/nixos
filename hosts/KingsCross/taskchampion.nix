{ config, ... }:
let
  domain = "vps.seekerer.com";
  publicPort = 28443;
  backendPort = 10222;
in
{
  sops = {
    secrets.taskchampion_client_id = {
      sopsFile = ../../users/seeker/taskwarrior.secrets.yaml;
      key = "client_id";
    };

    templates."taskchampion.env" = {
      mode = "0400";
      restartUnits = [ "taskchampion-sync-server.service" ];
      content = ''
        CLIENT_ID=${config.sops.placeholder.taskchampion_client_id}
      '';
    };
  };

  services = {
    taskchampion-sync-server = {
      enable = true;
      host = "127.0.0.1";
      port = backendPort;
    };

    nginx.virtualHosts.${domain} = {
      onlySSL = true;
      useACMEHost = domain;
      listen = [
        {
          addr = "0.0.0.0";
          port = publicPort;
          ssl = true;
        }
        {
          addr = "[::]";
          port = publicPort;
          ssl = true;
        }
      ];

      locations."/".proxyPass = "http://127.0.0.1:${toString backendPort}";
    };
  };

  systemd.services.taskchampion-sync-server = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."taskchampion.env".path;
      Restart = "on-failure";
      RestartSec = "5s";

      AmbientCapabilities = [ ];
      CapabilityBoundingSet = [ ];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
    };
  };

  security.acme.certs.${domain} = {
    dnsProvider = "alidns";
    extraLegoFlags = [
      "--dns.propagation-wait"
      "30s"
    ];
    credentialFiles = {
      ALICLOUD_ACCESS_KEY_FILE = config.sops.secrets.alicloud_access_key.path;
      ALICLOUD_SECRET_KEY_FILE = config.sops.secrets.alicloud_secret_key.path;
    };
    group = config.services.nginx.group;
  };

  networking.firewall.allowedTCPPorts = [ publicPort ];
}
