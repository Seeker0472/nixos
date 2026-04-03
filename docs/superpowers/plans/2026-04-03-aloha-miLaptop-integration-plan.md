# Aloha 接入 `miLaptop` 计划

## 目标描述

将本地实现的 launcher 仓库 `/home/seeker/Develop/aloha` 接入当前 `nixos-config`，在当前测试阶段通过绝对路径 flake input 使用其现成的 `packages` 与 `homeManagerModules.default`，并且只为 `seeker@miLaptop` 启用。接入结果需要同时覆盖本仓库的两条构建链路：

- `nixosConfigurations.miLaptop`
- `homeConfigurations."seeker@miLaptop"`

同时，集成不能只停留在“包能装上”；还需要把 `Hyprland` 的实际入口接到 `aloha`，让它替换掉当前 `wofi`/`TODO` 占位的 launcher 调用位，并提供最小但真实可用的 `apps`、`commands`、`power` 三个 root 菜单。

## 验收标准

- AC-1: 根 flake 需要能以测试态绝对路径引入 `aloha`，并复用其现有导出而不是重复实现。
  - 正向测试（应当通过）：
    - `flake.nix` 新增 `aloha.url = "path:/home/seeker/Develop/aloha"`，并让 `aloha.inputs.nixpkgs.follows = "nixpkgs"`、`aloha.inputs.home-manager.follows = "home-manager"`。
    - `flake.lock` 在更新后能够记录该本地 input，后续 `nix build` 可以解析 `inputs.aloha.homeManagerModules.default` 与 `inputs.aloha.packages.<system>.default`。
  - 反向测试（应当失败）：
    - 若 `aloha` 路径写错，`nix build .#homeConfigurations."seeker@miLaptop".activationPackage` 或 `nix build .#nixosConfigurations.miLaptop.config.system.build.toplevel` 会在 flake 解析阶段失败。
    - 若错误引用了不存在的导出属性，求值阶段会报出 attribute not found，而不是静默回退到仓库内的其他实现。

- AC-2: `aloha` 的 Home Manager module 必须同时接入本仓库的 standalone Home Manager 路径与 NixOS 内嵌 Home Manager 路径。
  - 正向测试（应当通过）：
    - `outputs/home-configurations.nix` 的 `modules` 列表包含 `inputs.aloha.homeManagerModules.default`，使 `homeConfigurations."seeker@miLaptop"` 能识别 `programs.aloha.*`。
    - `users/seeker/default.nix` 的 `home-manager.users.seeker.imports` 也包含 `inputs.aloha.homeManagerModules.default`，使 `nixosConfigurations.miLaptop` 内的用户配置能识别 `programs.aloha.*`。
  - 反向测试（应当失败）：
    - 若只在其中一条链路导入 module，另一条链路在求值 `programs.aloha` 时会报 unknown option。
    - 若把 `programs.aloha` 配置写在共享模块里，但忘了在对应构建入口导入 `aloha` module，错误必须在求值时直接暴露，不能靠运行时碰运气。

- AC-3: `aloha` 只能在 `miLaptop` 上为 `seeker` 启用，其他主机与用户保持现状。
  - 正向测试（应当通过）：
    - 为 `miLaptop` 新增一个 host-specific 的 Home Manager 模块，例如 `users/seeker/miLaptop.nix`，专门承载 `programs.aloha` 与相关桌面接线。
    - `outputs/home-configurations.nix` 只为 `"seeker@miLaptop"` 引入该 host-specific 模块。
    - `users/seeker/default.nix` 只在 `config.networking.hostName == "miLaptop"` 时把该模块并入 `home-manager.users.seeker.imports`。
  - 反向测试（应当失败）：
    - 若 `devContainer`、`gpu02` 或其他主机也被无条件启用 `programs.aloha`，则不满足范围约束。
    - 若 host-specific 模块被错误并入共享路径，导致非 `miLaptop` 的 home 构建引用到 `aloha` 菜单或 Hyprland 快捷键，也视为失败。

