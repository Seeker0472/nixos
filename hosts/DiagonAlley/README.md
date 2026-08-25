# DiagonAlley 安装备注

本主机已按 `miLaptop` 的用户态和 Btrfs impermanence 结构接入，但硬件信息
来自 WSL/Windows，不能确认 Linux Live ISO 中的稳定磁盘路径。因此
`disk.nix` 中的设备值是故意的占位符：

```text
/dev/disk/by-id/REPLACE_WITH_DIAGONALLEY_TARGET_NVME
```

在 Live ISO 中确认目标盘后，只替换这个值：

```bash
lsblk -d -o NAME,PATH,SIZE,MODEL,SERIAL,TRAN
readlink -f /dev/disk/by-id/REAL_TARGET_BY_ID
```

当前 Disko 布局会清空目标盘，创建 UEFI、LUKS2、Btrfs `root`/`nix`/`persist`
和 32 GiB swapfile。确认目标盘及备份后，才能运行 Disko 的
`destroy,format,mount` 流程。

age identity 需要在安装构建前放到目标持久化卷：

```text
/mnt/persist/home/seeker/.config/sops/age/keys.txt
```

安装后如果需要休眠，再根据新 swapfile 计算 offset，并填写
`resumeDevice` 与 `resumeOffset`；在此之前它们保持 `null`，避免写入错误的
恢复参数。
