# miLaptop 全新安装

本文档用于从 NixOS LiveCD 将 `nixosConfigurations.miLaptop` 全新安装到
miLaptop。当前磁盘布局会清空整块目标盘，并创建：

- 512 MiB EFI System Partition；
- 占用其余空间的 LUKS2 容器；
- LUKS 内的 Btrfs `root`、`nix`、`persist` 和 `swap` 子卷。

该布局不保留 Windows、现有分区或其他数据。日常更新应使用
`nixos-rebuild`，不要重新运行本安装流程。

## 当前目标盘

当前配置的目标盘是：

```text
/dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNA0K906073
```

在 LiveCD 中确认它仍然解析为 `/dev/nvme0n1`：

```bash
lsblk -d -o NAME,PATH,SIZE,MODEL,SERIAL
readlink -f /dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNA0K906073
test "$(readlink -f /dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNA0K906073)" = /dev/nvme0n1
```

当前 `/dev/sda` 是 LiveCD U 盘，不得作为安装目标。更换硬盘后，必须先更新
`hosts/miLaptop/disk.nix`，再更新本文档中的设备路径。

同时确认 LiveCD 以 UEFI 模式启动：

```bash
test -d /sys/firmware/efi/efivars && echo "UEFI OK"
```

没有看到 `UEFI OK` 时不要继续安装。

## 准备配置仓库

安装必须使用包含最新 miLaptop 修改的完整工作区。只有当本地修改已经提交并
推送后，才可以直接从 GitHub 克隆：

```bash
git clone --branch develop https://github.com/Seeker0472/flakes.git /tmp/flakes
```

存在未提交或未推送修改时，应通过 SSH 传输当前工作区。不要把 `.secrets`
目录混入配置仓库副本。以下命令中的 `WORKSTATION_IP` 必须替换为保存该工作区
的机器地址：

```bash
mkdir -p /tmp/flakes
ssh seeker@WORKSTATION_IP \
  'cd /home/seeker/flakes && tar --exclude=./.secrets --exclude=./result -czf - .' \
  | tar -xzf - -C /tmp/flakes
```

LiveCD 默认没有启用 `nix-command` 和 `flakes`。其中每条直接调用 `nix` 的命令
都要显式加入 `--extra-experimental-features 'nix-command flakes'`：

```bash
cd /tmp/flakes

nix --extra-experimental-features 'nix-command flakes' \
  flake check --no-build --no-write-lock-file "path:$PWD"

nix --extra-experimental-features 'nix-command flakes' \
  eval --raw \
  "path:$PWD#nixosConfigurations.miLaptop.config.machine.btrfs.impermanence.device"
```

第二条命令必须输出本文档开头列出的目标盘 `by-id` 路径。

## 准备 SOPS age identity

当前配置启用了 secret deployment。`nixos-install` 的激活阶段需要 SOPS 管理
身份，因此必须在安装前将工作机上的：

```text
/home/seeker/flakes/.secrets/age/keys.txt
```

安全传输到 LiveCD 的临时文件：

```bash
scp seeker@WORKSTATION_IP:/home/seeker/flakes/.secrets/age/keys.txt \
  /tmp/admin-age-key
chmod 0600 /tmp/admin-age-key
grep -q '^AGE-SECRET-KEY-' /tmp/admin-age-key && echo "age key OK"
```

该文件是 SOPS age 私钥，不是 SSH 私钥、LUKS 密码或 recovery identity。不得
显示其内容或提交到 Git。

## 执行安装

再次执行只读检查：

```bash
test -d /sys/firmware/efi/efivars \
  && test -b /dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNA0K906073 \
  && test "$(readlink -f /dev/disk/by-id/nvme-SAMSUNG_MZVLB256HAHQ-000L7_S41GNA0K906073)" = /dev/nvme0n1 \
  && test -s /tmp/admin-age-key \
  && echo "install preflight OK"
```

