# FreeKill 自制扩展

基于 FreeKill（新月杀）制作的个人卡牌游戏扩展项目。

这个仓库用于统一维护和展示我的 FreeKill 自制扩展，并同步到 GitHub 与 Gitee。两个平台保持相同的源码与文档；Gitee 主要作为国内访问镜像。

目前包含两个相互独立、在 FreeKill `packages/` 目录下平级使用的扩展：

- `fanmoushuo`：主要扩展，包含已经实际制作和测试的武将、卡牌与游戏模式
- `zhxs`：第二个扩展，目前仍在开发中（WIP）

## fanmoushuo

`fanmoushuo` 是目前主要完成并持续迭代的扩展。

当前项目包含 80+ 个 Lua 脚本文件，内容覆盖：

- 自制武将与武将技能
- 自制卡牌、装备与对应技能
- 规则技能
- 多种自定义游戏模式
- 图片、音频等扩展资源

项目从角色或玩法想法出发，将机制拆解为实际可运行的技能和规则，并在游戏内持续测试和调整。

## zhxs

**状态：WIP / 开发中**

`zhxs` 是正在制作的第二个独立扩展，目前已经实现部分角色与技能机制，但尚未作为完整扩展发布。

仓库保留当前开发内容，用于记录和展示持续迭代过程；不将其描述为已经完成或完整验证的扩展。

## 开发方式

项目的基本制作流程：

1. 确定角色、技能或玩法机制
2. 将设计拆解为触发条件、效果、状态与规则
3. 使用 Lua 在 FreeKill 扩展框架中实现
4. 在游戏中加载并测试
5. 根据实际表现、报错和规则冲突继续修改
6. 逐步扩展到卡牌和自定义游戏模式

开发过程中使用 AI 辅助代码实现、问题定位和方案探索。我主要负责玩法与机制设计、需求拆解、上下文提供、游戏内测试以及最终方案判断。

## Repository Structure

```text
FreeKill-Custom-Extensions/
├── fanmoushuo/
│   ├── audio/
│   ├── image/
│   ├── pkg/
│   ├── init.lua
│   └── ofl_util.lua
├── zhxs/
│   ├── image/
│   ├── pkg/
│   └── init.lua
├── README.md
└── .gitignore
```

两个扩展在实际 FreeKill 环境的 `packages/` 目录中均作为独立、平级扩展使用。本仓库将它们集中维护，方便版本管理、双平台同步与作品展示。

## Demo

Bilibili：

《关于我把我的舍敌做进三国杀的那些事》

https://www.bilibili.com/video/BV1V7h26KEzF/

## Mirrors

本项目同时维护于 GitHub 与 Gitee，两边保持相同内容。

- GitHub：公开仓库
- Gitee：国内访问镜像

## Status

个人游戏机制设计与实现项目。

`fanmoushuo` 为目前主要展示内容；`zhxs` 仍处于 WIP 状态。
