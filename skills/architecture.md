# 系统架构分析

## 整体架构

github-project-researcher 采用"Prompt + Shell CLI"双层架构：

1. **Prompt 层** — SKILL.md / SKILL_FULL.md 定义 AI 研究工作流（7 步流程、决策逻辑、输出模板）
2. **CLI 层** — research.sh 封装多 Runner 调度，处理会话管理、异步轮询、日志记录

```
用户请求
  │
  ├── 直接对话 → AI 加载 SKILL.md → 执行研究工作流
  │
  └── CLI 调用 → research.sh
                    │
                    ├── Runner: opencode → OpenCode Server API
                    │     ├── 创建 session
                    │     ├── 发送研究 prompt
                    │     ├── 轮询/等待完成
                    │     └── 提取结果
                    │
                    ├── Runner: claude → Claude Code CLI (print mode)
                    │     └── 直接调用 claude -p "$PROMPT"
                    │
                    └── Runner: gemini → Gemini CLI (headless)
                          └── echo "$PROMPT" | gemini
```

## CLI 架构 (research.sh)

### 模块划分

research.sh (~787 行) 按功能区域组织，使用注释分隔符 `# ─── Section ───` 划分：

| 区域 | 行数范围 | 功能 |
|------|----------|------|
| Defaults | 39-56 | 全局变量初始化（PORT、AGENT、TIMEOUT 等） |
| Load Config | 58-64 | 从 `.env.local` 加载本地配置 |
| Colors | 66-81 | ANSI 颜色定义，支持 NO_COLOR 标准 |
| Helpers | 83-108 | 日志函数（log_info/ok/warn/error/step/msg）|
| Usage | 110-140 | 帮助信息 |
| Parse Args | 142-191 | 参数解析（while + case 模式） |
| Parse URL | 193-213 | GitHub URL 解析（正则提取 owner/repo） |
| Build Prompt | 215-232 | 构造中文研究提示词 |
| Log Directory | 234-299 | 会话日志管理（setup/save/fetch messages） |
| Display Header | 341-358 | 终端信息展示 |
| Runner: OpenCode | 360-607 | OpenCode Server Runner（健康检查→会话→请求→结果） |
| Runner: Claude | 609-662 | Claude Code CLI Runner |
| Runner: Gemini | 664-723 | Gemini CLI Runner |
| Cleanup | 725-735 | EXIT trap 清理 |
| Runner Dispatch | 737-749 | case 分发到对应 Runner |
| Output | 751-787 | 最终结果展示 |

### Runner 设计模式

三个 Runner 遵循统一的函数接口：

```bash
run_with_opencode()  # 最完整：session 管理 + 异步轮询 + 日志
run_with_claude()    # 简化：直接 CLI 调用
run_with_gemini()    # 简化：管道输入 CLI
```

每个 Runner 包含：
1. **Preflight Check** — 检查工具可用性和认证状态
2. **Dry Run Gate** — `--dry-run` 时仅执行预检
3. **Execute** — 发送研究请求
4. **Extract Result** — 从响应中提取文本

### 降级策略

```
gh CLI (认证) → webfetch (公开) → curl (API, 60 req/hr)
```

这个降级链在 SKILL.md 的 Step 1 中定义，用于获取项目信息。CLI 本身不实现降级逻辑（由 AI Agent 根据 SKILL.md 指令执行）。

## 研究工作流引擎

工作流是纯 Prompt 驱动的，定义在 SKILL.md 中：

```
Step 1: Fetch Project Info     (必选)
Step 2: Clone to Local         (必选)
Step 3.0: Project Type Gate    (必选) → 路由到 3.D 或 3
  ├── Step 3.D: Docs Analysis  (文档项目)
  │     ├── 3.D.1 信息架构
  │     ├── 3.D.2 构建管道
  │     ├── 3.D.3 内容覆盖热力图
  │     ├── 3.D.4 写作质量评分 (/8)
  │     └── 3.D.5 链接健康
  └── Step 3: Code Analysis    (代码项目)
        ├── 3.A 语言自动检测 (强制)
        ├── 3.1 结构分析
        ├── 3.2 依赖分析
        ├── 3.3 安全分析
        │     ├── 3.3.1 AI Agent 安全
        │     └── 3.3.2 CI/CD 安全
        ├── 3.4 质量评估
        │     └── 3.4.1 AI 生成检测
        └── 3.5 架构分析

Step 4: Fitness Evaluation     (条件性)
  ├── 4.2 Ecosystem Audit      (项目 > 2 年)
  └── 4.5 Domain Fitness       (跨域评估时)

Step 5: Generate RESEARCH.md   (必选)
Step 6: Update Knowledge Base  (必选)
Step 7: Competitor Analysis    (按需)
```

### 知识库架构

知识库采用分层存储：

| 层级 | 文件 | 内容 | 行数目标 |
|------|------|------|----------|
| 索引层 | KNOWLEDGE_BASE.md | 项目一览表 + 简要条目 | 50-80 行 |
| 模式层 | PATTERNS.md | 可复用的架构模式详情 | 500+ 行 |
| 详情层 | {author}/{repo}/RESEARCH.md | 完整研究报告 | 按项目规模 |

### 知识库质量控制

- **Pattern Worth Gate**: 5 条判断标准，仅记录跨项目可复用、新颖、命名清晰的架构级模式
- **去重机制**: Knowledge Linking — 已存在的模式只添加来源项目名，不重复描述
- **卫生规则**: 不写空条目、不写占位符、超过 100 行触发整合

## 技能定义结构

项目包含两级技能文档：

| 文件 | 用途 | 加载方式 |
|------|------|----------|
| SKILL.md (~265 行) | 精简版，含完整工作流指令和 CLI 参考 | 默认加载（符号链接到技能目录） |
| SKILL_FULL.md (~178 行) | 完整参考，索引到 agents/steps/ 的详细文档 | 按需读取 |
| agents/steps/*.md (~1670 行) | 每个步骤的详细执行指令、命令和模板 | AI 按步骤按需读取 |

这种分层设计平衡了 token 消耗和信息完整性：常规研究只需加载 SKILL.md，深入某个步骤时再读取对应的 steps/ 文件。

## 配置架构

```bash
# .env.local (gitignored)
CLONE_DIR=~/.github-researcher/projects   # 克隆目录
LOG_DIR=~/.github-researcher/logs          # 日志目录
PORT=13456                                  # OpenCode 服务端口
AGENT=sisyphus                             # 使用的 Agent
TIMEOUT=3600                               # 超时时间
```

配置加载链：
1. 脚本内默认值 → 2. `.env.local` source 覆盖 → 3. CLI 参数覆盖

## 关键设计原则

1. **自进化** — 每次研究后更新知识库，技能随使用越来越强
2. **优雅降级** — gh CLI → webfetch → curl 三级降级，确保无 API Key 也能工作
3. **语言无关** — 分析前先检测项目语言，根据语言选择对应的安全检查模式
4. **最小输出** — 知识库条目保持紧凑，详细信息在 RESEARCH.md 中
5. **证据驱动** — 所有结论需有支撑数据
