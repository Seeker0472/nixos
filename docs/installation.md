# NixOS 安装

本流程用于 `miLaptop`、`DiagonAlley` 和 `burrow`。三台机器都由 Disko 清空
目标盘；磁盘路径和 SOPS 密钥必须按下表选择。

| 配置名 | 目标盘 | SOPS 密钥 | 目标路径 |
| --- | --- | --- | --- |
| `miLaptop` | `/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNA0K906073` | `.secrets/age/keys.txt` | `/mnt/persist/home/seeker/.config/sops/age/keys.txt` |
| `DiagonAlley` | `/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NU0W123827` | `.secrets/age/DiagonAlley.txt` | `/mnt/persist/home/seeker/.config/sops/age/keys.txt` |
| `burrow` | `/dev/disk/by-id/ata-SK_hynix_SC311_SATA_128GB_MJ86N833110606T20` | `.secrets/age/burrow.txt` | `/mnt/home/seeker/.config/sops/age/keys.txt` |

## 1. SCP 源码和密钥

从不含 `.secrets` 的干净 worktree 传输源码，只单独传输目标机器对应的
SOPS 密钥：

```bash
scp -r <WORKTREE> nixos@<LIVECD_IP>:/tmp/flakes
scp <SOPS_KEY> nixos@<LIVECD_IP>:/tmp/age-key
```

## 2. 检查磁盘标识并运行 Disko

在 LiveCD 中填入表中的 `HOST`、`DISK` 和 `KEY_TARGET`。`readlink` 的结果必须
与 `lsblk` 中准备清空的物理盘一致：

```bash
HOST='<FLAKE>'
DISK='<目标盘 by-id>'
KEY_TARGET='<密钥目标路径>'

readlink -f "$DISK"
lsblk -d -o NAME,SIZE,MODEL,SERIAL "$(readlink -f "$DISK")"

cd /tmp/flakes
sudo nix \
  --extra-experimental-features 'nix-command flakes' \
  --option substituters \
    'https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org' \
  --option fallback true \
  run github:nix-community/disko/de5708739256238fb912c62f03988815db89ec9a -- \
  --mode destroy,format,mount \
  --flake "path:$PWD#$HOST"

sudo install -D -m 0600 -o 1000 -g 100 /tmp/age-key "$KEY_TARGET"
test ! -e /mnt/.swapvol/swapfile || sudo swapon /mnt/.swapvol/swapfile
```

## 3. 使用镜像站安装

```bash
sudo env GOPROXY=https://goproxy.cn,direct \
  nixos-install \
  --flake "path:$PWD#$HOST" \
  --no-write-lock-file \
  --no-channel-copy \
  --no-root-password \
  --option substituters \
    'https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org' \
  --option fallback true
```

## King'sCross

`King'sCross` 只在首次安装或确定要清空 VPS 时使用 `nixos-anywhere`；日常更新
遵循 `docs/maintenance/kings-cross.md`。`--copy-host-keys` 保留现有 SSH host key，
使重装后的系统仍能解密 SOPS 文件：

```bash
cd /home/seeker/nixos-config
nix \
  --option substituters \
    'https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store https://mirrors.ustc.edu.cn/nix-channels/store https://cache.nixos.org' \
  --option fallback true \
  run github:nix-community/nixos-anywhere -- \
  --flake "path:$PWD#King'sCross" \
  --target-host root@vps.seekerer.com \
  -i /home/seeker/.ssh/id_admin \
  --copy-host-keys
```

## 其他 target

除注明的 PowerShell 命令外，以下命令均在仓库根目录执行：

```bash
# devVM：自动创建或复用 qcow2。
nix run --no-write-lock-file "path:$PWD#devVMQemu"

# nixos-wsl：在 Nix 环境中构建 tarball。
sudo nix run --no-write-lock-file \
  "path:$PWD#nixosConfigurations.nixos-wsl.config.system.build.tarballBuilder"

# 在包含 nixos.wsl 的目录中使用 PowerShell 导入。
wsl --install --from-file nixos.wsl --name NixOS

# 首次进入 nixos-wsl 后放置密钥并激活配置。
install -D -m 0600 .secrets/age/keys.txt ~/.config/sops/age/keys.txt
sudo nixos-rebuild switch --flake "path:$PWD#nixos-wsl"

# mi15 / miPad：先安装并启动 Nix-on-Droid 应用，再选择对应配置。
install -D -m 0600 .secrets/age/mi15.txt ~/.config/sops/age/keys.txt
nix-on-droid switch --flake "path:$PWD#mi15"

install -D -m 0600 .secrets/age/miPad.txt ~/.config/sops/age/keys.txt
nix-on-droid switch --flake "path:$PWD#miPad"

# gpu01：独立 Home Manager 配置。
install -D -m 0600 .secrets/age/gpu01.txt ~/.config/sops/age/keys.txt
nix run github:nix-community/home-manager -- \
  switch --flake "path:$PWD#seeker4721@gpu01"

# 开发容器镜像。
nix build --no-write-lock-file "path:$PWD#devContainerImage"
docker load < result
```
