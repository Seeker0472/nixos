# 仓库结构审阅建议

分支：`repo-audit-options-plan`

这份文档只记录“建议候选”，不等同于最终 RLCR plan。你挑选范围后，再把选中的项整理成正式计划。

## 总体判断

当前仓库的主要问题不是“模块太少”，而是“抽象层次不统一”：

- `system` 层已经开始用 `machine.*` option 做抽象。
- `home` 层同时混用了三种风格：
  - 自定义 option，例如 `homeProfiles.apps.*`
  - 直接依赖上游 option，例如 `programs.kitty.enable`
  - 导入即生效，没有本仓库自己的开关，例如 `gemini-cli`、`tmux`、部分 `impermanence` 内容
- `standalone home-manager` 和 `NixOS 内嵌 home-manager` 有重复拼装逻辑，导致外部模块导入和 host-specific 行为容易漂移。
- 一部分行为仍然依赖 `hostname` 分支，而不是 feature option。

## 优先级建议

### 候选 1：统一 Home Manager 入口链路

价值：高

建议目标：

- 把 `outputs/home-configurations.nix`、`users/seeker/default.nix`、`users/seeker/headless.nix` 里的重复 Home Manager 拼装逻辑收敛到一个公共构造层。
- 把外部模块导入列表收敛到单一来源，例如统一管理：
  - `sops-nix`
  - `zen-browser`
  - `nixvim`
  - `aloha`
  - `impermanence`

证据：

