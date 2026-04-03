# `nixos-config` 结构治理与 Option 统一计划

## Goal Description

对当前 `nixos-config` 做一次覆盖全仓库的结构治理，而不是继续按单点需求修补。治理目标是：

- 统一 standalone Home Manager 与 NixOS 内嵌 Home Manager 两条装配链路
- 为 `aloha`、`codex`、`claude`、`gemini-cli` 以及当前仍“导入即生效”的 home 能力建立清晰的本仓库 option 层
- 把共享模块中的 hostname 分支迁移为 host 声明的 feature option
- 统一 `impermanence` 的状态来源，并把 persistence 归还给各自功能模块
- 把 `machine.users` 从固定两名用户的硬编码模型提升为可扩展 submodule
- 把 `users/seeker/tools.nix` 的大包清单拆成可组合的 bundle
- 在完成治理后保持现有 flake 输出接口稳定，并确保当前主机/用户构建链路仍可验证

本次计划的重点是“结构抽象与边界收敛”，不是重写所有业务配置细节。功能行为应尽量保持当前语义，只调整其组织方式与控制入口。

## Acceptance Criteria

Following TDD philosophy, each criterion includes positive and negative tests for deterministic verification.

- AC-1: Home Manager 装配链路必须收敛为单一共享来源，避免外部模块导入列表在多处漂移。
  - Positive Tests (expected to PASS):
    - 仓库中存在一个共享的 Home Manager 装配层，用来统一管理 `sops-nix`、`zen-browser`、`nixvim`、`aloha`、`impermanence` 等外部模块导入。
    - [`outputs/home-configurations.nix`](/home/seeker/nixos-config/outputs/home-configurations.nix)、[`users/seeker/default.nix`](/home/seeker/nixos-config/users/seeker/default.nix)、[`users/seeker/headless.nix`](/home/seeker/nixos-config/users/seeker/headless.nix) 不再各自维护一份容易漂移的外部模块列表。
    - `nix build .#homeConfigurations."seeker@miLaptop".activationPackage` 与 `nix build .#nixosConfigurations.miLaptop.config.system.build.toplevel` 仍能识别同一组 Home Manager option。
  - Negative Tests (expected to FAIL):
    - 如果故意从共享装配层删除 `inputs.aloha.homeManagerModules.default`，依赖 `programs.aloha` 的求值必须在两条链路上都直接失败，而不是只有一边失败。
    - 如果实现后仍然保留两份及以上重复的外部模块导入列表，并且修改其中一份不会自动影响另一份，则视为未满足该 criterion。

- AC-2: 仓库必须为 AI / launcher / CLI 工具提供统一且显式的本地 option 命名空间，而不是继续依赖导入副作用。
  - Positive Tests (expected to PASS):
    - 仓库新增一致的 Home Manager option 命名空间，例如 `homeProfiles.ai.*`、`homeProfiles.launchers.*`、`homeProfiles.cli.*`、`homeProfiles.terminals.*`，或等价且同样一致的结构。
    - `aloha`、`codex`、`claude`、`gemini-cli` 至少都能通过本仓库自己的 option 开关启用/关闭，而不是通过“模块被导入所以生效”。
    - `fish`、`tmux`、`yazi`、`kitty`、`direnv` 这类当前混合了配置与启用职责的模块，被整理为“上游 leaf option + 本仓库默认值/开关”模型，或等价的一致模型。
    - 共享模块中不再出现“生成 secrets/template，但实际程序 hardcode 为 disabled”这种分裂控制方式，例如当前 [`modules/profiles/programs/home/claude/default.nix`](/home/seeker/nixos-config/modules/profiles/programs/home/claude/default.nix) 的状态被收敛。
  - Negative Tests (expected to FAIL):
    - 如果 `modules/profiles/programs/home/geminicli/default.nix` 仍然在导入后无条件 `enable = true`，则失败。
    - 如果 `codex` 仍然只通过 [`modules/profiles/impermanence/home.nix`](/home/seeker/nixos-config/modules/profiles/impermanence/home.nix) 的 `home.packages` 间接出现，而没有归属到自己的模块或 option，则失败。
    - 如果 `aloha` 仍然只能通过 host-specific 模块里的裸 `programs.aloha.*` 配置出现，而不是通过本仓库自己的 feature 开关进入，则失败。