只有四项检查全部成功并看到 `install preflight OK` 后，才继续。

### 1. 分区并挂载

下面是本流程中的破坏性步骤，会清空整块 Samsung NVMe：

```bash
cd /tmp/flakes

sudo nix --extra-experimental-features 'nix-command flakes' \
  run 'github:nix-community/disko/latest' -- \
  --mode destroy,format,mount \
  --flake "path:$PWD#miLaptop"
```

Disko 会要求输入并确认新的 LUKS 密码。该密码是 TPM 自动解锁失效时的恢复
凭据，必须妥善保存。命令完成后，根文件系统及其子卷应挂载在 `/mnt`：

```bash
findmnt -R /mnt
test -f /mnt/.swapvol/swapfile && echo "swapfile OK"
```

必须看到 `/mnt`、`/mnt/boot`、`/mnt/nix`、`/mnt/persist` 和
`/mnt/.swapvol`。没有看到 `swapfile OK` 时不要继续。

### 2. 启用安装期 swap

当前桌面系统的 Nix 闭包很大。不要使用 `disko-install`：它会在 LiveCD 的
内存 store 中准备整个闭包，并通过 `DISKO_SKIP_SWAP=1` 禁用目标盘 swap，
内存较小时容易被 OOM killer 终止。

Disko 已在新盘上创建 32 GiB swapfile，但不会在这个模式下自动启用。手动
启用它：

```bash
sudo swapon /mnt/.swapvol/swapfile
swapon --show
free -h
```

`swapon --show` 必须列出 `/mnt/.swapvol/swapfile`。

### 3. 放置 SOPS age identity

将 age identity 放入新系统的持久化目录，并设置目标系统中 `seeker:users`
对应的 UID/GID `1000:100`：

```bash
sudo install -d -m 0755 -o 0 -g 0 \
  /mnt/persist/home
sudo install -d -m 0755 -o 1000 -g 100 \
  /mnt/persist/home/seeker
sudo install -d -m 0700 -o 1000 -g 100 \
  /mnt/persist/home/seeker/.config/sops/age
sudo install -m 0600 -o 1000 -g 100 \
  /tmp/admin-age-key \
  /mnt/persist/home/seeker/.config/sops/age/keys.txt

sudo stat -c '%a %u:%g %n' \
  /mnt/persist/home/seeker/.config/sops/age/keys.txt
```

预期权限和所有者编号为 `600 1000:100`。

### 4. 安装系统

使用标准 `nixos-install`，让 Nix 直接在目标盘的 `/mnt/nix/store` 中构建，
同时限制构建并行度：

```bash
cd /tmp/flakes

sudo nixos-install \
  --flake "path:$PWD#miLaptop" \
  --no-write-lock-file \
  --no-channel-copy \
  --no-root-password \
  --max-jobs 1 \
  --cores 1
```

`nixos-install --flake` 内部会为其 Nix 调用启用 `nix-command flakes`，这里不需要
也不能直接追加 `--extra-experimental-features`。

如果该步骤因网络等临时问题失败，可以保持挂载和 swap，直接重跑同一条
`nixos-install` 命令；不要再次运行会清盘的 Disko 步骤。

### OOM 后重新开始

如果此前的 `disko-install` 已被 OOM killer 终止，建议先重启 LiveCD，以释放
内存 store 和残留进程。`/tmp` 会被清空，因此需要重新准备 `/tmp/flakes` 和
`/tmp/admin-age-key`，然后从本节第 1 步重新安装。目标盘已经没有需要保留的
数据时，可以让 Disko 重新创建布局。

安装成功前不要关机或拔出 LiveCD。

## 首次启动

看到 `installation finished!` 后：

```bash
sync
sudo reboot
```

移除 LiveCD。首次启动尚未登记 TPM token，需要手动输入刚才设置的 LUKS
密码。进入系统后检查：

