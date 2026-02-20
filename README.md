# github-project-researcher

**English** | [中文](README_ZH.md)

Prompt-only [OpenCode](https://github.com/anthropics/opencode) skill for researching GitHub projects.

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
git clone https://github.com/anthropics/github-project-researcher.git

# Symlink into OpenCode skills directory
mkdir -p ~/.config/opencode/skills/github-project-researcher
ln -s "$(pwd)/SKILL.md" ~/.config/opencode/skills/github-project-researcher/SKILL.md
```

## Configuration

All paths are configurable via environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `GITHUB_RESEARCHER_CLONE_DIR` | `~/.github-researcher/projects` | Where researched projects are cloned |
| `GITHUB_RESEARCHER_LOG_DIR` | `~/.github-researcher/logs` | Where session logs are saved |

```bash
# Example: customize clone and log directories
export GITHUB_RESEARCHER_CLONE_DIR="$HOME/research/projects"
export GITHUB_RESEARCHER_LOG_DIR="$HOME/research/logs"
```

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
```

## Requirements

- [OpenCode](https://github.com/anthropics/opencode) with server mode (`opencode serve`)
- `bash` 4.0+
- `curl`
- `python3`
- `gh` CLI (optional, for richer GitHub data)

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
├── research.sh          # CLI wrapper for OpenCode server
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
