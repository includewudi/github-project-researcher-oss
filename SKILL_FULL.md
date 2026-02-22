# GitHub Project Researcher — 完整参考

> **精简版:** [SKILL.md](./SKILL.md) | **步骤详情:** [agents/steps/](./agents/steps/)

Prompt-only AI skill for comprehensive GitHub project research.

---

## Section Index

| Section | File | Description |
|---------|------|-------------|
| Configuration | [→](#configuration) | `.env.local` 设置 |
| Quick Start | [→](#quick-start) | 5 分钟快速开始 |
| CLI Reference | [→](#cli-reference) | `research.sh` 命令 |
| Workflow Overview | [→](#workflow-overview) | 7 步工作流 |
| Step Details | [agents/steps/](./agents/steps/) | 各步骤详细文档 |
| Common Patterns | [→](#common-research-patterns) | 常用研究模式 |
| Error Handling | [→](#error-handling) | 错误处理策略 |

---

## Configuration

Copy `.env.local.example` to `.env.local` and customize:

| Variable | Default | Description |
|----------|---------|-------------|
| `CLONE_DIR` | `~/.github-researcher/projects` | Where projects are cloned |
| `LOG_DIR` | `~/.github-researcher/logs` | Where session logs are saved |
| `PORT` | `13456` | OpenCode server port |
| `AGENT` | `sisyphus` | Agent to use |
| `TIMEOUT` | `3600` | Timeout in seconds |
| `HOST` | `127.0.0.1` | Server host |
| `MODEL` | (default) | Model override |

---

## Quick Start

```bash
# 1. Symlink skill
mkdir -p ~/.config/opencode/skills/github-project-researcher
ln -s "$(pwd)/SKILL.md" ~/.config/opencode/skills/github-project-researcher/SKILL.md

# 2. Create config
cp .env.local.example .env.local

# 3. Research a project
./research.sh https://github.com/owner/repo --async --log
```

---

## CLI Reference

```bash
./research.sh <GITHUB_URL> [OPTIONS]

Options:
  --runner RUNNER    Execution backend: opencode (default), claude, gemini
  --port PORT        OpenCode server port (default: 13456)
  --async            Non-blocking mode (polls for completion)
  --log              Save session log
  --log-dir DIR      Custom log directory
  --verbose          Show real-time messages (async mode)
  --agent AGENT      Agent to use (default: sisyphus)
  --model MODEL      Model override (provider/model)
  --timeout SECS     Timeout for sync mode (default: 3600)
  --dry-run          Health check only
  --help             Show help
```

---

## Workflow Overview

```
1. Fetch Project Info → 2. Clone to Local → 3.0 Type Gate
                                              ↓
                                    ┌─────────┴─────────┐
                                    ↓                   ↓
                              3.D Docs             3. Code Analysis
                              Analysis             ├─ 3.1 Structure
                              ├─ 3.D.1 IA          ├─ 3.2 Dependencies
                              ├─ 3.D.2 Build       ├─ 3.3 Security
                              ├─ 3.D.3 Coverage    │  ├─ 3.3.1 Agent Safety
                              ├─ 3.D.4 Writing     │  └─ 3.3.2 CI/CD Security
                              └─ 3.D.5 Links       ├─ 3.4 Quality
                                                  │  └─ 3.4.1 AI Detection
                                                  └─ 3.5 Architecture
                                    └─────────┬─────────┘
                                              ↓
4. Evaluate Fitness → 4.2 Ecosystem Audit → 4.5 Domain Fitness
                                              ↓
5. Generate RESEARCH.md → 6. Update KB → 7. Competitor Analysis
```

---

## Step Details

详细步骤文档在 `agents/steps/` 目录：

| Step | File | Content |
|------|------|---------|
| 1 | [01-fetch.md](./agents/steps/01-fetch.md) | Fetch Project Info |
| 2 | [02-clone.md](./agents/steps/02-clone.md) | Clone to Local |
| 3.0 | [03-type-gate.md](./agents/steps/03-type-gate.md) | Project Type Gate |
| 3.D | [03d-docs-analysis.md](./agents/steps/03d-docs-analysis.md) | Documentation Analysis |
| 3 | [03-analysis.md](./agents/steps/03-analysis.md) | Deep Analysis (Code) |
| 3.3 | [03.3-security.md](./agents/steps/03.3-security.md) | Security Analysis |
| 3.5 | [03.5-architecture.md](./agents/steps/03.5-architecture.md) | Architecture Analysis |
| 4 | [04-fitness.md](./agents/steps/04-fitness.md) | Fitness Evaluation |
| 4.2 | [04.2-ecosystem.md](./agents/steps/04.2-ecosystem.md) | Ecosystem Audit |
| 4.5 | [04.5-domain.md](./agents/steps/04.5-domain.md) | Domain Fitness |
| 5 | [05-research.md](./agents/steps/05-research.md) | Generate RESEARCH.md |
| 6 | [06-kb.md](./agents/steps/06-kb.md) | Update Knowledge Base |
| 7 | [07-competitors.md](./agents/steps/07-competitors.md) | Competitor Analysis |

---

## Common Research Patterns

### Pattern: Quick Assessment (5 min)

1. `gh repo view` - Get overview
2. Check README - Understand purpose
3. Check stars/last commit - Assess popularity
4. Check license - Compatibility
5. Quick verdict

### Pattern: Deep Dive (30 min)

1. Full workflow (Steps 1-7)
2. Read key source files
3. Run tests locally
4. Check all open issues
5. Generate comprehensive RESEARCH.md

### Pattern: Security Audit

1. Clone locally
2. Run all security checks (Step 3.3)
3. Check dependencies for CVEs
4. Review auth/crypto code
5. Generate security-focused report

### Pattern: Cross-Domain Evaluation

1. Complete basic research (Steps 1-4)
2. Define target domain
3. Gap analysis (Step 4.5)
4. Rate component reusability
5. Recommend adaptation strategy

---

## Error Handling

| Error | Action |
|-------|--------|
| Repo not found | Verify URL/name is correct |
| `gh` not authenticated | **Switch to webfetch** |
| `gh` rate limited | **Switch to curl** (60 req/hr) |
| `webfetch` returns 404 | Try alternate branches (`main` → `master`) |
| Clone failed | Check SSH keys or use HTTPS |
| Large repo | Use `--depth 1` for shallow clone |
| Private repo | Ensure `gh auth login` completed |

---

## Related Skills

- `librarian` - For finding documentation and examples
- `explore` - For deep code exploration
- `oracle` - For complex architecture analysis
