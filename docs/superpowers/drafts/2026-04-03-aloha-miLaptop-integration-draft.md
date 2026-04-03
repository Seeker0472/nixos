# Aloha 接入 `nixos-config` 草稿

## 背景

- 本地已有一个自实现的 app launcher 仓库：`/home/seeker/Develop/aloha`
- `aloha` 已经是一个可独立构建的 flake，并导出了：
  - `packages.<system>.default`
  - `homeManagerModules.default`
- 当前 `nixos-config` 中，`miLaptop` 使用 Hyprland，且 `SUPER+P` 一组快捷键仍是占位 `TODO`

## 目标

- 仔细阅读 `aloha` 的 flake、Home Manager module、运行时入口和 provider 代码，确认真实集成方式
- 将 `aloha` 作为本地 flake input 接入当前 `nixos-config`
- 当前测试阶段允许直接使用绝对路径 `path:/home/seeker/Develop/aloha`
- 只在 `miLaptop` 上为 `seeker` 启用 `programs.aloha`
- 为 `miLaptop` 提供最小可用的 launcher 菜单配置，至少覆盖：
  - 应用菜单
  - 命令菜单
  - 电源菜单
- 把 Hyprland 中当前占位的 `SUPER+P` 相关快捷键替换为 `aloha` 的实际调用入口
- 保持其他主机和用户配置行为不变

## 约束

- 优先复用 `aloha` 仓库现有的 Home Manager module，不在 `nixos-config` 中重复实现一套 option schema
- 尽量通过 flake input 和 host/user 条件化配置完成接线，而不是写死在所有主机共享模块中
- 若需要 host 条件判断，应明确限定在 `miLaptop`
- 菜单内容需要结合当前桌面环境与已有快捷键意图，避免无意义地平移旧 `wofi` 脚本
- 验证方式至少覆盖 `nix eval` 或 `nix build` 级别的配置可求值/可构建性

## 非目标

- 这次不要求把 `aloha` 发布到远程仓库或公共 flake registry
- 后续迁移到 GitHub 后，可以再把 flake input 从绝对路径切换为远程来源
- 这次不要求在 `devContainer`、`gpu02` 或其他机器上启用 `aloha`
- 这次不要求一次性迁移所有旧 `wofi` 脚本能力
- 这次不要求修改 `aloha` 仓库的核心架构，除非在计划里作为单独前置依赖明确指出