- AC-3: 共享模块中的 hostname 分支必须迁移为 host 声明的 feature option 或 host metadata，而不是在共享逻辑里硬编码主机名。
  - Positive Tests (expected to PASS):
    - [`modules/profiles/de/hyprland/conf/keybind.nix`](/home/seeker/nixos-config/modules/profiles/de/hyprland/conf/keybind.nix) 与相关共享模块不再依赖 `osConfig.networking.hostName == "miLaptop"` 这样的判断来决定 launcher 与 lid-switch 行为。
    - `miLaptop` 的 `aloha` 快捷键、power 菜单、lid switch 规则由 host 或 host-specific user module 显式声明的 option 驱动。
    - 如果未来把 `miLaptop` 改名，但保留相同 feature option，功能语义仍然稳定。
  - Negative Tests (expected to FAIL):
    - 如果改造后共享模块仍然通过字符串比较 hostName 来决定 `aloha --root commands`、`aloha --root power` 或 lid-switch 绑定，则失败。
    - 如果仅仅把 hostname 判断挪到另一个共享模块，而不是改成 feature declaration，也视为失败。

- AC-4: `impermanence` 必须只有一套清晰的状态来源，并且 persistence 的所有权要回到各自功能模块。
  - Positive Tests (expected to PASS):
    - 仓库内只保留一套“是否启用 impermanence”的权威来源；`machine.impermanence.enable` 与 `machine.btrfs.impermanence.enable` 不再以并行且容易漂移的形式同时作为行为开关。
    - `codex`、`vscode`、`gemini`、`steam`、`winapps`、`tailscale` 等持久化目录由其所属模块声明，而不是集中塞进无关的大杂烩 persistence 模块。
    - 对启用与不启用 impermanence 的主机，相关模块都能在求值阶段正确处理 `persistdir` 与 conditional persistence。
  - Negative Tests (expected to FAIL):
    - 如果 [`hosts/miLaptop/home.nix`](/home/seeker/nixos-config/hosts/miLaptop/home.nix) 仍设置一套 flag，而 [`hosts/miLaptop/disk.nix`](/home/seeker/nixos-config/hosts/miLaptop/disk.nix) 又设置另一套并且两者没有被收敛为同一来源，则失败。
    - 如果 `codex`、`.gemini`、`.vscode` 等目录仍然堆在 [`modules/profiles/impermanence/home.nix`](/home/seeker/nixos-config/modules/profiles/impermanence/home.nix) 中，而不是迁回各自功能模块，则失败。

- AC-5: Home 层模块风格必须统一，模块边界需要清晰且无隐式启用副作用。
  - Positive Tests (expected to PASS):
    - [`modules/home/default.nix`](/home/seeker/nixos-config/modules/home/default.nix) 导入的模块在职责上是清晰的：要么定义并消费本仓库 option，要么只补充某个上游 option 的配置而不偷偷开启它。
    - `users/seeker/config.nix` 或新的 option defaults 模块成为默认启用策略的主要承载点，而不是让每个 leaf module 自己决定 `enable = true`。
    - `kitty`、`fish`、`tmux`、`yazi` 等模块中，`enable` 与 `settings` 的职责分离，避免“导入模块时顺手改多个程序/桌面行为”的情况继续扩散。
  - Negative Tests (expected to FAIL):
    - 如果改造后仍然广泛存在“模块被导入就直接把上游程序打开”的模式，例如 `programs.gemini-cli.enable = true` 或 `programs.tmux.enable = true` 依然出现在无 gate 的共享模块里，则失败。
    - 如果某个 home 模块继续同时负责程序启用、桌面快捷键覆写、persistence 声明、host 条件分支，而没有清晰边界，则失败。

