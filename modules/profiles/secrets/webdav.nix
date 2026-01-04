{
  config,
  pkgs,
  ...
}:
{
  options.seeker.secrets.webdav = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Enable WebDAV(123PAN)";
    };
  };
  config = lib.mkIf config.seeker.secrets.webdav.enable {
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

        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /mnt/123PAN";

        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount \
            --config /etc/rclone/rclone.conf \
            --allow-other \
            --vfs-cache-mode full \
            --log-level INFO \
            123PAN: /mnt/123PAN
        '';

        ExecStop = "${pkgs.fuse}/bin/fusermount -u /mnt/123PAN";
        Restart = "always";
        RestartSec = "10s";
      };
    };
  };
}
