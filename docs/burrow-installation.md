# burrow 全新安装

本文档用于从 NixOS LiveCD 将 `nixosConfigurations.burrow` 安装到 Dell
Wyse 5070。Disko 只允许清空以下 128 GB SK hynix SATA SSD：

```text
/dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MJ86N833110606T20
```

16 GB eMMC 上的 Windows 和当前 Ventoy U 盘都不属于安装目标。

## 安装前检查

在 LiveCD 中确认目标盘、UEFI 模式和不可触碰的磁盘：

```bash
lsblk -d -o NAME,PATH,SIZE,MODEL,SERIAL,TRAN
readlink -f /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MJ86N833110606T20
test "$(readlink -f /dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MJ86N833110606T20)" = /dev/sda
test -b /dev/mmcblk0
test -d /sys/firmware/efi/efivars
```

预期目标盘解析为 `/dev/sda`；`/dev/mmcblk0` 是应保留的 Windows eMMC；
Ventoy U 盘当前是 `/dev/sdb`。任一设备对应关系变化时必须停止安装并重新核对。

## 准备配置和 identity

将包含 burrow 修改的完整 worktree 传到 LiveCD 的 `/tmp/flakes`，并将本机
git-ignored 的专用 identity 安全传到 `/tmp/burrow-age-key`：

```text
.secrets/age/burrow.txt
```

identity 必须满足：

```bash
chmod 0600 /tmp/burrow-age-key
grep -q '^AGE-SECRET-KEY-' /tmp/burrow-age-key
```

在清盘前备份 LiveCD 当前已连接的 `Home` NetworkManager profile：

```bash
sudo install -m 0600 \
  /etc/NetworkManager/system-connections/Home.nmconnection \
  /tmp/Home.nmconnection
```

该文件包含 Wi-Fi 密码，只保留在 LiveCD 的 `/tmp` 和目标系统中，不放入仓库。

在工作站上完成 flake 检查和完整构建；LiveCD 的可写 Nix store 是内存支持的
`tmpfs`，不要在 LiveCD 上重复完整检查或预构建系统。LiveCD 上只求值目标设备：

```bash
cd /tmp/flakes
nix --extra-experimental-features 'nix-command flakes' eval --raw \
  "path:$PWD#nixosConfigurations.burrow.config.machine.disko.device"
```

第二条命令必须输出本文开头的 SK hynix `by-id` 路径。

## Disko 清盘、分区并挂载

以下命令是破坏性步骤，会删除 SATA SSD 上的 Proxmox、LVM 和 VM 101。
Disko 版本固定为仓库 `flake.lock` 使用的提交；单任务、单核运行，避免给
8 GiB LiveCD 增加不必要的并行内存压力：

```bash
target=/dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MJ86N833110606T20
test "$(readlink -f "$target")" = /dev/sda

sudo nix \
  --extra-experimental-features 'nix-command flakes' \
  --option substituters \
    'https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org' \
  --option fallback true \
  --max-jobs 1 \
  --cores 1 \
  run github:nix-community/disko/de5708739256238fb912c62f03988815db89ec9a -- \
  --mode destroy,format,mount \
  --flake path:/tmp/flakes#burrow
```

完成后必须看到 `/mnt` 和 `/mnt/boot`，且 Disko 生成的 GPT partition label
与系统配置一致：

```bash
findmnt -R /mnt
ls -l /dev/disk/by-partlabel/disk-main-root
ls -l /dev/disk/by-partlabel/disk-main-ESP
```

在第一次激活前放置 burrow identity：

```bash
sudo install -d -m 0755 -o 1000 -g 100 /mnt/home/seeker
sudo install -d -m 0700 -o 1000 -g 100 \
  /mnt/home/seeker/.config/sops/age
sudo install -m 0600 -o 1000 -g 100 /tmp/burrow-age-key \
  /mnt/home/seeker/.config/sops/age/keys.txt

sudo install -d -m 0700 -o 0 -g 0 \
  /mnt/etc/NetworkManager/system-connections
sudo install -m 0600 -o 0 -g 0 /tmp/Home.nmconnection \
  /mnt/etc/NetworkManager/system-connections/Home.nmconnection
```

## 安装系统

使用标准安装器直接在目标盘的 Nix store 中构建：

```bash
# 给构建峰值准备 SSD 临时 swap；正式系统使用 zram，不保留该文件。
sudo fallocate -l 8G /mnt/.install-swap
sudo chmod 0600 /mnt/.install-swap
sudo mkswap /mnt/.install-swap
sudo swapon /mnt/.install-swap

sudo env GOPROXY=https://goproxy.cn,direct \
  nixos-install --flake "path:$PWD#burrow" \
  --no-write-lock-file \
  --no-channel-copy \
  --no-root-password \
  --max-jobs 1 \
  --cores 1 \
  --option substituters \
    'https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org' \
  --option fallback true

sudo swapoff /mnt/.install-swap
sudo rm -- /mnt/.install-swap
```

`nixos-install` 会显式使用 `/mnt` 作为 Nix store，因此系统闭包直接写入 SSD；
`GOPROXY` 供未命中二进制缓存的 Go fixed-output derivation 使用。

安装成功后重启并移除 Ventoy U 盘。安装器会在固件中注册 SSD 上的新 NixOS
启动项，但不会改写 eMMC 上的 Windows EFI 分区或删除 Windows 启动项。

## 首次启动

有线 DHCP 的路由 metric 低于 Wi-Fi；接入网线时优先使用有线，Wi-Fi `Home`
仍会自动连接作为后备。首次启动后检查：

```bash
systemctl --failed
systemctl status sshd NetworkManager mihomo netbird
sudo ss -lntup
sudo nft list ruleset
```

Mihomo 的 `7890/tcp`、`7891/tcp` 和 `7891/udp` 只应允许源地址
`192.168.3.0/24`。SSH 使用与 miLaptop 相同的入站 authorized keys；
`/home/seeker/.ssh/id_admin` 由 Home Manager 以 `0600` 部署。

NetBird 客户端需要在首次启动后单独登记，setup key 不写入仓库。完成登记后
再次确认 NetBird、Mihomo、SSH 和有线/Wi-Fi 故障切换。
