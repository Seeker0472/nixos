{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.machine.secrets.webdav;
in
with lib;
{
  options.machine.secrets.webdav = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Enable WebDAV(123PAN)";
    };
    extraArgs = lib.mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra arguments for rclone mount";
    };
    mountPoint = lib.mkOption {
      type = types.path;
      default = "/mnt/123PAN";
      description = "Mount point for WebDAV";
    };
  };
  config = lib.mkIf (cfg.enable && config.machine.secrets.deploy) {
    sops.secrets."rclone" = {
      sopsFile = ./sys.secrets.yaml;
      key = "rclone_conf";
      owner = "root";
      group = "root";
      mode = "600";
      # this is the path where the secret will be mounted
      path = "/etc/rclone/rclone.conf";
    };

    systemd.services.rclone-webdav = {
      description = "Rclone Mount for WebDAV ( 123PAN )";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        User = "root";
        Group = "root";

        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${cfg.mountPoint}";

        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount \
            --config /etc/rclone/rclone.conf \
            --allow-other \
            --vfs-cache-mode full \
            --log-level INFO \
            ${lib.escapeShellArgs cfg.extraArgs}\
            123PAN: ${cfg.mountPoint}
        '';

        ExecStop = "${pkgs.fuse}/bin/fusermount -u ${cfg.mountPoint}";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
