# AGENTS.md — GitHub Project Researcher

> Guidance for AI coding agents working in this repository.

## Project Overview

Prompt-only OpenCode skill for researching GitHub projects. Analyzes capabilities, architecture, security, fitness, and competitors. Generates RESEARCH.md documentation and maintains KNOWLEDGE_BASE.md.

**Key Files:**
- `research.sh` — Multi-runner CLI (opencode/claude/gemini)
- `SKILL.md` — Skill definition with full workflow (load via skill tool)
- `agents/` — Detailed style and workflow guides

---

## Build/Lint/Test Commands

### Run the Research Script
```bash
# Basic usage (sync mode, blocks until complete)
./research.sh https://github.com/owner/repo

# Async mode (polls for completion)
./research.sh https://github.com/owner/repo --async

# Async mode with logging (saves to log directory)
./research.sh https://github.com/owner/repo --async --log

# Async mode with logging + real-time messages
./research.sh https://github.com/owner/repo --async --log --verbose

# With custom agent/model
./research.sh https://github.com/owner/repo --agent build --model "github-copilot/claude-sonnet-4"

# Custom log directory
./research.sh https://github.com/owner/repo --async --log --log-dir /custom/path

# Dry run (health check only)
./research.sh https://github.com/owner/repo --dry-run
```

### CLI Options

| Option | Default | Description |
|--------|---------|-------------|
| `--runner RUNNER` | opencode | Execution backend: opencode, claude, gemini |
| `--port PORT` | 13456 | OpenCode server port (opencode only) |
| `--async` | false | Async mode (non-blocking) |
| `--log` | false | Save session log |
| `--log-dir DIR` | `~/.github-researcher/logs` | Custom log directory |
| `--verbose` | false | Show real-time messages in async mode |
| `--agent AGENT` | sisyphus | Agent to use |
| `--model MODEL` | default | Model override (provider/model) |
| `--timeout SECS` | 3600 | Timeout for sync mode |
| `--dry-run` | false | Health check only |
| `--help` | - | Show help message |

### Lint Bash Script
```bash
# ShellCheck (recommended)
shellcheck research.sh

# Bash syntax check
bash -n research.sh
```

### Test Commands
```bash
# Verify script is executable
test -x research.sh && echo "OK"

# Health check against server
./research.sh --dry-run https://github.com/example/test
```

---

## Code Style Guidelines

### Bash Scripting (research.sh)

```bash
# ALWAYS use strict mode at script start
set -euo pipefail

# Use meaningful variable names (UPPERCASE for globals)
PORT=13456
GITHUB_URL=""

# Use local for function variables
parse_url() {
    local url="$1"
    local owner=""
    # ...
}

# Prefer [[ ]] over [ ] for conditionals
if [[ -z "$GITHUB_URL" ]]; then
    log_error "Missing URL"
    exit 1
fi

# Use printf or echo -e with explicit flags
echo -e "${GREEN}[OK]${NC} Success"

# Quote all variables to prevent word splitting
curl -sf "${BASE_URL}/session" -d "$PAYLOAD"
```

### Error Handling
```bash
# Always check command exit codes with || or set -e
curl -sf "${BASE_URL}/health" || {
    log_error "Server not reachable"
    exit 1
}

# Use trap for cleanup
cleanup() {
    # Cleanup code
}
trap cleanup EXIT
```

### Logging Pattern
```bash
log_info()  { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
```

### JSON Processing
```bash
# Prefer python3 for JSON parsing (available everywhere)
VALUE=$(echo "$JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['key'])")

# Use jq if available, but provide python fallback
if command -v jq &>/dev/null; then
    VALUE=$(echo "$JSON" | jq -r '.key')
else
    VALUE=$(echo "$JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['key'])")
fi
```

---

## Imports & Dependencies

### Required Tools
- `bash` 4.0+
- `curl` — HTTP requests
- `python3` — JSON parsing