- AC-6: `machine.users` 必须改造成可扩展 submodule 模型，新增用户不能再依赖复制粘贴 schema。
  - Positive Tests (expected to PASS):
    - [`modules/profiles/system/hardware/users.nix`](/home/seeker/nixos-config/modules/profiles/system/hardware/users.nix) 不再只为 `seeker` 和 `hagrid` 写死 option 结构，而是支持 `machine.users.<name>` 的通用定义。
    - 当前已有主机继续能表达“启用 seeker / 启用 hagrid / 设置 uid / 设置 groups”等需求，且行为与当前语义兼容。
    - 共享用户模块中不再要求新增用户时必须先改 schema，再改 host data。
  - Negative Tests (expected to FAIL):
    - 如果实现后仓库仍然通过 `machine.users.seeker` 与 `machine.users.hagrid` 两个专用字段表达用户，而无法自然扩展到第三个用户，则失败。
    - 如果用户密码、组、authorized keys 等共享元信息仍然强绑定在硬编码的用户分支里，导致 schema 无法复用，也视为失败。

- AC-7: `users/seeker/tools.nix` 必须拆成可组合 bundle，包分组能够按场景复用和裁剪。
  - Positive Tests (expected to PASS):
    - 当前 `home.packages` 巨型列表被拆分为多个有明确边界的 bundle，例如 `base`、`dev`、`media`、`office`、`ai`，或等价的结构。
    - `seeker.gui.enable` 继续控制 GUI 相关 bundle，但不再是唯一的粗粒度开关；需要时可以单独调节开发 / 媒体 / AI 工具集合。
    - `codex`、`gemini-cli`、`claude` 这类 AI 工具不再散落在 `tools.nix`、`impermanence`、独立 leaf module 之间，而是通过统一 bundle 与 option 控制。
  - Negative Tests (expected to FAIL):
    - 如果 `users/seeker/tools.nix` 仍然保留为唯一的大包列表入口，只是在内部加注释而没有形成可组合 bundle，则失败。
    - 如果拆分后 GUI/CLI/AI 工具仍然无法被 host-specific 配置有选择地启用或关闭，则失败。

- AC-8: 结构治理完成后，现有 flake 输出必须仍可验证，且验证矩阵要覆盖两条主要配置链路与现存目标主机。
  - Positive Tests (expected to PASS):
    - `nix build .#homeConfigurations."seeker@miLaptop".activationPackage`
    - `nix build .#homeConfigurations."seeker@devContainer".activationPackage`
    - `nix build .#homeConfigurations."seeker4721@gpu02".activationPackage`
    - `nix build .#homeConfigurations."hagrid@GringottsVault713".activationPackage`
    - `nix build .#nixosConfigurations.miLaptop.config.system.build.toplevel`
    - `nix build .#nixosConfigurations.devContainer.config.system.build.toplevel`
    - 至少补充一组结构性检查，例如 `rg` 或 `nix eval`，确认共享模块中不再保留目标范围内的 hostname 分支与重复 HM 导入列表。
  - Negative Tests (expected to FAIL):
    - 如果只验证 `miLaptop`，但 `devContainer`、`gpu02` 或 `GringottsVault713` 的求值路径被结构调整破坏，则失败。
    - 如果重构后必须手工修改 flake 输出名、host target 名或用户 target 名才能通过验证，则失败。

## Path Boundaries

Path boundaries define the acceptable range of implementation quality and choices.

### Upper Bound (Maximum Acceptable Scope)

最完整且仍然合理的实现可以包含：

