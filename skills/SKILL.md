---
name: github-project-researcher-oss
description: 纯 Prompt 驱动的 AI OpenCode 技能，用于深度研究 GitHub 项目。支持多 Runner（OpenCode/Claude/Gemini），自动完成 7 步研究流程并生成文档。
---

# github-project-researcher-oss 项目技能文档

## 项目概览

| 属性 | 值 |
|------|-----|
| **项目名称** | github-project-researcher |
| **项目类型** | OpenCode AI 技能（Prompt-only） |
| **主要语言** | Bash (research.sh ~787 行) + Markdown (SKILL.md/SKILL_FULL.md) |
| **许可证** | MIT |
| **GitHub** | [includewudi/github-project-researcher-oss](https://github.com/includewudi/github-project-researcher-oss) |
| **核心功能** | 自动研究 GitHub 项目的架构、安全、适配度、竞品，生成研究文档 |
| **依赖** | bash 4.0+, python3, curl; 可选: gh CLI, jq, shellcheck |

## 核心能力

| 能力 | 说明 | 对应步骤 |
|------|------|----------|
| 项目信息采集 | 通过 gh CLI / webfetch / curl 三级降级获取项目元数据 | Step 1 |
| 本地克隆 | 按 `{author}/{repo}` 规范组织目录结构 | Step 2 |
| 项目类型门控 | 自动区分代码项目 vs 文档项目，路由不同分析路径 | Step 3.0 |
| 代码深度分析 | 语言检测、结构分析、依赖审计、安全扫描、质量评估 | Step 3 |
| 文档深度分析 | 信息架构、构建管道、内容覆盖、写作质量评分 | Step 3.D |
| AI Agent 安全审计 | 扫描 agent 配置中的提示注入、数据外泄、权限升级 | Step 3.3.1 |
| CI/CD 安全检查 | 工作流攻击面、权限配置、Action 固定、密钥暴露 | Step 3.3.2 |
| 架构分析 | 设计模式、组件层级、扩展点识别 | Step 3.5 |
| 适配度评估 | 7 维度评分 /80（安全态势 /20 量化清单） | Step 4 |
| 生态审计 | 对 2 年以上项目的推荐/工具进行现代性检查 | Step 4.2 |
| 跨域适配评估 | 差距分析、组件复用矩阵、适配策略推荐 | Step 4.5 |
| 研究报告生成 | 输出 RESEARCH.md 到克隆目录 | Step 5 |
| 知识库维护 | 自进化知识库，含模式去重、卫生规则、知识链接 | Step 6 |
| 竞品分析 | 功能矩阵、定位图、按场景推荐替代方案 | Step 7 |
| 多 Runner 支持 | OpenCode Server / Claude Code CLI / Gemini CLI 三种执行后端 | CLI |

## 技术栈

| 组件 | 技术 |
|------|------|
| CLI 脚本 | Bash 4.0+ (strict mode: `set -euo pipefail`) |
| JSON 处理 | Python3 内联（jq 可选降级） |
| HTTP 请求 | curl (silent + fail-on-error) |
| GitHub API | gh CLI (首选) → webfetch → curl (降级链) |
| AI 执行 | OpenCode Server API / Claude Code CLI / Gemini CLI |
| 配置管理 | `.env.local` (gitignored) |

## 目录结构

```
github-project-researcher-oss/
├── research.sh              # 多 Runner CLI 入口 (~787 行)
├── .env.local.example       # 配置模板
├── .env.local               # 本地配置 (gitignored)
├── SKILL.md                 # 精简版技能定义 (~265 行，默认加载)
├── SKILL_FULL.md            # 完整参考 (~178 行，含步骤索引)
├── AGENTS.md                # AI Agent 开发指南 (~290 行)
├── README.md                # 英文文档
├── README_ZH.md             # 中文文档
├── LICENSE                  # MIT 许可证
├── .sisyphus/               # Sisyphus 计划和草稿
│   ├── plans/               # 工作计划
│   └── drafts/              # 草稿
├── agents/                  # 详细开发指南
│   ├── bash-style.md        # Bash 编码规范 (~320 行)
│   ├── skill-dev.md         # 技能开发模式 (~338 行)
│   ├── workflow.md          # 研究工作流参考 (~280 行)
│   └── steps/               # 各步骤详细文档 (13 个文件, ~1670 行)
│       ├── 01-fetch.md      # Step 1: 获取项目信息
│       ├── 02-clone.md      # Step 2: 克隆到本地
│       ├── 03-type-gate.md  # Step 3.0: 项目类型门控
│       ├── 03-analysis.md   # Step 3: 代码深度分析
│       ├── 03d-docs-analysis.md  # Step 3.D: 文档分析
│       ├── 03.3-security.md # Step 3.3: 安全分析
│       ├── 03.5-architecture.md  # Step 3.5: 架构分析
│       ├── 04-fitness.md    # Step 4: 适配度评估
│       ├── 04.2-ecosystem.md # Step 4.2: 生态审计
│       ├── 04.5-domain.md   # Step 4.5: 跨域适配
│       ├── 05-research.md   # Step 5: 生成 RESEARCH.md
│       ├── 06-kb.md         # Step 6: 更新知识库
│       └── 07-competitors.md # Step 7: 竞品分析
└── skills/
    └── SKILL.md             # 本文件

总计: ~32 个文件
```

## 子文件索引

| 文件 | 说明 |
|------|------|
| [architecture.md](./architecture.md) | 系统架构分析：CLI 设计、研究工作流引擎、技能定义结构 |
| [development.md](./development.md) | 开发指南：环境配置、CLI 使用、技能扩展、测试方法 |
