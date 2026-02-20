---
name: github-project-researcher
description: Use when researching GitHub projects - analyzing capabilities, architecture patterns, finding vulnerabilities, evaluating fitness for needs (including cross-domain applicability), competitor analysis, cloning to local library, and generating research documentation. Self-evolving through accumulated knowledge.
---

# GitHub Project Researcher

Self-evolving GitHub project research agent. Analyze projects, find vulnerabilities, evaluate fitness, **understand architecture**, **assess cross-domain applicability**, **compare competitors**, clone to local library, generate documentation.

**Clone Directory:** `$CLONE_BASE/{author}/{repo}` (default: `~/.github-researcher/projects/`)
**Log Directory:** `$LOG_BASE/{owner}_{repo}_{timestamp}` (default: `~/.github-researcher/logs/`)
**Full Reference:** Read `SKILL_FULL.md` for detailed bash commands, templates, and language-specific examples.

## Default Behavior

当用户说"研究 xxx"或"Research xxx"时，默认使用以下命令：

```bash
./research.sh <github_url> --async --log --verbose
```

**选项说明：**
- `--async` — 异步模式，不阻塞终端
- `--log` — 保存完整会话日志到日志目录
- `--verbose` — 显示实时研究进度消息

**日志位置：** `$LOG_BASE/{owner}_{repo}_{timestamp}/SESSION.md`

## When to Use

- Research a GitHub project's capabilities and use cases
- Analyze project architecture and design patterns (Step 3.5)
- Analyze documentation-first projects (Step 3.D)
- Find security vulnerabilities or code quality issues
- Evaluate if a project fits specific needs
- Audit if recommendations/tooling are still current (Step 4.2)
- Assess project fitness for a DIFFERENT domain (Step 4.5)
- Find and compare alternative/competitor projects (Step 7)
- Clone projects with organized directory structure
- Generate comprehensive research documentation
- Build knowledge base from accumulated research

## Quick Start

```
User: "Research https://github.com/facebook/react"
User: "Analyze if langchain fits my RAG needs"
User: "Find vulnerabilities in fastapi project"
User: "Analyze the architecture of microsoft/qlib"           # Step 3.5
User: "Research realpython/python-guide"                      # Step 3.D (docs project)
User: "Is qlib suitable for crypto trading?"                  # Step 4.5
User: "What are alternatives to freqtrade for algo trading?" # Step 7
```

**收到研究请求后，执行：**
```bash
./research.sh <GITHUB_URL> --async --log --verbose
```

## CLI Reference

| Option | Default | Description |
|--------|---------|-------------|
| `--async` | - | 异步模式（推荐） |
| `--log` | - | 保存会话日志 |
| `--verbose` | - | 显示实时进度 |
| `--log-dir DIR` | `~/.github-researcher/logs` | 自定义日志目录 |
| `--agent AGENT` | sisyphus | 指定 agent |
| `--model MODEL` | default | 指定模型 |
| `--timeout SECS` | 3600 | 超时时间 |
| `--dry-run` | - | 健康检查 |

## Research Workflow

| Step | Name | When to Use | Details |
|------|------|-------------|---------|
| 1 | Fetch Project Info | Always | gh CLI → webfetch → curl fallback chain |
| 2 | Clone to Local | Always | `/github/{author}/{repo}` convention |
| **3.0** | **Project Type Gate** | Always | Route to docs vs code analysis |
| **3.D** | **Docs Deep Analysis** | Docs-first projects | IA, build pipeline, quality scoring |
| 3 | Deep Analysis (Code) | Code libraries | Language auto-detect, deps, security, quality |
| **3.4.1** | **AI Detection** | Always | Assess AI involvement level |
| **3.5** | **Architecture Analysis** | Complex projects | Patterns, hierarchy, extension points |
| 4 | Evaluate Fitness | When checking requirements | 7-dimension scoring /70 |
| **4.2** | **Ecosystem Audit** | Projects >2 years old | Parallel librarian agents for currency check |
| **4.5** | **Domain Fitness** | Cross-domain evaluation | Gap analysis, reusability matrix, adaptation strategy |
| 5 | Generate RESEARCH.md | Always | Comprehensive report in clone dir |
| 6 | Update Knowledge Base | Always | **6.0 Pattern Worth Gate → 6.1 Hygiene → 6.2 Knowledge Linking** |
| **7** | **Competitor Analysis** | When exploring alternatives | Feature matrix, positioning map, recommendations |

> **For detailed bash commands and templates for each step**, read `SKILL_FULL.md`.

## Step Routing Summary

### Steps 1-2: Fetch & Clone
- Check `gh auth status` → Strategy A (gh) / B (webfetch) / C (curl)
- Clone to `$CLONE_BASE/{author}/{repo}`
- Use `--depth 1` for large repos

### Step 3.0: Project Type Gate
- Count code vs docs files → route to Step 3.D (docs) or Step 3 (code) or both (mixed)
- When in doubt, run both paths

### Step 3.D: Docs Analysis
- IA mapping, build pipeline, content coverage heatmap, writing quality /8, link health