- 新增一个共享的 Home Manager 装配层，把 standalone / NixOS 两条导入链路完全统一
- 为 `homeProfiles.ai`、`homeProfiles.launchers`、`homeProfiles.cli`、`homeProfiles.terminals`、现有 `homeProfiles.apps` 建立一致的 option 结构和默认值层
- 把 `aloha`、`codex`、`claude`、`gemini-cli`、`fish`、`tmux`、`yazi`、`kitty`、`direnv` 等模块全部迁到统一风格
- 把 `impermanence` 的 state source、persistdir 访问、目录所有权全部整理干净
- 把 `machine.users` 改为可扩展 submodule，并迁移现有 host data
- 把 `tools.nix` 拆成 bundle，并完成必要的 host/user 接线
- 补充必要文档或注释，帮助未来继续沿同一结构扩展

### Lower Bound (Minimum Acceptable Scope)

最低可接受实现也必须同时覆盖你已经选定的全部治理范围：

- Home Manager 重复装配链路被收敛
- AI / launcher / CLI 工具有本仓库 option 层
- 目标范围内的 hostname 分支被 feature option 取代
- `impermanence` 只剩一套权威状态来源，且关键 persistence 归位
- `machine.users` 不再是两名用户专用 schema
- `tools.nix` 不再是唯一单体包清单
- 当前 flake 输出矩阵仍能验证

如果只是把 `aloha` / `codex` 单点补成 option，但没有同步治理装配链路、impermanence、users schema、tools bundle，则不满足这次计划的最低标准。

### Allowed Choices

- Can use:
  - 新的公共 helper/module，例如放在 `outputs/common/`、`modules/profiles/`、`hosts/lib/` 下
  - `mkOption`、`mkEnableOption`、`submodule`、`attrsOf`
  - `mkIf`、`mkDefault`、`mkMerge`
  - host-specific module、user-specific module、shared defaults module
  - `hostMeta`、`osConfig`，前提是它们用于消费已声明的 feature，而不是直接做 hostname 分支
  - 在不改变现有输出 target 名称的前提下调整目录结构与导入组织
- Cannot use:
  - 继续在多处复制 Home Manager 外部模块导入列表
  - 继续依赖共享模块里的 `hostName == "..."`
  - 继续把 `codex` / `.gemini` / `.vscode` 等 persistence 堆在无关的统一大文件里
  - 为了省事重写外部仓库 `aloha` 的 schema 或把其配置逻辑复制回本仓库
  - 以大范围删除现有主机/用户输出为代价来“完成”重构
  - 顺手做与结构治理无关的大规模桌面 UI 或脚本重写

## Feasibility Hints and Suggestions

> **Note**: This section is for reference and understanding only. These are conceptual suggestions, not prescriptive requirements.

### Conceptual Approach

一个可收敛的实现路径可以分成六层：

1. 先收敛“装配层”
   - 建一个共享 HM imports/helper
   - 让 standalone 与 NixOS 内嵌路径都经过同一份装配逻辑

2. 再定义“option 层”
   - 为 AI / launcher / CLI / terminal / bundles 建立一致命名空间
   - 把默认启用策略集中放在用户默认模块里，而不是 scattered leaf module

3. 再迁移“功能模块”
   - `aloha`、`claude`、`gemini-cli`、`codex`、`fish`、`tmux`、`yazi`、`kitty` 等模块逐个迁移
   - 迁移时把 `enable` 与 `settings` 拆开

4. 然后处理“host feature 接线”
   - 把 `miLaptop` 的 launcher、lid-switch 等行为声明为 host feature
   - 共享 Hyprland 模块只读取 feature option，不再认主机名

5. 再整理“impermanence / users / bundles”
   - 统一 `impermanence` state source
   - 按所有权迁移 persistence
   - 改造 `machine.users` schema
   - 拆分 `tools.nix`

6. 最后做“验证与收尾”
   - 跑 flake 输出矩阵
   - 搜索残留 hostname 分支、残留重复 imports、残留 always-on module

### Relevant References

