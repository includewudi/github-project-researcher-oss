# 开发指南

## 环境配置

### 安装步骤

```bash
# 1. 克隆仓库
git clone https://github.com/includewudi/github-project-researcher-oss.git
cd github-project-researcher-oss

# 2. 符号链接 SKILL.md 到 OpenCode 技能目录
mkdir -p ~/.config/opencode/skills/github-project-researcher
ln -s "$(pwd)/SKILL.md" ~/.config/opencode/skills/github-project-researcher/SKILL.md

# 3. 复制配置模板
cp .env.local.example .env.local
# 编辑 .env.local 配置本地路径和端口
```

### 依赖要求

| 工具 | 版本 | 必需 | 用途 |
|------|------|------|------|
| bash | 4.0+ | ✅ | CLI 脚本执行 |
| python3 | 3.x | ✅ | JSON 处理（替代 jq） |
| curl | - | ✅ | HTTP 请求 |
| gh CLI | - | ❌ 可选 | 更丰富的 GitHub 元数据 |
| jq | - | ❌ 可选 | JSON 处理（有 python3 降级） |
| shellcheck | - | ❌ 可选 | Bash 代码检查 |

## CLI 使用

### 基本语法

```bash
./research.sh <github_url> [options]
```

### 推荐用法

```bash
# 默认推荐：异步 + 日志 + 实时消息
./research.sh https://github.com/owner/repo --async --log --verbose
```

### 完整选项列表

| 选项 | 默认值 | 适用 Runner | 说明 |
|------|--------|------------|------|
| `--runner RUNNER` | opencode | 全部 | 执行后端：opencode / claude / gemini |
| `--async` | false | opencode | 异步模式：提交后轮询结果 |
| `--log` | false | opencode | 保存会话日志到日志目录 |
| `--log-dir DIR` | `~/.github-researcher/logs` | opencode | 自定义日志目录 |
| `--verbose` | false | opencode | 异步模式下显示实时消息 |
| `--agent AGENT` | sisyphus | opencode | 使用的 Agent 名称 |
| `--model MODEL` | 默认模型 | 全部 | 模型覆盖（格式: `provider/model`） |
| `--port PORT` | 13456 | opencode | OpenCode 服务端口 |
| `--timeout SECS` | 3600 | 全部 | 超时时间（秒） |
| `--dry-run` | false | 全部 | 仅执行预检，不启动研究 |
| `--help` | - | 全部 | 显示帮助信息 |

### Runner 选择

| Runner | 前提条件 | 特点 |
|--------|---------|------|
| opencode（默认） | OpenCode Server 运行 + curl | 支持异步、日志、实时消息、session 管理 |
| claude | Claude Code CLI + ANTHROPIC_API_KEY | 无需服务器，直接 CLI 调用（print mode） |
| gemini | Gemini CLI + GEMINI_API_KEY | 无需服务器，管道输入 CLI |

## 配置参考

通过 `.env.local` 文件配置（gitignored）：

| 变量 | 默认值 | 说明 |
|------|--------|------|
| `CLONE_DIR` | `~/.github-researcher/projects` | 项目克隆目录 |
| `LOG_DIR` | `~/.github-researcher/logs` | 会话日志目录 |
| `PORT` | `13456` | OpenCode 服务端口 |
| `AGENT` | `sisyphus` | 默认使用的 Agent |
| `TIMEOUT` | `3600` | 默认超时时间（秒） |

**配置加载优先级**：脚本内默认值 → `.env.local` source 覆盖 → CLI 参数覆盖

## 技能扩展

### 添加研究步骤

1. 在 `SKILL.md` 中添加新步骤定义（编号遵循 `N.N` 格式）
2. 在 `agents/steps/` 下创建对应的详细文档（如 `08-new-step.md`）
3. 在 `SKILL_FULL.md` 的步骤索引中添加新条目
4. 步骤文档应包含：执行指令、命令模板、输出格式

### 添加安全检查模式

在 `agents/steps/03.3-security.md` 中扩展：

1. 添加新的语言特定 grep 模式（如新框架的配置注入）
2. 遵循现有格式：`模式名 | grep 命令 | 风险等级 | 说明`
3. 同步更新 SKILL.md 中的安全检查摘要

### 添加适配度评估维度

在 `agents/steps/04-fitness.md` 中：

1. 在 7 维度评分表中添加新维度
2. 定义评分标准（/N 分制）
3. 更新总分计算方式

### 添加竞品来源

在 `agents/steps/07-competitors.md` 中：

1. 添加新的竞品发现渠道（如 Awesome Lists、行业报告）
2. 更新功能矩阵模板的列定义

## 测试方法

### Dry Run（快速预检）

```bash
# 仅检查服务健康状态和参数解析，不执行研究
./research.sh https://github.com/octocat/Hello-World --dry-run
```

### 快速集成测试

```bash
# 用小型仓库做端到端测试
./research.sh https://github.com/octocat/Hello-World --async --log --verbose
```

### 完整测试

```bash
# 用中等规模仓库测试全部功能
./research.sh https://github.com/vercel/next.js --async --log --verbose

# 测试 Claude Runner
./research.sh https://github.com/octocat/Hello-World --runner claude

# 测试 Gemini Runner
./research.sh https://github.com/octocat/Hello-World --runner gemini
```

### Bash 语法检查

```bash
# ShellCheck 静态分析
shellcheck research.sh

# Bash 语法检查
bash -n research.sh
```

## Bash 编码规范摘要

项目遵循严格的 Bash 编码规范（详见 `agents/bash-style.md`）：

| 规范 | 说明 |
|------|------|
| Strict Mode | 脚本开头必须 `set -euo pipefail` |
| 全局变量 | `UPPER_SNAKE_CASE`（如 `PORT`、`GITHUB_URL`） |
| 局部变量 | `local` 声明 + `lower_snake_case` |
| 条件判断 | 使用 `[[ ]]` 而非 `[ ]` |
| 日志输出 | 统一使用 `log_info/ok/warn/error/step/msg` 函数 |
| JSON 处理 | 优先 python3 内联，jq 作为可选优化 |
| 颜色输出 | 遵循 NO_COLOR 标准（https://no-color.org/） |
| 错误处理 | `command \|\| { log_error "msg"; exit 1; }` 模式 |
| 清理机制 | `trap cleanup EXIT` 确保异常退出时清理资源 |
| 注释分隔 | `# ─── Section ───` 格式划分功能区域 |