- AC-4: `miLaptop` 上的 `programs.aloha` 配置必须复用 `aloha` 现有 schema，并生成一份最小可用但真实的 launcher 菜单。
  - 正向测试（应当通过）：
    - `apps` root 至少包含一个 `desktop` source，用于扫描 `.desktop` 应用。
    - `commands` root 至少包含静态命令项，并复用 `aloha` 已实现的 `brightness` provider，而不是在 `nixos-config` 里重复造 provider。
    - `power` root 至少包含 `poweroff`、`reboot`、`suspend`、`hibernate`、`suspend-then-hibernate` 这组 `builtin-action`，并可额外用 `exec` 项补 `hyprlock`。
    - 生成的 `~/.config/aloha/config.json` 中能看到稳定的 root 名、source 类型与 menu item 结构。
  - 反向测试（应当失败）：
    - 若静态项缺少 `id` 或 `command`，Home Manager 求值必须失败。
    - 若把 `lock` 误写成 `builtin-action`，由于 `aloha` 当前并不支持该 builtin，求值或运行时必须明确报错；正确做法应是单独的 `exec = "hyprlock"` 项。
    - 若为了图省事继续调用旧的 `wofi.sh` 作为主菜单，而不是直接声明 `programs.aloha.roots`，则不算真正完成集成。

- AC-5: `Hyprland` 必须为 `miLaptop` 提供可直接触发的 `aloha` 入口，并解决 launcher 窗口的展示形态。
  - 正向测试（应当通过）：
    - 现有 `$menu` 入口应在 `miLaptop` 上切换为 `aloha --root apps`，从而让 `SUPER+R` 直接打开应用菜单。
    - `modules/profiles/de/hyprland/conf/keybind.nix` 中当前的 `SUPER+P` 与 `SUPER+SHIFT+P` 占位项应分别接到 `aloha --root commands` 与 `aloha --root power`。
    - `AlohaLauncher` 这个 `kitty` class 需要被 `Hyprland` 规则识别并设置为适合 launcher 的浮动/居中/尺寸行为，而不是作为普通终端平铺打开。
  - 反向测试（应当失败）：
    - 若 `miLaptop` 之外的主机也被改写了 `$menu` 或新增了相同快捷键，不满足作用域限制。
    - 若保留原有 `TODO` 绑定并额外新增重复快捷键，会产生冲突，不算完成。
    - 若只接入命令但没有窗口规则，导致 `aloha` 每次以普通 `kitty` 窗口打断工作流，则集成质量不达标。

- AC-6: 集成后的仓库必须能通过本仓库现有输出进行验证，而不是只停留在“理论可行”。
  - 正向测试（应当通过）：
    - `nix build .#homeConfigurations."seeker@miLaptop".activationPackage`
    - `nix build .#nixosConfigurations.miLaptop.config.system.build.toplevel`
    - 必要时可用 `nix eval` 检查 `homeConfigurations."seeker@miLaptop".config.xdg.configFile."aloha/config.json".text` 中是否包含预期 roots。
  - 反向测试（应当失败）：
    - 若只验证其中一条输出，另一条路径仍然 broken，则不算完成。
    - 若需要手工到 `aloha` 仓库单独执行额外修补，才能让 `nixos-config` 构建成功，则说明本次接线边界没有处理干净。

## 路径边界

### 上界（最大可接受范围）

实现可以包含以下内容：

- 在根 `flake.nix` 与 `flake.lock` 中加入 `aloha` 本地 input
- 在 `outputs/home-configurations.nix` 与 `users/seeker/default.nix` 中把 `aloha` 的 Home Manager module 接入两条构建链路
- 新增 `users/seeker/miLaptop.nix`，集中定义：
  - `programs.aloha.enable = true`
  - `programs.aloha.roots`
  - 仅 `miLaptop` 生效的 `Hyprland` launcher 变量、窗口规则与必要桌面接线
- 修改 `modules/profiles/de/hyprland/conf/keybind.nix`，替换现有 `SUPER+P` / `SUPER+SHIFT+P` 占位绑定
- 使用当前 `wofi.sh` 仅作为菜单内容迁移时的参考来源，而不是运行时依赖

### 下界（最小可接受范围）

至少要做到：

