{ config, lib, pkgs, modulesPath, ... }: {
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "ntfs" ];
  # mount data part
  fileSystems."/mnt/Data" = {
    device = "/dev/disk/by-label/Data";
    fsType = "exfat";
    options = [ "noatime" "x-systemd.automount" ];
  };
  # services.davfs2.enable = true;

  # FIXME:use TPM for auth

  sops.age.keyFile = "${config.users.users.seeker.home}/.config/age/keys";

  sops.secrets."rclone" = {
    sopsFile = ./webdav.secrets.yaml;
    key = "rclone_conf";
    owner = "root";
    group = "root";
    mode = "600";
    # this is the path where the secret will be mounted
    path = "/etc/rclone/rclone.conf";
  };
# FIXME:rename it and move it into common!
  sops.secrets."nix_config" = {
    sopsFile = ./webdav.secrets.yaml;
    key = "nix_config";
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

  # Difficult to use
  # Switched to `rclone mount` 
  # sops.secrets."davfs" = {
  #   sopsFile = ./webdav.secrets.yaml;
  #   key = "123PAN_cridentials";
  #   owner = "root";
  #   group = "root";
  #   mode = "600";
  #   # this is the path where the secret will be mounted
  #   path = "/etc/davfs2/secrets";
  # };
  # systemd.mounts = [
  #   {
  #     description = "123PAN";
  #     after = [ "network-online.target" ];
  #     wants = [ "network-online.target" ];
  #     what = "https://webdav-1813940027.pd1.123pan.cn/webdav";
  #     where = "/mnt/123PAN";
  #     options = "noauto,x-systemd.automount,_netdev,uid=1000,gid=100";
  #     #options = "x-systemd.automount,uid=1000,gid=100";
  #     type = "davfs";
  #   }
  # ];
  # systemd.automounts = [
  #    {
  #      description = "123PAN webdav automount";
  #      where = "/mnt/123PAN";
  #      wantedBy = [ "multi-user.target" ];
  #      automountConfig = {
  #        TimeoutIdleSec = "2m";
  #      };
  #    }
  # ];


}