### Step 3: Code Analysis
- **3.A** Language auto-detect (MANDATORY) → set `$LANG_EXTS` for all greps
- **3.1** Structure, **3.2** Dependencies, **3.3** Security (language-specific patterns), **3.4** Quality
- **3.4.1** AI-generated project detection (AGENTS.md, .cursorrules, commit patterns)
- **3.5** Architecture: design patterns, component hierarchy (ASCII), extension points

### Steps 4, 4.2, 4.5: Evaluation
- **Step 4**: 7-dimension fitness scoring /70
- **Step 4.2**: Extract recommendations → fire parallel librarian agents → Modern Replacements table
- **Step 4.5**: Domain gap analysis → component reusability matrix → adaptation strategy (Wrap/Fork/Hybrid/Inspiration)

### Step 5: Generate RESEARCH.md
- Output to clone directory with standard template (see SKILL_FULL.md for full template)

### Step 7: Competitor Analysis
- GitHub search + web search + awesome lists
- Feature comparison matrix, positioning map, recommendation by use case
- Generate COMPETITORS.md

## Step 6: Update Knowledge Base (Core Rules)

**KB Path:** `$CLONE_BASE/KNOWLEDGE_BASE.md`

### 6.0 Pattern Worth Gate (MANDATORY before KB write)

Before writing ANY new pattern to `## 可复用模式`, ALL 5 must pass:

| # | Question | Fail → Action |
|---|----------|---------------|
| 1 | **Reusable across projects?** Would a DIFFERENT project benefit? | Skip — too project-specific |
| 2 | **Novel?** Already in KB (exact or near-duplicate)? | Skip — or LINK to existing (6.2) |
| 3 | **Named?** Clear ≤5-word name? | Skip — too vague |
| 4 | **Architecture-level?** Design pattern, not implementation detail? | Skip — RESEARCH.md only |
| 5 | **Future value?** Useful to a researcher 3 months from now? | Skip — ephemeral |

**Throttle:** Max **3 new patterns** per project research. Pick most novel if >3 worthy.

### 6.1 KB Hygiene Rules

1. **Append minimal non-empty entries only** — no "None found", no "N/A", no placeholders
2. **Maintain index table at top** — one row per project, don't duplicate into detailed entry
3. **Consolidation pass** — trigger at >150 lines OR every 3 projects (merge shared patterns, remove empty headings, verify links)
4. **Deep-Dive Navigation** — KB gets verdict/insight/tags/link; details stay in RESEARCH.md

**Per-project entry template:**
```markdown
## {Project Name} ({date})

**Verdict:** {one-line}
**Key Insight:** {most valuable learning}
**Reusable Pattern:** {pattern name, or omit if none passed Gate}
**Deep Dive:** [{Project} RESEARCH.md](./{author}/{repo}/RESEARCH.md)
**Tags:** {2-5 tags}
```

### 6.2 Knowledge Linking (Cross-Project Pattern Dedup)

When a new project exhibits an **existing** KB pattern:

| Situation | Action |
|-----------|--------|
| Exact match in KB | Add project name to existing pattern heading, no new bullets |
| Same family, new variant | Add project name to heading + append variant sub-bullet |
| Truly novel | Pass Pattern Worth Gate → add new entry with `(project)` in heading |

**In per-project entries**, reference linked patterns: `Uses 客户端-守护进程 IPC 架构 (see 可复用模式)` — never re-describe.

> **Rule:** A pattern appears in KB exactly ONCE in `## 可复用模式`, with ALL source projects in its heading.

## Error Handling

| Error | Action |
|-------|--------|
| Repo not found | Verify URL/name is correct |
| `gh` not authenticated | Switch to Strategy B (webfetch) — do NOT retry `gh` |
| `gh` rate limited | Switch to Strategy C (curl) — 60 req/hr |
| `webfetch` returns 404 | Try alternate branch names (`main` → `master` → `develop`) |
| Clone failed | Check SSH keys or use HTTPS |
| Large repo | Use `--depth 1` for shallow clone |
| Private repo | Ensure `gh auth login`; cannot use Strategy B/C |
| All strategies fail | Report errors; ask user to run `gh auth login` |

## Common Research Patterns

| Pattern | Steps | Time |
|---------|-------|------|
| **Quick Assessment** | 1 → 2 → README → verdict | 5 min |
| **Deep Dive** | Full 1-7 workflow | 30 min |
| **Security Audit** | 1 → 2 → 3.3 → deps CVE → report | 15 min |
| **Architecture Discovery** | 1 → 2 → 3.5 → document | 20 min |
| **Cross-Domain Eval** | 1-4 → 4.5 → report | 25 min |
| **Competitive Landscape** | 1-5 → 7 → COMPETITORS.md | 30 min |
| **Documentation Project** | 1 → 2 → 3.0 → 3.D → 4.2 (if old) | 20 min |
| **Recommendation Audit** | Extract claims → parallel librarians → verdicts | 15 min |

## Related Skills

- `librarian` - For finding documentation and examples
- `explore` - For deep code exploration
- `oracle` - For complex architecture analysis