- [`outputs/home-configurations.nix`](/home/seeker/nixos-config/outputs/home-configurations.nix#L47) 到 [`outputs/home-configurations.nix`](/home/seeker/nixos-config/outputs/home-configurations.nix#L58)
- [`users/seeker/default.nix`](/home/seeker/nixos-config/users/seeker/default.nix#L18) 到 [`users/seeker/default.nix`](/home/seeker/nixos-config/users/seeker/default.nix#L35)
- [`users/seeker/headless.nix`](/home/seeker/nixos-config/users/seeker/headless.nix#L10) 到 [`users/seeker/headless.nix`](/home/seeker/nixos-config/users/seeker/headless.nix#L23)

预期收益：

- 新增 `aloha` / `codex` / 其他外部模块时只改一个地方。
- standalone 与 NixOS 两条链路不会再出现“这一边能识别 option，另一边不能”的问题。

### 候选 2：给 AI / launcher / CLI 工具建立统一 option 命名空间

价值：高

建议目标：

- 给下面这些能力补一层“本仓库自己的 option”：
  - `aloha`
  - `codex`
  - `claude`
  - `gemini-cli`
  - 可能还有 `tmux` / `fish` / `yazi`
- 不要把这些能力散落在 host-specific 文件、impermanence 文件、或导入即生效的模块里。

证据：

- `aloha` 现在直接写在 [`users/seeker/miLaptop.nix`](/home/seeker/nixos-config/users/seeker/miLaptop.nix#L19) 到 [`users/seeker/miLaptop.nix`](/home/seeker/nixos-config/users/seeker/miLaptop.nix#L158)
- `codex` 现在混在 [`modules/profiles/impermanence/home.nix`](/home/seeker/nixos-config/modules/profiles/impermanence/home.nix#L15) 到 [`modules/profiles/impermanence/home.nix`](/home/seeker/nixos-config/modules/profiles/impermanence/home.nix#L39)
- `claude` 现在即使 secrets 可部署，也会生成配置模板，但 `programs.claude-code.enable` 仍然硬编码为 false：
  [`modules/profiles/programs/home/claude/default.nix`](/home/seeker/nixos-config/modules/profiles/programs/home/claude/default.nix#L16) 到 [`modules/profiles/programs/home/claude/default.nix`](/home/seeker/nixos-config/modules/profiles/programs/home/claude/default.nix#L58)
- `gemini-cli` 现在导入即启用：
  [`modules/profiles/programs/home/geminicli/default.nix`](/home/seeker/nixos-config/modules/profiles/programs/home/geminicli/default.nix#L27) 到 [`modules/profiles/programs/home/geminicli/default.nix`](/home/seeker/nixos-config/modules/profiles/programs/home/geminicli/default.nix#L38)

建议方向：

- 可以统一成例如：
  - `homeProfiles.tools.codex.enable`
  - `homeProfiles.ai.claude.enable`
  - `homeProfiles.ai.gemini.enable`
  - `homeProfiles.launcher.aloha.enable`

### 候选 3：把 hostname 分支改成 feature option

价值：高

建议目标：

- 尽量避免在共享模块里写 `osConfig.networking.hostName == "miLaptop"`。
- 让 host 文件声明能力，而共享模块只消费能力。

证据：

- [`users/seeker/default.nix`](/home/seeker/nixos-config/users/seeker/default.nix#L34)
- [`users/seeker/miLaptop.nix`](/home/seeker/nixos-config/users/seeker/miLaptop.nix#L9)
- [`modules/profiles/de/hyprland/conf/keybind.nix`](/home/seeker/nixos-config/modules/profiles/de/hyprland/conf/keybind.nix#L185) 到 [`modules/profiles/de/hyprland/conf/keybind.nix`](/home/seeker/nixos-config/modules/profiles/de/hyprland/conf/keybind.nix#L226)

建议方向：

- 例如把这些信息收敛成 option：
  - `machine.launcher.appsCommand`
  - `machine.launcher.commandsCommand`
  - `machine.launcher.powerCommand`
  - `machine.hardware.lidSwitch.enable`
  - `machine.hardware.internalDisplay`
- 或更直接一点：
  - `machine.features.aloha.enable`
  - `machine.features.lidActions.enable`

### 候选 4：统一 impermanence 模型，并把 persistence 归还给各自模块

价值：高

建议目标：

- 清理 `machine.impermanence.enable` 和 `machine.btrfs.impermanence.enable` 这两套并存的状态。
- 让 persistence 配置跟着具体功能模块走，而不是集中塞进一个“大杂烩 home persistence” 文件。

证据：

- 顶层 option：[`modules/default.nix`](/home/seeker/nixos-config/modules/default.nix#L41) 到 [`modules/default.nix`](/home/seeker/nixos-config/modules/default.nix#L68)
- host 开启的是 `machine.impermanence.enable`：
  [`hosts/miLaptop/home.nix`](/home/seeker/nixos-config/hosts/miLaptop/home.nix#L6) 到 [`hosts/miLaptop/home.nix`](/home/seeker/nixos-config/hosts/miLaptop/home.nix#L10)
- 真正的 Btrfs 配置走的是 `machine.btrfs.impermanence.*`：
  [`hosts/miLaptop/disk.nix`](/home/seeker/nixos-config/hosts/miLaptop/disk.nix#L10) 到 [`hosts/miLaptop/disk.nix`](/home/seeker/nixos-config/hosts/miLaptop/disk.nix#L20)
- `codex`、`.gemini`、`.vscode` 等 persistence 现在混在一起：
  [`modules/profiles/impermanence/home.nix`](/home/seeker/nixos-config/modules/profiles/impermanence/home.nix#L16) 到 [`modules/profiles/impermanence/home.nix`](/home/seeker/nixos-config/modules/profiles/impermanence/home.nix#L35)
- 其他模块又依赖另一套 flag：
  [`modules/profiles/programs/steam.nix`](/home/seeker/nixos-config/modules/profiles/programs/steam.nix#L10)
  [`modules/profiles/programs/winapps.nix`](/home/seeker/nixos-config/modules/profiles/programs/winapps.nix#L23)
  [`modules/profiles/programs/tailscale.nix`](/home/seeker/nixos-config/modules/profiles/programs/tailscale.nix#L17)

建议方向：

- 只保留一套“是否启用 impermanence”的来源。
- `codex` 的持久化放回 codex 模块。
- `vscode` 的持久化放回 vscode 模块。
- `steam` / `winapps` / `tailscale` 继续各自声明自己的 persistence。

### 候选 5：统一 Home 层模块风格

价值：中高

建议目标：

- 让 `modules/home/default.nix` 只导入“有明确边界”的模块。
- 每个 home 模块至少满足下面之一：
  - 提供本仓库 option，并 `mkIf`
  - 明确只是在补充某个上游 option 的实现，并且不开启它
- 避免“导入即启用”与“导入但不启用”混在一起。

证据：

- 总入口过于扁平，且直接导入很多行为不同的模块：
  [`modules/home/default.nix`](/home/seeker/nixos-config/modules/home/default.nix#L14) 到 [`modules/home/default.nix`](/home/seeker/nixos-config/modules/home/default.nix#L88)
- `kitty` 模块直接写配置并顺手改 Hyprland：
  [`modules/profiles/programs/home/kitty.nix`](/home/seeker/nixos-config/modules/profiles/programs/home/kitty.nix#L3) 到 [`modules/profiles/programs/home/kitty.nix`](/home/seeker/nixos-config/modules/profiles/programs/home/kitty.nix#L63)
- `fish` / `yazi` 也是类似模式：
  [`modules/profiles/programs/home/fish.nix`](/home/seeker/nixos-config/modules/profiles/programs/home/fish.nix#L22)
  [`modules/profiles/programs/home/yazi.nix`](/home/seeker/nixos-config/modules/profiles/programs/home/yazi.nix#L3)

建议方向：

- 要么统一走 `homeProfiles.*`
- 要么统一做成“配置模块只补充上游 option，不负责 enable”
- 不建议继续三种风格混用

### 候选 6：把用户模型从“固定两个用户名”提升为可扩展子模块

价值：中

建议目标：

- 现在 `machine.users` 只对 `seeker` 和 `hagrid` 写死了 schema。
- 如果后续再加用户，会继续复制粘贴。

证据：

- [`modules/profiles/system/hardware/users.nix`](/home/seeker/nixos-config/modules/profiles/system/hardware/users.nix#L6) 到 [`modules/profiles/system/hardware/users.nix`](/home/seeker/nixos-config/modules/profiles/system/hardware/users.nix#L84)

建议方向：

- 可以改成 attrset/submodule 风格，例如 `machine.users.<name> = { enable; uid; extraGroups; ...; }`
- 密码、SSH key 等敏感信息不要继续硬编码在主模块里

### 候选 7：把包清单拆成 bundle，而不是一个超大 `tools.nix`

价值：中

建议目标：

- `users/seeker/tools.nix` 现在是一个大列表，横跨基础 CLI、开发工具、GUI 软件、媒体工具、文档工具。
- 这种写法短期快，长期难以做按场景裁剪。

证据：

- [`users/seeker/tools.nix`](/home/seeker/nixos-config/users/seeker/tools.nix#L8) 到 [`users/seeker/tools.nix`](/home/seeker/nixos-config/users/seeker/tools.nix#L134)

建议方向：

- 拆成 bundle，例如：
  - `seeker.packages.base`
  - `seeker.packages.dev`
  - `seeker.packages.media`
  - `seeker.packages.office`
  - `seeker.packages.ai`

## 我建议优先进入 RLCR 的组合

如果你希望这次 plan 解决“结构性问题”而不是只修单点，我建议优先从下面 3 组里选：

1. 组合 A：`候选 1 + 候选 2 + 候选 3`
   这一组会解决 `aloha`/`codex`/`claude`/`gemini` 这类功能应该如何被建模的问题。

2. 组合 B：`候选 2 + 候选 4 + 候选 5`
   这一组会把 home 层 option 风格和 impermanence 的职责边界一起理顺。

3. 组合 C：`候选 1 + 候选 4 + 候选 6`
   这一组偏基础设施，会让后续继续扩仓库时成本更低。

## 不建议现在就塞进同一个 plan 的内容

- 大规模重写 Hyprland 细节配置
- 全面替换现有应用清单
- 一次性重写所有 shell 脚本
- 先动外部仓库 `aloha` 的 schema，再回来改本仓库

这些范围容易把“结构治理”计划变成“所有东西都想顺手改”，不利于 RLCR 收敛。
