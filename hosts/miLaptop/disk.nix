{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # 1. 必须启用 Systemd Initrd 以支持 TPM 和下面的脚本逻辑
  boot.initrd.systemd.enable = true;
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };
  boot.initrd.luks.devices."crypted".crypttabExtraOpts = [ "tpm2-device=auto" ];

  boot.supportedFilesystems = [
    "ntfs"
    "exfat"
  ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];

  fileSystems."/persist".neededForBoot = true;
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_ed25519_key"
    ];
    # remains empty for now
    users.seeker = {
      directories = [
        ".zen"
        "nixos-config"
        "age"
      ];
    };
  };

  boot.initrd.systemd.services.rollback = {
    description = "Rollback BTRFS root subvolume to a pristine state";
    wantedBy = [ "initrd.target" ];
    # 在解密后运行，在挂载根文件系统前运行
    after = [ "systemd-cryptsetup@crypted.service" ];
    before = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /btrfs_tmp

      mount /dev/mapper/crypted /btrfs_tmp

      if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root

      umount /btrfs_tmp
    '';
  };

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NU0W123827";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted"; # 解密后的设备映射名为 /dev/mapper/crypted

                settings = {
                  # 启用 TRIM 支持。
                  allowDiscards = true;

                  keyFile = "/tmp/secret.key";
                };

                # 额外的 cryptsetup 参数 (可选)
                # extraOpenArgs = [ ];

                # === 内部文件系统 (Btrfs) ===
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    # 根目录 (易失)
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };

                    # Nix Store (必须持久化)
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };

                    # 数据持久化层
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };

                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap = {
                        swapfile.size = "32G";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
