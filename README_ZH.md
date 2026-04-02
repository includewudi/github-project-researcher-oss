# github-project-researcher

[English](README.md) | **中文**

纯 Prompt 驱动的 AI [OpenCode](https://github.com/anomalyco/opencode) 技能，用于深度研究 GitHub 项目。支持多 Runner 执行（OpenCode / Claude Code / Gemini CLI）。

## 功能

- 分析 GitHub 项目的能力、架构和设计模式
- 发现安全漏洞和代码质量问题
- 评估项目对特定需求的适配度（包括跨领域适用性）
- 对比竞品和替代方案
- 按规范目录结构克隆项目
- 生成全面的研究文档（RESEARCH.md）
- 构建自进化知识库（KNOWLEDGE_BASE.md）
- **模块化步骤系统** — 每个研究阶段独立文档，易于扩展
- **可选慢雾集成** — 可升级至 [SlowMist Agent Security](https://github.com/slowmist/slowmist-agent-security) 进行 Web3/区块链/Agent 安全深度审查

## 安装

```bash
# 克隆仓库
git clone https://github.com/includewudi/github-project-researcher-oss.git
cd github-project-researcher-oss

# 软链接到 OpenCode 技能目录
mkdir -p ~/.config/opencode/skills/github-project-researcher
ln -s "$(pwd)/SKILL.md" ~/.config/opencode/skills/github-project-researcher/SKILL.md
```

### 可选：慢雾安全技能

用于 Web3/区块链/Agent 项目的深度安全分析：

```bash
git clone https://github.com/slowmist/slowmist-agent-security.git \
  ~/.config/opencode/skills/slowmist-agent-security
```

## 配置

复制 `.env.local.example` 为 `.env.local` 并自定义：

```bash
cp .env.local.example .env.local
```

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `CLONE_DIR` | `~/.github-researcher/projects` | 研究项目的克隆目录 |
| `LOG_DIR` | `~/.github-researcher/logs` | 会话日志保存目录 |
| `PORT` | `13456` | OpenCode 服务端口 |
| `HOST` | `127.0.0.1` | OpenCode 服务地址 |
| `AGENT` | `sisyphus` | 使用的 Agent |
| `MODEL` | _（默认）_ | 模型覆盖（`provider/model`） |
| `TIMEOUT` | `3600` | 超时时间（秒） |

`.env.local` 已加入 gitignore，可安全存放私有路径。

## 使用方法

```
"Research https://github.com/facebook/react"
"分析 langchain 是否适合我的 RAG 需求"
"查找 fastapi 项目中的漏洞"
"freqtrade 做量化交易有哪些替代品？"
```

### 命令行

```bash
# 快速研究（异步模式 + 日志 + 实时输出）
./research.sh https://github.com/owner/repo --async --log --verbose

# 试运行（仅健康检查）
./research.sh https://github.com/owner/repo --dry-run

# 自定义 agent/模型
./research.sh https://github.com/owner/repo --agent build --model "provider/model"

# 使用 Claude Code CLI（无需服务器）
./research.sh https://github.com/owner/repo --runner claude

# 使用 Gemini CLI（无需服务器）
./research.sh https://github.com/owner/repo --runner gemini
```

完整选项见 `./research.sh --help`。

## 依赖

**基础依赖：**
- `bash` 4.0+
- `python3`
- `gh` CLI（可选，用于获取更丰富的 GitHub 数据）

**Runner 依赖：**

| Runner | 依赖 |
|--------|------|
| `opencode`（默认） | [OpenCode](https://github.com/anomalyco/opencode) 服务器（`opencode serve`）+ `curl` |
| `claude` | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI + `ANTHROPIC_API_KEY` |
| `gemini` | [Gemini CLI](https://github.com/google-gemini/gemini-cli) + `GEMINI_API_KEY` |

## 工作流程

| 步骤 | 名称 | 说明 |
|------|------|------|
| 1 | 获取项目信息 | 通过 gh CLI 拉取元数据、README、目录结构 |
| 2 | 克隆到本地 | 按 `{author}/{repo}` 规范组织 |
| 3 | 深度分析 | 代码质量、依赖、语言/类型检测 |
| 3-security | 安全审计 | 4 维评分（/20），可选慢雾升级 |
| 3-architecture | 架构分析 | 设计模式、层级结构、扩展点 |
| 3-docs | 文档审查 | README 质量、API 文档、示例 |
| 4 | 适配度评估 | 按用户需求进行评分 |
| 4.5 | 跨领域适配 | 跨领域适用性评估 |
| 5 | 生成 RESEARCH.md | 输出完整研究报告 |
| 6 | 更新知识库 | 积累研究成果 |
| 7 | 竞品分析 | 替代方案对比矩阵 |

## 安全模块

内置 4 维安全评分（/20）：

| 维度 | 覆盖范围 |
|------|----------|
| 供应链安全 | 依赖、安装脚本、锁文件 |
| 代码安全 | 注入、密钥泄露、认证、加密 |
| 基础设施 | CI/CD、权限、固定版本 Actions |
| AI Agent 安全 | Skill/MCP 信任、数据外泄、提示注入 |

**慢雾升级** 在以下情况自动触发：
- 检测到 Web3 / 区块链 / DeFi 项目
- Agent/MCP/Skill 存在 🔴 发现
- 初始评分 ≤ 10/20
- 用户明确要求更严格审查

## 项目结构

```
github-project-researcher/
├── research.sh              # 多 Runner 研究 CLI
├── SKILL.md                 # 精简版技能定义（默认加载）
├── SKILL_FULL.md            # 完整参考，含详细命令和模板
├── AGENTS.md                # AI agent 开发指南
├── .env.local.example       # 配置模板（复制为 .env.local）
├── steps/                   # 模块化研究步骤
│   ├── 01-fetch.md          #   步骤 1: 获取项目信息
│   ├── 02-clone.md          #   步骤 2: 克隆到本地
│   ├── 03-type-gate.md      #   步骤 3: 语言/类型检测
│   ├── 03-analysis.md       #   步骤 3: 代码质量分析
│   ├── 03-security.md       #   步骤 3: 安全审计 + 慢雾
│   ├── 03-architecture.md   #   步骤 3.5: 架构分析
│   ├── 03d-docs.md          #   步骤 3.D: 文档审查
│   ├── 04-fitness.md        #   步骤 4: 适配度评估
│   ├── 05-report.md         #   步骤 5: 生成 RESEARCH.md
│   ├── 06-kb.md             #   步骤 6: 更新知识库
│   └── 07-competitors.md    #   步骤 7: 竞品分析
├── templates/               # 报告模板
│   ├── research-deep.md     #   完整研究报告
│   ├── research-quick.md    #   快速评估
│   ├── research-security.md #   安全专项报告
│   └── kb-entry.md          #   知识库条目
├── agents/                  # 开发指南
│   ├── bash-style.md        #   Bash 编码规范
│   ├── skill-dev.md         #   技能开发模式
│   └── workflow.md          #   研究工作流参考
├── skills/                  # 子技能定义
│   ├── SKILL.md             #   OSS 技能变体
│   ├── architecture.md      #   架构分析
│   └── development.md       #   开发模式
├── docs/                    # 项目文档
│   └── evolution-plan.md    #   路线图和演进计划
├── README.md                # 英文文档
├── README_ZH.md             # 本文件
└── LICENSE                  # MIT 许可证
```

## 许可证

MIT
