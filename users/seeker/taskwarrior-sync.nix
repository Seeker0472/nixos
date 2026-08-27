{
  config,
  lib,
  osConfig,
  ...
}:
let
  secretsFile = ./taskwarrior.secrets.yaml;
  syncConfig = config.sops.templates."taskwarrior-sync.conf".path;
in
lib.mkIf config.programs.taskwarrior.enable {
  sops = {
    secrets = {
      taskwarrior_client_id = {
        sopsFile = secretsFile;
        key = "client_id";
      };
      taskwarrior_encryption_secret = {
        sopsFile = secretsFile;
        key = "encryption_secret";
      };
    };

    templates."taskwarrior-sync.conf" = {
      mode = "0400";
      content = ''
        sync.server.client_id=${config.sops.placeholder.taskwarrior_client_id}
        sync.encryption_secret=${config.sops.placeholder.taskwarrior_encryption_secret}
      '';
    };
  };

  programs.taskwarrior = {
    config = {
      recurrence = osConfig.networking.hostName == "miLaptop";
      sync.server.url = "https://vps.seekerer.com:28443";
    };
    extraConfig = lib.mkAfter ''
      include ${syncConfig}
    '';
  };
}
