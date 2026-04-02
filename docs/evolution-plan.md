# Research Skill Evolution Plan

> Created: 2026-03-29
> Status: 3-iteration rewrite in progress

## Current Problems

| # | Problem | Detail |
|---|---------|--------|
| 1 | Monolithic SKILL.md | 265 lines trying to cover everything; SKILL_FULL.md + 12 step sub-docs scattered and redundant |
| 2 | No Progressive Disclosure | All info crammed into SKILL.md; LLM skips sub-documents in practice |
| 3 | Shell script dependency | research.sh is the CLI entry point, but Butler pipeline uses opencode_serve executor — shell script is legacy |
| 4 | No decision tree | 7+2 steps without "what should I do?" routing like fast-edit |
| 5 | Rigid output format | RESEARCH.md template is fixed; no quick/depth/security modes |
| 6 | Complex KB maintenance | KNOWLEDGE_BASE.md + PATTERNS.md two-layer maintenance, Pattern Worth Gate is verbose |
| 7 | Disconnected from Butler | opencode_serve input_data injection bug shows lack of contract between skill and executor |

## Fast-Edit Principles to Adopt

| Principle | Application |
|-----------|-------------|
| Decision tree first | Top-level "what should I do?" routing: quick assess / deep dive / security audit / competitor analysis / architecture discovery |
| Safety rules inline | 3-5 critical rules in SKILL.md body, not hidden in sub-docs |
| On-demand sub-documents | Detailed commands and templates loaded only when needed |
| Concise command reference | Core commands at a glance; details in sub-docs |
| Verification mechanism | Post-generation validation checklist for RESEARCH.md completeness |
| Use case table | Pattern → Steps → Time, researcher sees the path immediately |

## Evolution Direction

1. **Three-layer Progressive Disclosure**: SKILL.md (<200 lines: decision tree + rules + reference) → steps/ (on-demand) → templates/ (on-demand)
2. **Decision tree driven**: Top-level answers "what? how deep? why?" to auto-route to correct step subset
3. **Prompt-only, no shell**: Remove research.sh dependency; skill is pure prompt instructions (Butler already has executor layer)
4. **Output modes**: Support quick summary / deep report / security audit / competitor analysis modes
5. **Obsidian auto-archive**: Post-research prompt to archive to vault (github-research convention)
6. **KB simplification**: Flatten to single KNOWLEDGE_BASE.md with stricter throttling; remove PATTERNS.md

## Butler Contract

The ResearchExecutor (`butler/executors/research.py`) calls:
```
skill("github-project-researcher")
研究 {github_url}。
```
And expects `RESEARCH.md` at `~/.github-researcher/projects/{owner}/{repo}/RESEARCH.md`.

The skill must produce this file path. The executor reads `ctx.input_data` for `research_md` — future steps (md2wechat) receive it via pipeline merge.

## Target Structure

```
github-project-researcher/
├── SKILL.md              # Layer 1: Decision tree + rules + reference (<200 lines)
├── steps/
│   ├── 01-fetch.md       # Layer 2: Fetch project info (gh → webfetch → curl)
│   ├── 02-clone.md       # Clone to local
│   ├── 03-type-gate.md   # Route to code vs docs analysis
│   ├── 03-analysis.md    # Code analysis (structure, deps, security, quality)
│   ├── 03d-docs.md       # Documentation analysis
│   ├── 03-security.md    # Security deep-dive (agent safety, CI/CD)
│   ├── 03-architecture.md # Architecture patterns + hierarchy
│   ├── 04-fitness.md     # Fitness evaluation + scoring
│   ├── 05-report.md      # Generate RESEARCH.md (with template)
│   ├── 06-kb.md          # Knowledge base update (simplified)
│   └── 07-competitors.md # Competitor analysis
├── templates/
│   ├── research-quick.md # Quick assessment template
│   ├── research-deep.md  # Deep dive template (default)
│   ├── research-security.md # Security audit template
│   └── kb-entry.md       # KB per-project entry template
└── docs/
    └── evolution-plan.md # This file
```

## Related Files

- Research Skill source: `/Users/wudi/data/code/ai_tools/git_skills/wudi/github-project-researcher-oss/`
- Fast Edit reference: `/Users/wudi/data/code/ai_tools/git_skills/wudi/fast-edit/`
- Butler ResearchExecutor: `/Users/wudi/data/code/ai_tools/opencode/butler/butler/executors/research.py`
- doc-store github-research convention: `/Users/wudi/data/code/ai_tools/git_skills/wudi/doc-store/references/config.md`
- Installed skill symlink: `~/.config/opencode/skills/github-project-researcher/SKILL.md`
