{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = "netbird.vps.seekerer.com";
  publicPort = 28443;
  stunPort = 28478;
  backendPort = 8081;
  publicUrl = "https://${domain}:${toString publicPort}";
  stateDirectory = "/var/lib/netbird";

  netbirdServer = pkgs.netbird.overrideAttrs (old: {
    pname = "netbird-server";
    subPackages = [ "combined" ];
    postInstall = ''
      mv "$out/bin/combined" "$out/bin/netbird-server"
    '';
    doInstallCheck = false;
    passthru = (old.passthru or { }) // {
      tests = { };
    };
    meta = old.meta // {
      mainProgram = "netbird-server";
    };
  });
in
{
  environment.systemPackages = [ netbirdServer ];

  users = {
    groups.netbird = { };
    users.netbird = {
      isSystemUser = true;
      group = "netbird";
      home = stateDirectory;
    };
  };

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      netbird_relay_auth_secret = {
        sopsFile = ./netbird.secrets.yaml;
        owner = "netbird";
        group = "netbird";
      };
      netbird_datastore_encryption_key = {
        sopsFile = ./netbird.secrets.yaml;
        owner = "netbird";
        group = "netbird";
      };
      netbird_idp_session_cookie_encryption_key = {
        sopsFile = ./netbird.secrets.yaml;
        owner = "netbird";
        group = "netbird";
      };
      alicloud_access_key = {
        sopsFile = ./netbird.secrets.yaml;
      };
      alicloud_secret_key = {
        sopsFile = ./netbird.secrets.yaml;
      };
    };

    templates."netbird-config.yaml" = {
      owner = "netbird";
      group = "netbird";
      mode = "0400";
      restartUnits = [ "netbird-server.service" ];
      content = ''
        server:
          listenAddress: ":${toString backendPort}"
          exposedAddress: "${publicUrl}"
          stunPorts:
            - ${toString stunPort}
          metricsPort: 9090
          healthcheckAddress: "127.0.0.1:9000"
          logLevel: "info"
          logFile: "console"
          disableAnonymousMetrics: true
          disableGeoliteUpdate: true
          authSecret: "${config.sops.placeholder.netbird_relay_auth_secret}"
          dataDir: "${stateDirectory}"
          auth:
            issuer: "${publicUrl}/oauth2"
            localAuthDisabled: false
            signKeyRefreshEnabled: true
            sessionCookieEncryptionKey: "${config.sops.placeholder.netbird_idp_session_cookie_encryption_key}"
            dashboardRedirectURIs:
              - "${publicUrl}/nb-auth"
              - "${publicUrl}/nb-silent-auth"
            dashboardPostLogoutRedirectURIs:
              - "${publicUrl}/"
            cliRedirectURIs:
              - "http://localhost:53000/"
          store:
            engine: "sqlite"
            encryptionKey: "${config.sops.placeholder.netbird_datastore_encryption_key}"
          reverseProxy:
            trustedHTTPProxies:
              - "127.0.0.1/32"
              - "::1/128"
            trustedPeers:
              - "127.0.0.1/32"
              - "::1/128"
      '';
    };
  };

  systemd.services.netbird-server = {
    description = "NetBird combined server";
    documentation = [ "https://docs.netbird.io/selfhosted/" ];
    environment.NB_DISABLE_GEOLOCATION = "true";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "network-online.target"
      "sops-nix.service"
    ];
    serviceConfig = {
      Type = "simple";
      User = "netbird";
      Group = "netbird";
      StateDirectory = "netbird";
      StateDirectoryMode = "0750";
      WorkingDirectory = stateDirectory;
      ExecStart = "${lib.getExe netbirdServer} --config ${
        config.sops.templates."netbird-config.yaml".path
      }";
      Restart = "on-failure";
      RestartSec = "5s";
      UMask = "0077";

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

  services = {
    netbird.server.dashboard = {
      enable = true;
      enableNginx = false;
      domain = domain;
      managementServer = publicUrl;
      settings = {
        AUTH_AUDIENCE = "netbird-dashboard";
        AUTH_AUTHORITY = "${publicUrl}/oauth2";
        AUTH_CLIENT_ID = "netbird-dashboard";
        AUTH_CLIENT_SECRET = "";
        AUTH_REDIRECT_URI = "/nb-auth";
        AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
        AUTH_SUPPORTED_SCOPES = "openid profile email groups";
        NETBIRD_TOKEN_SOURCE = "accessToken";
        USE_AUTH0 = false;
      };
    };

    nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts.${domain} = {
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
        root = config.services.netbird.server.dashboard.finalDrv;

        extraConfig = ''
          client_header_timeout 1d;
          client_body_timeout 1d;
        '';

        locations = {
          "~ ^/(relay|ws-proxy/)" = {
            proxyPass = "http://127.0.0.1:${toString backendPort}";
            proxyWebsockets = true;
            recommendedProxySettings = false;
            extraConfig = ''
              proxy_set_header Host ${domain}:${toString publicPort};
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Real-Port $remote_port;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-Host ${domain}:${toString publicPort};
              proxy_read_timeout 1d;
              proxy_send_timeout 1d;
            '';
          };

          "~ ^/(signalexchange\\.SignalExchange|management\\.(ManagementService|ProxyService))/" = {
            extraConfig = ''
              grpc_pass grpc://127.0.0.1:${toString backendPort};
              grpc_set_header Host ${domain}:${toString publicPort};
              grpc_set_header X-Real-IP $remote_addr;
              grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              grpc_set_header X-Forwarded-Proto https;
              grpc_set_header X-Forwarded-Host ${domain}:${toString publicPort};
              grpc_read_timeout 1d;
              grpc_send_timeout 1d;
              grpc_socket_keepalive on;
            '';
          };

          "~ ^/(api|oauth2)(/|$)" = {
            proxyPass = "http://127.0.0.1:${toString backendPort}";
            recommendedProxySettings = false;
            extraConfig = ''
              proxy_set_header Host ${domain}:${toString publicPort};
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto https;
              proxy_set_header X-Forwarded-Host ${domain}:${toString publicPort};
              proxy_read_timeout 1d;
            '';
          };

          "= /nb-auth".tryFiles = "/index.html =404";
          "= /nb-silent-auth".tryFiles = "/index.html =404";

          "/" = {
            tryFiles = "$uri $uri.html $uri/ =404";
          };

          "= /404.html".extraConfig = "internal;";
        };
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "gmx472@qq.com";
    certs.${domain} = {
      dnsProvider = "alidns";
      # The VPS cannot reliably query every AliDNS authoritative server over
      # IPv6. Wait for propagation instead of making issuance depend on that
      # network path.
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
  };

  networking.firewall = {
    allowedTCPPorts = [ publicPort ];
    allowedUDPPorts = [ stunPort ];
  };
}
