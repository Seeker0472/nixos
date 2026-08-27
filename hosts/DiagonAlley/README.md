# DiagonAlley 安装备注

本主机已按 `miLaptop` 的用户态和 Btrfs impermanence 结构接入。2026-08-27
从 NixOS Live ISO 确认的安装目标是 1 TB Samsung NVMe：

```text
/dev/nvme1n1
953.87 GiB
SAMSUNG MZVL21T0HCLR-00B00
S676NU0W123827
/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NU0W123827
```

每次执行 Disko 前都必须重新确认稳定路径仍然解析到这块盘：

```bash
target=/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NU0W123827
test "$(readlink -f "$target")" = /dev/nvme1n1
lsblk -d -o NAME,PATH,SIZE,MODEL,SERIAL,TRAN "$target"
```

这块盘当前是 Windows GPT，包含 EFI、MSR、约 952.8 GiB NTFS 数据分区和
Windows Recovery。当前 Disko 布局会永久清除这四个分区，并创建 UEFI、
LUKS2、Btrfs `root`/`nix`/`persist` 和 32 GiB swapfile。必须确认数据已备份后
才能运行 `destroy,format,mount`。不得操作保留 Windows 的 512 GB
`/dev/nvme0n1`，也不得操作 Ventoy U 盘或 USB NVMe。

Live ISO 已确认以 UEFI 启动。硬件探测结果已写入
`hardware-configuration.nix`：Ryzen 9 9950X、RTX 5070、Intel AX210、
Realtek RTL8125 与 TPM 2.0。

age identity 需要在安装构建前放到目标持久化卷：

```text
/mnt/persist/home/seeker/.config/sops/age/keys.txt
```

这里应使用 `.sops.yaml` 中 `diagonal_alley_age` 对应的专用私钥，其公钥必须是：

```text
age17wfs54f8c6a3f02gv70l0yz5p6q80cjuvpx46c89e3tz6v5dtauq9jwsfu
```

专用私钥位于 Git 忽略的 `.secrets/age/DiagonAlley.txt`。首次安装时只把它复制
到上面的目标持久化路径，不要提交到 Git，也不要用管理员 age identity 长期
替代主机专用 identity。

安装后如果需要休眠，再根据新 swapfile 计算 offset，并填写
`resumeDevice` 与 `resumeOffset`；在此之前它们保持 `null`，避免写入错误的
恢复参数。