- [docs/reviews/2026-04-03-repo-audit-suggestions.md](/home/seeker/nixos-config/docs/reviews/2026-04-03-repo-audit-suggestions.md) - 本次正式 plan 的输入审阅结论
- [outputs/home-configurations.nix](/home/seeker/nixos-config/outputs/home-configurations.nix) - standalone Home Manager 装配链路
- [users/seeker/default.nix](/home/seeker/nixos-config/users/seeker/default.nix) - NixOS 内嵌 Home Manager 装配链路
- [users/seeker/headless.nix](/home/seeker/nixos-config/users/seeker/headless.nix) - headless 变体的内嵌 Home Manager 链路
- [modules/home/default.nix](/home/seeker/nixos-config/modules/home/default.nix) - home 层共享模块总入口
- [users/seeker/config.nix](/home/seeker/nixos-config/users/seeker/config.nix) - 当前默认启用策略入口
- [users/seeker/miLaptop.nix](/home/seeker/nixos-config/users/seeker/miLaptop.nix) - 当前 `aloha` 与 host-specific 行为集中点
- [modules/profiles/de/hyprland/conf/keybind.nix](/home/seeker/nixos-config/modules/profiles/de/hyprland/conf/keybind.nix) - 当前 hostname 分支最明显的位置
- [modules/profiles/impermanence/home.nix](/home/seeker/nixos-config/modules/profiles/impermanence/home.nix) - 当前 persistence 大杂烩入口
- [modules/profiles/system/hardware/users.nix](/home/seeker/nixos-config/modules/profiles/system/hardware/users.nix) - 当前用户 schema 硬编码位置
- [users/seeker/tools.nix](/home/seeker/nixos-config/users/seeker/tools.nix) - 当前单体包清单

## Dependencies and Sequence

### Milestones

1. 里程碑 1：收敛 Home Manager 装配链路
   - Phase A: 识别两条装配链路中的共享内容与差异
   - Phase B: 引入共享 HM 装配 helper / module list
   - Phase C: 让 standalone 与 NixOS 路径改用同一来源

2. 里程碑 2：建立统一 option 命名空间与默认值层
   - Phase A: 定义 `homeProfiles.*` 的新分区与默认值承载点
   - Phase B: 为 AI / launcher / CLI / terminal / bundles 设定一致风格
   - Phase C: 保留现有 GUI app options 的兼容语义

3. 里程碑 3：迁移功能模块并去除导入副作用
   - Phase A: 迁移 `aloha`、`claude`、`gemini-cli`、`codex`
   - Phase B: 迁移 `fish`、`tmux`、`yazi`、`kitty`、`direnv`
   - Phase C: 清理 leaf module 中的 always-on 行为

4. 里程碑 4：把 host-specific 行为改为 feature declaration
   - Phase A: 为 `miLaptop` 定义 launcher / lid-switch 等 feature option
   - Phase B: 修改共享 Hyprland 模块消费这些 feature
   - Phase C: 删除目标范围内的 hostname 分支

5. 里程碑 5：统一 impermanence、users schema 与 package bundles
   - Phase A: 收敛 impermanence state source
   - Phase B: 按模块所有权迁移 persistence 声明
   - Phase C: 改造 `machine.users`
   - Phase D: 拆分 `tools.nix` 为 bundles

6. 里程碑 6：验证与文档收尾
   - Phase A: 跑 flake 输出矩阵
   - Phase B: 搜索残留结构性坏味道
   - Phase C: 在必要位置补最小说明，固定新约定

### Dependency Notes

- Home Manager 装配层收敛后，AI / launcher / CLI modules 的统一迁移才不会在两条链路上重复做两遍
- feature option 替代 hostname 分支依赖 option 命名空间先稳定下来
- persistence 归位依赖相关功能模块先有清晰归属
- `machine.users` submodule 改造要在 host data 迁移前设计好兼容层，否则容易同时打碎多台主机
- package bundles 拆分应该晚于 option namespace 初步稳定，否则 bundle 名称与 feature 名称容易反复改

