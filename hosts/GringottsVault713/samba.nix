{ config, pkgs, ... }:

{

  config = {
    environment.systemPackages = with pkgs; [
      rclone
      cifs-utils # 用于挂载 SMB
      samba # 提供 smbpasswd 工具
    ];

    # 'd' 代表目录, '0777' 是权限, 'root' 是所有者
    systemd.tmpfiles.rules = [
      "d /share 0777 root root -"
      "d /share/webdav 0777 root root -"
    ];
    seeker.secrets.webdav = {
      mountPoint = "/share/webdav";
      extraArgs = [
        "--vfs-cache-max-size=100G"
        "--vfs-cache-max-age=24h"
        "--vfs-read-chunk-size=32M"
        "--buffer-size=32M"
        "--umask=000"
      ];
    };

    services.samba = {
      enable = true;
      openFirewall = true;

      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "NixOS NAS";
          "netbios name" = "nixos-nas";
          "security" = "user";
          "hosts allow" = "192.168. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };

        # 分享名称 [Share]
        "Share" = {
          "path" = "/share";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0777";
          "directory mask" = "0777";
          # 强制使用 root 操作文件，确保 Rclone 挂载点可写
          "force user" = "root";
        };
      };
    };
  };
}
