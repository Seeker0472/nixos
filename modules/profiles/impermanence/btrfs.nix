{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.machine.btrfs.impermanence;
  impermanenceEnabled = config.machine.impermanence.enable;
in
{
  # TODO :hibrnate don't work
  config = mkIf impermanenceEnabled (mkMerge [
    {
      boot.initrd.systemd.enable = true;
      boot.initrd.supportedFilesystems = [ "btrfs" ];
      # boot.initrd.supportedFilesystems = lib.mkForce [ ];
      boot.initrd.availableKernelModules = [
        "btrfs"
        "crc32c"
      ];
      boot.initrd.kernelModules = [
        # "dm-snapshot"
      ];
      boot.initrd.luks.devices."${cfg.luksName}".crypttabExtraOpts = [ "tpm2-device=auto" ];
      boot.initrd.systemd.services.create-needed-for-boot-dirs.after = [ "local-fs-pre.target" ];

      # 2. 回滚逻辑 (提取出来的通用脚本)
      boot.initrd.systemd.services.rollback = {
        description = "Rollback BTRFS root subvolume to a pristine state";
        wantedBy = [ "initrd.target" ];
        after = [
          "systemd-cryptsetup@${cfg.luksName}.service"
          "systemd-hibernate-resume.service"
        ];
        before = [ "sysroot.mount" ];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          # manually modprobe btrfs as we don't use boot.supportedFilesystems
          # modprobe btrfs

          mkdir -p /btrfs_tmp
          mount /dev/mapper/${cfg.luksName} /btrfs_tmp

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

          # 使用变量控制保留天数
          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +${toString cfg.retentionDays}); do
              delete_subvolume_recursively "$i"
          done

          btrfs subvolume create /btrfs_tmp/root
          umount /btrfs_tmp
        '';
      };

      # 3. Disko 配置 (使用变量生成)
      disko.devices.disk.main = {
        type = "disk";
        device = cfg.device;
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
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = cfg.luksName;
                settings.allowDiscards = cfg.allowDiscards;
              }
              // optionalAttrs (cfg.luksKeyFile != null) {
                keyFile = cfg.luksKeyFile;
              }
              // {
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "${config.machine.btrfs.impermanence.persistdir}" = {
                      mountpoint = "${config.machine.btrfs.impermanence.persistdir}";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    }
    (mkIf (cfg.resumeDevice != null) {
      boot.resumeDevice = cfg.resumeDevice;
    })
    (mkIf (cfg.resumeOffset != null) {
      boot.kernelParams = [ "resume_offset=${toString cfg.resumeOffset}" ];
    })
  ]);
}
