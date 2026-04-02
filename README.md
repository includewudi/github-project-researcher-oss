# github-project-researcher

**English** | [中文](README_ZH.md)

Prompt-only AI [OpenCode](https://github.com/anomalyco/opencode) skill for deep research on GitHub projects. Supports multi-runner execution (OpenCode / Claude Code / Gemini CLI).

## Features

- Analyze GitHub project capabilities, architecture, and design patterns
- Find security vulnerabilities and code quality issues
- Evaluate project fitness for specific needs (including cross-domain applicability)
- Compare competitors and alternatives
- Clone projects with organized directory structure
- Generate comprehensive research documentation (RESEARCH.md)
- Build self-evolving knowledge base (KNOWLEDGE_BASE.md)
- **Modular step system** — each research phase is a standalone doc, easy to extend
- **Optional SlowMist integration** — escalate to [SlowMist Agent Security](https://github.com/slowmist/slowmist-agent-security) for Web3/blockchain/agent security deep review

## Install

```bash
# Clone the repository
git clone https://github.com/includewudi/github-project-researcher-oss.git
cd github-project-researcher-oss

# Symlink into OpenCode skills directory
mkdir -p ~/.config/opencode/skills/github-project-researcher
ln -s "$(pwd)/SKILL.md" ~/.config/opencode/skills/github-project-researcher/SKILL.md
```

### Optional: SlowMist Security Skill

For deeper security analysis on Web3/blockchain/agent projects:

```bash
git clone https://github.com/slowmist/slowmist-agent-security.git \
  ~/.config/opencode/skills/slowmist-agent-security
```

## Configuration

Copy `.env.local.example` to `.env.local` and customize:

```bash
cp .env.local.example .env.local
```

| Variable | Default | Description |
|----------|---------|-------------|
| `CLONE_DIR` | `~/.github-researcher/projects` | Where researched projects are cloned |
| `LOG_DIR` | `~/.github-researcher/logs` | Where session logs are saved |
| `PORT` | `13456` | OpenCode server port |
| `HOST` | `127.0.0.1` | OpenCode server host |
| `AGENT` | `sisyphus` | Agent to use |
| `MODEL` | _(default)_ | Model override (`provider/model`) |
| `TIMEOUT` | `3600` | Timeout in seconds |

`.env.local` is gitignored — safe for private paths.

## Usage

```
"Research https://github.com/facebook/react"
"Analyze if langchain fits my RAG needs"
"Find vulnerabilities in fastapi project"
"What are alternatives to freqtrade for algo trading?"
```

### CLI

```bash
# Quick research (async with logging)
./research.sh https://github.com/owner/repo --async --log --verbose

# Dry run (health check only)
./research.sh https://github.com/owner/repo --dry-run

# Custom agent/model
./research.sh https://github.com/owner/repo --agent build --model "provider/model"

# Use Claude Code CLI (no server required)
./research.sh https://github.com/owner/repo --runner claude

# Use Gemini CLI (no server required)
./research.sh https://github.com/owner/repo --runner gemini
```

See `./research.sh --help` for all options.

## Requirements

**Core:**
- `bash` 4.0+
- `python3`
- `gh` CLI (optional, for richer GitHub data)

**Per-Runner:**

| Runner | Requirement |
|--------|-------------|
| `opencode` (default) | [OpenCode](https://github.com/anomalyco/opencode) server (`opencode serve`) + `curl` |
| `claude` | [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI + `ANTHROPIC_API_KEY` |
| `gemini` | [Gemini CLI](https://github.com/google-gemini/gemini-cli) + `GEMINI_API_KEY` |

## Workflow

| Step | Name | Description |
|------|------|-------------|
| 1 | Fetch Project Info | gh CLI metadata, README, structure |
| 2 | Clone to Local | Organized `{author}/{repo}` convention |
| 3 | Deep Analysis | Code quality, deps, type/language gate |
| 3-security | Security Audit | 4-dimension scoring (/20), optional SlowMist escalation |
| 3-architecture | Architecture Analysis | Patterns, hierarchy, extension points |
| 3-docs | Documentation Review | README quality, API docs, examples |
| 4 | Evaluate Fitness | Scoring against user requirements |
| 4.5 | Domain Fitness | Cross-domain applicability assessment |
| 5 | Generate RESEARCH.md | Comprehensive research report |
| 6 | Update Knowledge Base | Accumulate learnings |
| 7 | Competitor Analysis | Alternatives comparison matrix |

## Security Module

Built-in 4-dimension security scoring (/20):

| Dimension | What it covers |
|-----------|---------------|
| Supply Chain | Dependencies, install scripts, lock files |
| Code Security | Injection, secrets, auth, crypto |
| Infrastructure | CI/CD, permissions, pinned actions |
| AI Agent Safety | Skill/MCP trust, data exfiltration, prompt injection |

**SlowMist escalation** triggers automatically when:
- Web3 / blockchain / DeFi project detected
- Agent/MCP/skill with 🔴 findings
- Initial score ≤ 10/20
- User explicitly requests stricter review

## Project Structure

```
github-project-researcher/
├── research.sh              # Multi-runner CLI
├── SKILL.md                 # Compact skill definition (loaded by default)
├── SKILL_FULL.md            # Full reference with detailed commands & templates
├── AGENTS.md                # AI agent guidance
├── .env.local.example       # Config template (copy to .env.local)
├── steps/                   # Modular research steps
│   ├── 01-fetch.md          #   Step 1: Fetch project info
│   ├── 02-clone.md          #   Step 2: Clone to local
│   ├── 03-type-gate.md      #   Step 3: Language/type detection
│   ├── 03-analysis.md       #   Step 3: Code quality analysis
│   ├── 03-security.md       #   Step 3: Security audit + SlowMist
│   ├── 03-architecture.md   #   Step 3.5: Architecture analysis
│   ├── 03d-docs.md          #   Step 3.D: Documentation review
│   ├── 04-fitness.md        #   Step 4: Fitness evaluation
│   ├── 05-report.md         #   Step 5: Generate RESEARCH.md
│   ├── 06-kb.md             #   Step 6: Update knowledge base
│   └── 07-competitors.md    #   Step 7: Competitor analysis
├── templates/               # Report templates
│   ├── research-deep.md     #   Full research report
│   ├── research-quick.md    #   Quick assessment
│   ├── research-security.md #   Security-focused report
│   └── kb-entry.md          #   Knowledge base entry
├── agents/                  # Development guides
│   ├── bash-style.md        #   Bash scripting conventions
│   ├── skill-dev.md         #   Skill development patterns
│   └── workflow.md          #   Research workflow reference
├── skills/                  # Sub-skill definitions
│   ├── SKILL.md             #   OSS skill variant
│   ├── architecture.md      #   Architecture analysis
│   └── development.md       #   Development patterns
├── docs/                    # Project documentation
│   └── evolution-plan.md    #   Roadmap and evolution plan
├── README.md                # This file
├── README_ZH.md             # Chinese documentation
└── LICENSE                  # MIT license
```

## License

MIT
