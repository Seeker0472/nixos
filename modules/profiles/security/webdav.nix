{
  config,
  pkgs,
  ...
}:
let
  username = "seeker";
  keyRelativePath = "age/keys";
in
{
  sops.age.keyFile =
    if config.seeker.impermanence.enable then
      "/persist/home/${username}/${keyRelativePath}"
    else
      "/home/${username}/${keyRelativePath}";

  sops.secrets."rclone" = {
    sopsFile = ./webdav.secrets.yaml;
    key = "rclone_conf";
    owner = "root";
    group = "root";
    mode = "600";
    # this is the path where the secret will be mounted
    path = "/etc/rclone/rclone.conf";
  };
  sops.secrets."nix_config" = {
    sopsFile = ./webdav.secrets.yaml;
    key = "nix_config";
    owner = "root";
    group = "wheel";
    mode = "0440";
    path = "/etc/nix/my_nix.conf";
  };
  nix.extraOptions = ''
    !include ${config.sops.secrets.nix_config.path}
  '';
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
}
