# github-project-researcher

**English** | [中文](README_ZH.md)

Prompt-only AI [OpenCode](https://github.com/anomalyco/opencode) skill for researching GitHub projects.

## What it does

- Analyze GitHub project capabilities, architecture, and design patterns
- Find security vulnerabilities and code quality issues
- Evaluate project fitness for specific needs (including cross-domain applicability)
- Compare competitors and alternatives
- Clone projects with organized directory structure
- Generate comprehensive research documentation (RESEARCH.md)
- Build self-evolving knowledge base (KNOWLEDGE_BASE.md)

## Install

```bash
# Clone the repository
git clone https://github.com/includewudi/github-project-researcher-oss.git

# Symlink into OpenCode skills directory
mkdir -p ~/.config/opencode/skills/github-project-researcher
ln -s "$(pwd)/SKILL.md" ~/.config/opencode/skills/github-project-researcher/SKILL.md
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
| `AGENT` | `sisyphus` | Agent to use |
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
| 3 | Deep Analysis | Code, deps, security, quality |
| 3.5 | Architecture Analysis | Patterns, hierarchy, extension points |
| 4 | Evaluate Fitness | Scoring against user requirements |
| 4.5 | Domain Fitness | Cross-domain applicability assessment |
| 5 | Generate RESEARCH.md | Comprehensive research report |
| 6 | Update Knowledge Base | Accumulate learnings |
| 7 | Competitor Analysis | Alternatives comparison matrix |

## Project Structure

```
github-project-researcher/
├── research.sh          # Multi-runner CLI for project research
├── .env.local.example   # Config template (copy to .env.local)
├── SKILL.md             # Compact skill definition (loaded by default)
├── SKILL_FULL.md        # Full reference with detailed commands & templates
├── AGENTS.md            # AI agent guidance
├── README.md            # This file
├── LICENSE              # MIT license
└── agents/              # Detailed guides
    ├── bash-style.md    # Bash scripting conventions
    ├── skill-dev.md     # Skill development patterns
    └── workflow.md      # Research workflow reference
```

## License

MIT