## Task Breakdown

Each task must include exactly one routing tag:
- `coding`: implemented by Claude
- `analyze`: executed via Codex (`/humanize:ask-codex`)

| Task ID | Description | Target AC | Tag (`coding`/`analyze`) | Depends On |
|---------|-------------|-----------|----------------------------|------------|
| task1 | 盘点 HM 两条装配链路的重复项与差异项，输出共享装配目标清单 | AC-1 | analyze | - |
| task2 | 引入共享 HM 装配层，并让 standalone / NixOS / headless 路径改用同一来源 | AC-1 | coding | task1 |
| task3 | 定义统一的本仓库 home option 命名空间与默认值承载点 | AC-2, AC-5, AC-7 | coding | task2 |
| task4 | 迁移 `aloha`、`codex`、`claude`、`gemini-cli` 到新的 option 层与模块边界 | AC-2, AC-5 | coding | task3 |
| task5 | 迁移 `fish`、`tmux`、`yazi`、`kitty`、`direnv` 等当前带副作用的 home 模块 | AC-2, AC-5 | coding | task3 |
| task6 | 把 `miLaptop` 的 launcher / lid-switch 等行为改为 feature declaration，并移除共享模块中的 hostname 分支 | AC-3 | coding | task3, task4 |
| task7 | 统一 `impermanence` 状态来源，并把 persistence 按所有权迁移回各模块 | AC-4 | coding | task4, task5 |
| task8 | 把 `machine.users` 改造成可扩展 submodule，并迁移当前 host data | AC-6 | coding | task3 |
| task9 | 拆分 `users/seeker/tools.nix` 为可组合 bundles，并接入新的 option defaults | AC-7 | coding | task3, task4, task5 |
| task10 | 审查重构后是否仍残留 hostname 分支、重复 HM imports、导入副作用与错误 persistence 归属 | AC-1, AC-3, AC-4, AC-5 | analyze | task2, task4, task5, task6, task7 |
| task11 | 运行 flake 输出矩阵验证并修补收尾问题 | AC-8 | coding | task6, task7, task8, task9, task10 |

## Claude-Codex Deliberation

### Agreements

- 当前仓库的核心问题是抽象边界不统一，而不是某一个模块单独写得不够优雅
- `aloha` / `codex` / `claude` / `gemini-cli` 这类能力最需要先进入统一 option 模型
- standalone 与 NixOS 内嵌 Home Manager 双链路的重复装配是后续所有治理工作的基础阻塞点
- 共享模块里的 hostname 分支需要尽快替换为 feature declaration，否则结构会继续扩散
- `impermanence`、users schema、tools bundle 都属于同一轮结构治理的一部分，不能再被当成无关枝节延后

### Resolved Disagreements

- 范围大小：最初存在“只优先修 `aloha` / `codex` 相关 option”与“直接做全仓库结构治理”两种可能路径；用户已在 2026-04-03 明确选择“全部修”，因此本计划采用全范围治理，但通过多里程碑拆分来控制收敛风险。
- 命名空间强约束程度：实现可以在具体命名上有少量选择空间，但必须呈现为单一、连贯、可扩展的 option 树，而不能继续保留混合风格。

### Convergence Status

- Final Status: `converged`

## Pending User Decisions

- 无。用户已在 2026-04-03 明确选择把审阅文档中的全部候选项纳入正式 RLCR plan。

## Implementation Notes

### Code Style Requirements

- Implementation code and comments must NOT contain plan-specific terminology such as `AC-`, `Milestone`, `Phase`, `task1`, or similar workflow markers
- These terms are for plan documentation only, not for the resulting codebase
- Use descriptive, domain-appropriate naming in code instead
- 优先保留现有 flake 输出名、host 名、user target 名，避免把结构治理变成接口破坏
- 新 helper / module 可以增加，但不要为了“整洁”而做无关的大范围目录震荡
