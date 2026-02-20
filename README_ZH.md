# github-project-researcher

[English](README.md) | **中文**

纯 Prompt 驱动的 [OpenCode](https://github.com/anomalyco/opencode) 技能，用于深度研究 GitHub 项目。

## 功能

- 分析 GitHub 项目的能力、架构和设计模式
- 发现安全漏洞和代码质量问题
- 评估项目对特定需求的适配度（包括跨领域适用性）
- 对比竞品和替代方案
- 按规范目录结构克隆项目
- 生成全面的研究文档（RESEARCH.md）
- 构建自进化知识库（KNOWLEDGE_BASE.md）

## 安装

```bash
# 克隆仓库
git clone https://github.com/includewudi/github-project-researcher-oss.git

# 软链接到 OpenCode 技能目录
mkdir -p ~/.config/opencode/skills/github-project-researcher
ln -s "$(pwd)/SKILL.md" ~/.config/opencode/skills/github-project-researcher/SKILL.md
```

## 配置

所有路径均可通过环境变量配置：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `GITHUB_RESEARCHER_CLONE_DIR` | `~/.github-researcher/projects` | 研究项目的克隆目录 |
| `GITHUB_RESEARCHER_LOG_DIR` | `~/.github-researcher/logs` | 会话日志保存目录 |

```bash
# 示例：自定义克隆和日志目录
export GITHUB_RESEARCHER_CLONE_DIR="$HOME/research/projects"
export GITHUB_RESEARCHER_LOG_DIR="$HOME/research/logs"
```

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
```

## 依赖

- [OpenCode](https://github.com/anomalyco/opencode) 并启用 server 模式（`opencode serve`）
- `bash` 4.0+
- `curl`
- `python3`
- `gh` CLI（可选，用于获取更丰富的 GitHub 数据）

## 工作流程

| 步骤 | 名称 | 说明 |
|------|------|------|
| 1 | 获取项目信息 | 通过 gh CLI 拉取元数据、README、目录结构 |
| 2 | 克隆到本地 | 按 `{author}/{repo}` 规范组织 |
| 3 | 深度分析 | 代码、依赖、安全性、质量评估 |
| 3.5 | 架构分析 | 设计模式、层级结构、扩展点 |
| 4 | 适配度评估 | 按用户需求进行评分 |
| 4.5 | 跨领域适配 | 跨领域适用性评估 |
| 5 | 生成 RESEARCH.md | 输出完整研究报告 |
| 6 | 更新知识库 | 积累研究成果 |
| 7 | 竞品分析 | 替代方案对比矩阵 |

## 项目结构

```
github-project-researcher/
├── research.sh          # OpenCode server 的 CLI 封装
├── SKILL.md             # 精简版技能定义（默认加载）
├── SKILL_FULL.md        # 完整参考，含详细命令和模板
├── AGENTS.md            # AI agent 开发指南
├── README.md            # 英文文档
├── README_ZH.md         # 本文件
├── LICENSE              # MIT 许可证
└── agents/              # 详细指南
    ├── bash-style.md    # Bash 编码规范
    ├── skill-dev.md     # 技能开发模式
    └── workflow.md      # 研究工作流参考
```

## 许可证

MIT