- `aloha` 被正确作为 flake input 接入
- 两条构建链路都能识别 `programs.aloha`
- 只有 `miLaptop` 真正启用 `programs.aloha`
- 至少完成 `apps`、`commands`、`power` 三个 root 的声明式配置
- 至少完成 `SUPER+R`、`SUPER+P`、`SUPER+SHIFT+P` 这一组入口中的 `aloha` 替换

如果只做了“包能安装”，却没有快捷键入口、没有 host 限定、或只有一条构建链路可用，都不满足最低标准。

### 允许的选择

- 可以使用：绝对路径 flake input、`follows`、Home Manager module、host-specific 用户模块、`programs.aloha.roots`、现有 `brightness` provider、现有 `builtin-action` 电源动作、`Hyprland` `windowrule`
- 不可以使用：把 `aloha` 源码复制进 `nixos-config`、在 `nixos-config` 里重复实现 `aloha` 的 option schema、无条件对所有主机启用、把 `wofi.sh` 当成 `aloha` 的壳继续保留为主入口、伪造 `lock` 之类当前未实现的 builtin action

## 可行性提示

### 建议接线方式

基于当前代码结构，最顺的实现路径是：

1. 在根 [`flake.nix`](/home/seeker/nixos-config/flake.nix) 中加入 `aloha` input，并让其 `nixpkgs` 与 `home-manager` 跟随当前仓库
2. 更新 [`outputs/home-configurations.nix`](/home/seeker/nixos-config/outputs/home-configurations.nix)，让 standalone Home Manager 也能认识 `programs.aloha`
3. 更新 [`users/seeker/default.nix`](/home/seeker/nixos-config/users/seeker/default.nix)，让 NixOS 内嵌 Home Manager 也能认识 `programs.aloha`
4. 新增一个 `miLaptop` 专用用户模块，例如 `users/seeker/miLaptop.nix`
5. 在该模块里声明：
   - `programs.aloha.enable = true`
   - `apps` / `commands` / `power` 三个 root
   - `AlohaLauncher` 对应的 `Hyprland` 窗口规则
   - 对 `$menu` 的 host-specific 覆盖
6. 更新 [`modules/profiles/de/hyprland/conf/keybind.nix`](/home/seeker/nixos-config/modules/profiles/de/hyprland/conf/keybind.nix)，把当前 `TODO` 绑定替换为 `aloha` 命令

### 菜单内容建议

`aloha` 现有实现已经覆盖了你这次接线最需要的能力：

- `desktop` source：适合作为 `apps` 根菜单
- `static` source：适合作为 `commands` 与 `power` 的静态项
- `brightness` provider：适合替换当前 `wofi.sh` 里与亮度相关的子菜单需求
- `builtin-action`：已经支持 `poweroff`、`reboot`、`suspend`、`hibernate`、`suspend-then-hibernate`

结合你当前的桌面配置，首版建议如下：

- `apps`
  - `desktop`
- `commands`
  - `Terminal`
  - `Display Settings` -> `nwg-displays`
  - `Next Wallpaper` -> `wpaperctl next-wallpaper`
  - `Reload Hyprland` -> `hyprctl reload`
  - `Brightness` -> `provider-submenu = brightness`
- `power`
  - `Lock` -> `exec = "hyprlock"`
  - 其余电源动作走 `builtin-action`

这样做可以覆盖当前 `wofi` 脚本里最实用的部分，但不会在本次范围里强行迁移 `cliphist` 或 Waydroid / Docker 容器控制之类与 launcher 主目标耦合度较低的项。

### 相关参考

- [`/home/seeker/Develop/aloha/nix/home-manager/aloha.nix`](/home/seeker/Develop/aloha/nix/home-manager/aloha.nix)：`programs.aloha` 的 schema、wrapper 与 JSON 生成逻辑
- [`/home/seeker/Develop/aloha/examples/home-manager.nix`](/home/seeker/Develop/aloha/examples/home-manager.nix)：root/source/item 配置范式
- [`/home/seeker/Develop/aloha/src/aloha/providers/brightness.py`](/home/seeker/Develop/aloha/src/aloha/providers/brightness.py)：亮度 provider 的参数格式
- [`/home/seeker/nixos-config/modules/profiles/de/hyprland/conf/keybind.nix`](/home/seeker/nixos-config/modules/profiles/de/hyprland/conf/keybind.nix)：当前 `SUPER+P` 占位绑定
- [`/home/seeker/nixos-config/modules/profiles/de/wofi/wofi.sh`](/home/seeker/nixos-config/modules/profiles/de/wofi/wofi.sh)：可迁移的旧菜单语义来源