### Optional Tools
- `jq` — JSON processing (python fallback exists)
- `shellcheck` — Bash linting

### No External Libraries
This project uses only standard Unix tools. No npm, pip, or other package managers required.

---

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Global variables | `UPPER_SNAKE_CASE` | `PORT`, `GITHUB_URL` |
| Local variables | `lower_snake_case` | `session_id`, `owner` |
| Functions | `lower_snake_case()` | `parse_github_url()` |
| Constants | `UPPER_CASE` | `RED='\033[0;31m'` |
| Environment | `UPPER_CASE` | `RESEARCH_PROMPT` |

---

## File Structure

```
github-project-researcher/
├── research.sh          # Multi-runner CLI script
├── .env.local.example   # Config template (copy to .env.local)
├── SKILL.md             # OpenCode skill definition (1000+ lines)
├── README.md            # Project overview
├── LICENSE              # MIT license
├── AGENTS.md            # This file
└── agents/              # Detailed guides
    ├── bash-style.md    # Bash scripting conventions
    ├── skill-dev.md     # Skill development patterns
    └── workflow.md      # Research workflow summary
```

---

## Skill Development

When modifying SKILL.md or adding workflow steps:

1. **Workflow Steps** — Number sequentially (1, 2, 3, 3.5, 4, 4.2, 4.5, 5, 6, 7)
2. **Sub-steps** — Use decimal notation (3.1, 3.2, 3.D.1)
3. **Code Blocks** — Always specify language: `bash`, `markdown`, `dot`
4. **Tables** — Use for decision matrices and checklists
5. **Diagrams** — Use graphviz `dot` syntax in fenced code blocks

See `agents/skill-dev.md` for detailed patterns.

---

## Output Conventions

### RESEARCH.md Location
```
$CLONE_BASE/{owner}/{repo}/RESEARCH.md
```

### KNOWLEDGE_BASE.md Location
```
$CLONE_BASE/KNOWLEDGE_BASE.md
```

### Session Logs Location (with --log)
```
$LOG_BASE/{owner}_{repo}_{timestamp}/SESSION.md
```

### File Naming
- `RESEARCH.md` — Per-project research output
- `KNOWLEDGE_BASE.md` — Accumulated learnings
- `COMPETITORS.md` — Competitor analysis (optional)
- `SESSION.md` — Research session log (when using --log)

---

## Common Tasks

### Add New Research Step
1. Add step section to SKILL.md with numbered heading
2. Include bash commands in fenced blocks
3. Add output template
4. Update workflow diagram

### Modify CLI Options
1. Add case to argument parser in `research.sh`
2. Update usage() function
3. Update README.md with new option

### Test Skill Changes
```bash
# Quick test with dry-run
./research.sh --dry-run https://github.com/example/test

# Full test with small repo
./research.sh https://github.com/octocat/Hello-World --async
```

---

## Recommended Tools

### fast-edit

For large file edits (SKILL_FULL.md, workflow.md) and batch modifications, use [fast-edit](https://github.com/includewudi/fast-edit) — a specialized skill for fast, reliable large-file editing that avoids timeout issues with standard Edit/Write tools.

---

## Related Documentation

- [agents/bash-style.md](agents/bash-style.md) — Detailed bash conventions
- [agents/skill-dev.md](agents/skill-dev.md) — Skill development patterns
- [agents/workflow.md](agents/workflow.md) — Research workflow reference
- [SKILL.md](SKILL.md) — Full skill definition (load via skill tool)

---

## Key Principles

1. **Self-Evolving** — Skill improves with each research; update KB after every run
2. **Graceful Degradation** — `gh` CLI → webfetch → curl fallback chain
3. **Language Agnostic** — Detect project language before analysis
4. **Minimal Output** — KB entries should be compact; details in RESEARCH.md
5. **Evidence-Based** — All claims need supporting data

---

## Clone Directory Convention

All researched projects are cloned to:
```
$CLONE_BASE/{owner}/{repo}/
```
