# Nix Config 仓库问题清单

日期：2026-04-02

这份清单基于一次静态审查，以及对仓库执行的 `nix flake show --all-systems` 和 `nix flake check --no-build`。

当前结论：

- `flake` 评估可以通过，没有立即阻断构建的错误。
- 但仓库里已经存在几类明显的安全风险、结构债和维护噪音。
- 下面的问题按优先级从高到低排列，方便后续直接按编号选择修复。

## 1. 全局 SSH 与防火墙默认值过宽

证据：

- `modules/profiles/system/core/common.nix:45` 全局启用了 `services.openssh.enable = true`
- `modules/profiles/system/core/common.nix:50` 全局启用了 `PasswordAuthentication = true`
- `modules/profiles/system/core/common.nix:52` 设置了 `openFirewall = true`
- `modules/profiles/system/core/networking.nix:15` 全局设置 `networking.firewall.enable = false`

问题：

- 所有主机默认暴露 SSH。
- 默认允许密码登录，不是 key-only。
- 同时全局关闭防火墙，扩大了暴露面。

影响：

- 这是当前仓库最直接的安全风险之一。
- 一旦任何主机联网，默认暴露面就偏大。

建议修复方向：

- 防火墙默认开启。
- SSH 改为按主机显式启用，而不是公共模块默认启用。
- 密码登录默认关闭，只在确有需要的主机上显式打开。

## 2. 用户密码哈希被硬编码进仓库

证据：

- `modules/profiles/system/hardware/users.nix:36` 提交了 `root` 的 `hashedPassword`
- `modules/profiles/system/hardware/users.nix:58` 提交了 `seeker` 的 `hashedPassword`
- `modules/profiles/system/hardware/users.nix:78` 提交了 `hagrid` 的 `hashedPassword`

问题：

- 密码相关信息直接放在版本库里。
- 密码轮换会和代码变更强耦合。
- 仓库权限即密码信息可见范围。

影响：

- 这是明确的敏感信息管理问题。
- 与默认开放的 SSH 组合在一起，风险更高。

建议修复方向：

- 删除仓库中的 `hashedPassword` 常量。
- 改成 `hashedPasswordFile`，由 `sops-nix` 下发。
- 仅在需要部署 secrets 的主机上启用这些密码 secret。

## 3. Mihomo 默认监听范围过大

证据：

- `modules/profiles/programs/mihomo/mihomo.nix:16` 设置了 `allow-lan: true`
- `modules/profiles/programs/mihomo/mihomo.nix:19` 设置 `external-controller: 0.0.0.0:9090`
- `modules/profiles/programs/mihomo/mihomo.nix:35` 设置 `listen: 0.0.0.0:53`
- `hosts/miLaptop/home.nix:25` 默认启用了 `mihomo` 和 `tun`

问题：

- 代理控制接口和 DNS 监听默认面向整个局域网。
- 在防火墙关闭的情况下，这个暴露面更危险。

影响：

- 本机代理配置被外部访问的风险增大。
- 容易把“只给本机用”的代理服务错误暴露成“局域网共享服务”。

建议修复方向：

- 默认改为仅监听 `127.0.0.1`。
- 只有在显式开启“共享到局域网”选项时，才放开监听地址和对应端口。
- 顺手检查并整理规则顺序，避免 `MATCH` 之后仍有不可达规则。

## 4. `impermanence` 模块看似通用，实际夹带主机常量

证据：

- `modules/profiles/impermanence/btrfs.nix:27` 将 `boot.resumeDevice` 写死为 `/dev/mapper/crypted`
- `modules/profiles/impermanence/btrfs.nix:28` 写死 `resume_offset=533760`
- `modules/profiles/impermanence/btrfs.nix:96` 写死 `keyFile = "/tmp/secret.key"`
- 同文件同时又定义了 `cfg.luksName` 等可配置项

问题：

- 模块名义上是通用配置，但内部仍然依赖特定主机假设。
- 主机一变，抽象就不成立。

影响：

- 复用性差。
- 容易出现“改了配置但模块里还有旧常量”的隐性错误。

建议修复方向：

- 把 `resumeDevice`、`resumeOffset`、`keyFile` 全部参数化或按需禁用。
- 明确哪些是通用能力，哪些是 `miLaptop` 私有配置。

## 5. 模块导入图依赖目录递归扫描，行为过于隐式

证据：

- `modules/default.nix:7` 递归扫描 `./profiles`
- `modules/default.nix:23` 直接 `imports = allProfiles`
- `modules/default.nix:16` 到 `modules/default.nix:19` 依赖路径字符串排除若干目录
- `modules/profiles/programs/default.nix:7` 递归扫描 `./home`
- `modules/profiles/programs/default.nix:18` 直接塞进 `home-manager.sharedModules`

问题：

- 新增一个文件就可能改变整个评估图。
- 导入边界不是显式声明，而是“目录结构 + 排除规则”的副作用。
- 已经出现必须靠路径排除才能维持结构的迹象。

影响：

- 调试困难。
- 后续重命名目录或新增文件时容易引入意外行为。

建议修复方向：

- 改成显式模块列表或按目录分层导出。
- 降低“文件落在哪个目录就自动生效”的隐式行为。

## 6. 系统层与 Home Manager 层耦合过深