## 依赖与顺序

### 里程碑

1. 里程碑 1：把 `aloha` 作为测试态本地 input 接进仓库
   - 阶段 A：修改 `flake.nix`
   - 阶段 B：更新 `flake.lock`
   - 阶段 C：确认 `inputs.aloha.homeManagerModules.default` 可被两条构建链路引用

2. 里程碑 2：打通 `programs.aloha` 的模块可见性
   - 阶段 A：修改 `outputs/home-configurations.nix`
   - 阶段 B：修改 `users/seeker/default.nix`
   - 阶段 C：让 `programs.aloha` 在 standalone 与 NixOS 两种路径下都能求值

3. 里程碑 3：落 `miLaptop` 专用配置
   - 阶段 A：新增 `users/seeker/miLaptop.nix`
   - 阶段 B：声明 `apps` / `commands` / `power`
   - 阶段 C：补 `Hyprland` 变量与 launcher 窗口规则

4. 里程碑 4：替换桌面入口并验证
   - 阶段 A：修改 `modules/profiles/de/hyprland/conf/keybind.nix`
   - 阶段 B：构建 `homeConfigurations."seeker@miLaptop"`
   - 阶段 C：构建 `nixosConfigurations.miLaptop`

### 依赖关系

- `miLaptop` 专用配置依赖 `aloha` module 先被两条构建路径识别
- `Hyprland` 快捷键替换依赖 `programs.aloha.roots` 已经声明完成
- 窗口规则应与 `aloha` 的 `kitty.class = "AlohaLauncher"` 保持一致，避免规则与运行时 class 脱节

## 任务拆分

| 任务 ID | 描述 | 对应 AC | 标签 | 依赖 |
|---------|------|---------|------|------|
| task1 | 在根 flake 中加入 `aloha` 绝对路径 input，并更新 lock | AC-1 | coding | - |
| task2 | 把 `inputs.aloha.homeManagerModules.default` 接入 standalone Home Manager 输出 | AC-2 | coding | task1 |
| task3 | 把 `inputs.aloha.homeManagerModules.default` 接入 NixOS 内嵌 Home Manager 路径 | AC-2 | coding | task1 |
| task4 | 新增 `users/seeker/miLaptop.nix`，声明 `programs.aloha` 与 root menus | AC-3, AC-4 | coding | task2, task3 |
| task5 | 为 `AlohaLauncher` 增加 `Hyprland` 变量覆盖与窗口规则 | AC-5 | coding | task4 |
| task6 | 替换 `SUPER+P` / `SUPER+SHIFT+P` 占位绑定，接上 `aloha` 命令 | AC-5 | coding | task4 |
| task7 | 运行 `nix build` / `nix eval` 验证两条输出与生成配置 | AC-6 | coding | task4, task5, task6 |

## 已确认的实现假设

- 2026-04-03 已确认：当前阶段允许直接使用绝对路径 `path:/home/seeker/Develop/aloha`
- 本次目标是 `miLaptop` 测试接入，不要求同时兼顾其他设备上的 `aloha` 来源可用性
- 后续当 `aloha` 推到 GitHub 后，再把 flake input 切换为远程地址即可；这属于后续迁移，不阻塞当前计划

## 实现注意事项

- 实际代码与注释里不要写入 `AC-`、里程碑、阶段之类计划术语
- 不要在 `nixos-config` 里重写 `aloha` 的 Home Manager schema；直接复用上游 module
- `cliphist` 绑定不属于这次 launcher 集成最低范围，可以保持现状或在后续单独设计
- 若后续要让其他设备复用，优先改 flake input 来源，不要继续扩散绝对路径硬编码
