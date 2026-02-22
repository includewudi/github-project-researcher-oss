# Step 3.0: Project Type Gate (MANDATORY before analysis)

> **返回索引:** [SKILL_FULL.md](../../SKILL_FULL.md)

This step was evolved from researching `realpython/python-guide` where code-analysis templates were forced onto a documentation-first project, producing irrelevant results.

**Detect whether the repo is a code library, a documentation project, or mixed — then route to the appropriate analysis path.**

---

## 3.0.1 Detect Project Type

```bash
# Count files by type to determine project nature
CODE_COUNT=$(find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.rb" -o -name "*.c" -o -name "*.cpp" \) -not -path './.git/*' -not -path './node_modules/*' -not -path './venv/*' | wc -l)

DOCS_COUNT=$(find . -type f \( -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.adoc" \) -not -path './.git/*' | wc -l)

# Check for docs build tooling
ls conf.py mkdocs.yml mkdocs.yaml .readthedocs.yml docs/conf.py 2>/dev/null
```

**Decision Table:**

| Signal | Project Type | Route To |
|--------|-------------|----------|
| `.rst/.md` files dominate AND (`conf.py` or `mkdocs.yml` present) | **Docs Project** | Step 3.D |
| `.py/.ts/.go` dominate AND (`pyproject.toml` / `package.json` / `go.mod` + `src/`) | **Code Library** | Step 3 (existing) |
| Both substantial code and docs directories with build tooling | **Mixed** | Step 3.D THEN Step 3 |
| `DOCS_COUNT` > `CODE_COUNT` × 2 AND docs build tool present | **Docs Project** | Step 3.D |

> **Rule:** When in doubt, run both paths. The docs path is lightweight and won't bloat the analysis.

---

## 3.0.2 Monorepo Detection

```bash
# Detect monorepo structures
ls packages/ apps/ libs/ lerna.json nx.json pnpm-workspace.yaml rush.json turbo.json 2>/dev/null
```

| Signal | Action |
|--------|--------|
| `packages/` or `apps/` + workspace config | Monorepo — scope analysis to dominant package |
| `lerna.json` or `nx.json` or `turbo.json` | Build orchestrator detected — note in report |
| Single `src/` directory | Standard layout — proceed normally |

> **If monorepo detected:** Add note "Monorepo detected. Analysis scoped to primary package: {dir}" and focus analysis on the dominant package directory.