```bash
sudo stat -c '%a %U:%G %n' \
  /persist/home/seeker/.config/sops/age/keys.txt
systemctl --failed
systemctl status home-manager-seeker.service mihomo.service rclone-webdav.service
```

age key 应属于 `seeker:users`，权限应为 `600`。如需修正：

```bash
sudo chown seeker:users /persist/home/seeker/.config/sops/age/keys.txt
sudo chmod 0600 /persist/home/seeker/.config/sops/age/keys.txt
```

安装命令没有复制配置仓库。系统启动后，再将与安装时相同的工作区放入：

```text
/home/seeker/nixos-config
```

该目录已由 impermanence 配置持久化。只有所有修改均已推送时，才直接克隆
远端仓库；否则应从原工作机传输同一工作区。

## 登记 TPM 自动解锁

确认 LUKS 恢复密码可用后登记 TPM token：

```bash
sudo systemd-cryptenroll --tpm2-device=list
sudo systemd-cryptenroll \
  --tpm2-device=auto \
  /dev/disk/by-partlabel/disk-main-luks
```

登记过程会要求输入现有 LUKS 密码。不要删除密码 keyslot；它是 TPM 或固件
状态异常时的恢复入口。登记后重启一次，验证无需输入密码即可解锁。

## 休眠

miLaptop 以 UEFI 启动，并使用 systemd initrd。当前 systemd 会在休眠时自动
选择 swapfile，将设备和当时的 Btrfs offset 写入 `HibernateLocation` EFI
变量，并在下次启动的 initrd 中恢复。因此配置显式允许 `hibernate` 和
`suspend-then-hibernate`，同时有意将 `resumeDevice` 与 `resumeOffset` 保持为
`null`，避免 Disko 重新创建 swapfile 后留下失效的静态 offset。

进入新系统后先确认休眠可用：

```bash
swapon --show
busctl call \
  org.freedesktop.login1 \
  /org/freedesktop/login1 \
  org.freedesktop.login1.Manager \
  CanHibernate
```

预期 swap 列表包含 `/.swapvol/swapfile`，且 `CanHibernate` 返回 `yes`。首次测试
使用 `systemctl hibernate`，恢复后检查本次启动日志中是否同时出现
`hibernation entry` 与 `hibernation exit`。

只有系统不是以 UEFI 启动，或自动 `HibernateLocation` 路径无法工作时，才使用
手工 fallback。先计算当前 swapfile 的 offset：

```bash
sudo btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
```

将输出的整数写回 `hosts/miLaptop/disk.nix`：

```nix
resumeDevice = "/dev/mapper/crypted";
resumeOffset = 123456; # 替换为 map-swapfile 输出的整数
```

然后验证并激活：

```bash
cd /home/seeker/nixos-config
sudo nixos-rebuild dry-build --flake "path:$PWD#miLaptop"
sudo nixos-rebuild test --flake "path:$PWD#miLaptop"
sudo nixos-rebuild switch --flake "path:$PWD#miLaptop"
sudo systemctl reboot
```

重启进入新 generation 后，必须先确认两个参数都已生效，才能测试休眠：

```bash
grep -oE 'resume=[^ ]+|resume_offset=[^ ]+' /proc/cmdline
```

`nixos-rebuild switch` 无法改变正在运行内核的命令行，因此不能省略这次重启。
swapfile 被删除或重新创建后，必须重新计算 `resumeOffset`；不能复用安装前或
其他 swapfile 的数值。

## 延后放置 age identity

本流程不使用 `--extra-files`，而是在运行 `nixos-install` 前手动将 age identity
放入新系统。当前配置的安装激活阶段需要它，不能直接省略该步骤。

如需在首次启动后才放置 age identity，必须在安装前临时设置：

```nix
machine.secrets.deploy = false;
```

此时才可以跳过“放置 SOPS age identity”。首次启动后应先放置 age key，再
删除该临时设置并运行一次 `nixos-rebuild switch`。当前配置保持 secret
deployment 启用时，不能直接省略 age identity。