证据：

- `outputs/home-configurations.nix:15` 先构造一套 `lib.nixosSystem`
- `outputs/home-configurations.nix:43` 将该系统的 `osConfig` 再传给 standalone Home Manager
- `users/seeker/config.nix:16` 在用户配置里写 `machine.home = ...`
- `modules/profiles/programs/home/vscode.nix:8` 和 `modules/profiles/programs/home/zen.nix:22` 继续扩展 `machine.home.*`

问题：

- Home Manager 配置依赖系统模块命名空间。
- Home 与 system 的边界不清晰。
- standalone home 其实通过伪 `nixosSystem` 间接依赖了系统层。

影响：

- 维护时需要同时理解两层模块系统。
- 独立复用 Home Manager 配置会比较困难。

建议修复方向：

- 收敛 `machine.home.*` 的职责。
- 明确哪些选项属于 system，哪些属于 home。
- 减少 standalone home 对伪系统上下文的依赖。

## 7. `mainUser` 抽象不完整，仍有大量 `seeker` 写死

证据：

- `modules/default.nix:39` 定义了 `machine.mainUser`
- `modules/profiles/programs/steam.nix:13` 持久化路径写死 `users.seeker`
- `modules/profiles/programs/winapps.nix:25` 持久化路径写死 `users.seeker`
- `hosts/gpu02/home.nix:8` 和 `hosts/GringottsVault713/home.nix:8` 已经表明并非所有主机都以 `seeker` 为主用户

问题：

- 抽象层已经存在，但真正使用时仍回退成硬编码用户名。

影响：

- 多用户主机、非 `seeker` 主机支持是不完整的。
- 一旦迁移到别的用户名，边角配置会漏改。

建议修复方向：

- 统一通过 `machine.mainUser` 或更明确的用户描述结构引用主用户。
- 清理系统和持久化模块里对 `users.seeker` 的硬编码。

## 8. `hosts/*` 目录存在重复样板，主机描述被拆得过碎

证据：

- `hosts/miLaptop/default.nix:3` 和 `hosts/miLaptop/options.nix:3` 都重复 `import ./home.nix`
- `hosts/devContainer/default.nix:2` 也是相同模式
- `hosts/GringottsVault713/default.nix` / `options.nix` 同类重复

问题：

- `default.nix`、`home.nix`、`options.nix` 三件套里有很多固定样板。
- `hostName`、`stateVersion`、`machine` 在多个文件之间间接传递。

影响：

- 新增主机的样板成本偏高。
- 理解单台主机最终配置时需要跨多个文件来回跳。

建议修复方向：

- 收敛主机元数据入口。
- 降低 `default/options/home` 之间的重复装配逻辑。

## 9. 死代码、旧目录和仓库卫生问题开始积累

证据：

- `users/seeker/home.nix:22` 仍然导入 `./old`
- `users/seeker/old/default.nix:1` 自己就写着 `TODO: remove them!`
- `users/nix-on-droid/nod.nix:9` 到 `users/nix-on-droid/nod.nix:11` 仍然引用不存在的 `../../modules/programs`、`../../modules/shell`、`../../modules/gui`
- 仓库里还有 `modules/profiles/de/waybar/config.jsonc.bak`
- `flake.nix:28` 定义了 `home-manager-2405`，仓库搜索里未发现消费者

问题：

- 旧配置、备份文件、疑似废弃输入仍留在主分支结构里。
- 部分路径已经不对应当前目录结构。

影响：

- 提高阅读噪音。
- 让“哪些东西还在用”变得不清楚。

建议修复方向：

- 删除不再使用的旧目录和备份文件。
- 清理无效路径引用。
- 重新核对 flake inputs，移除未使用项。

## 10. Home Manager 已出现兼容性警告，配置依赖旧默认值

证据：

- `nix flake check --no-build` 输出了 `gtk.gtk4.theme` 的 legacy default 警告
- 同一检查还输出了 `programs.git.signing.format` 的 legacy default 警告
- `users/seeker/home.nix:35` 和 `users/hagrid/home.nix:13` 仍使用 `home.stateVersion = "24.05"`

问题：

- 配置当前虽能评估，但已经开始依赖旧版本默认行为。

影响：

- 未来升级 Home Manager 时更容易遇到行为变化。

建议修复方向：

- 对相关选项显式赋值，消除警告。
- 逐步把依赖 legacy default 的配置收口。

## 额外观察

- 仓库根目录有未跟踪的 `.codex` 和 `VSCode_1.113.0_linux-x64.tar.gz`。
- 根目录存在 `result` 符号链接，当前已在 `.gitignore` 中忽略。
- `nix flake check --no-build` 通过，说明现在更像是“风险与结构债”问题，而不是“仓库已经不能用”。

## 建议的修复顺序

第一批：

- 1. 全局 SSH 与防火墙默认值过宽
- 2. 用户密码哈希被硬编码进仓库
- 3. Mihomo 默认监听范围过大
- 4. `impermanence` 模块通用性不足
- 7. `mainUser` 抽象不完整

第二批：

- 5. 模块导入图过于隐式
- 6. system 与 home 边界混乱
- 8. hosts 样板重复
- 9. 死代码与仓库卫生
- 10. Home Manager 兼容性警告
