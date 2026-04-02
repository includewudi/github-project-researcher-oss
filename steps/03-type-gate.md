# Step 3.0: Project Type Gate

Detect project type → route to correct analysis path.

## Detect Type

```bash
CODE_COUNT=$(find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.rb" -o -name "*.c" -o -name "*.cpp" \) -not -path './.git/*' -not -path './node_modules/*' -not -path './venv/*' | wc -l)

DOCS_COUNT=$(find . -type f \( -name "*.md" -o -name "*.rst" -o -name "*.txt" -o -name "*.adoc" \) -not -path './.git/*' | wc -l)

# Check docs build tooling
ls conf.py mkdocs.yml mkdocs.yaml .readthedocs.yml docs/conf.py 2>/dev/null
```

## Decision Table

| Signal | Project Type | Route To |
|--------|-------------|----------|
| `.rst/.md` dominate AND (`conf.py` or `mkdocs.yml` present) | **Docs Project** | `steps/03d-docs.md` |
| `.py/.ts/.go` dominate AND (`pyproject.toml` / `package.json` / `go.mod` + `src/`) | **Code Library** | `steps/03-analysis.md` |
| Both substantial | **Mixed** | `03d-docs.md` THEN `03-analysis.md` |
| `DOCS_COUNT` > `CODE_COUNT` × 2 AND docs build tool | **Docs Project** | `steps/03d-docs.md` |

> **Rule:** When in doubt, run both paths. Docs path is lightweight.

## Monorepo Detection

```bash
ls packages/ apps/ libs/ lerna.json nx.json pnpm-workspace.yaml rush.json turbo.json 2>/dev/null
```

| Signal | Action |
|--------|--------|
| `packages/` or `apps/` + workspace config | Monorepo — scope to dominant package |
| `lerna.json` / `nx.json` / `turbo.json` | Note build orchestrator |
| Single `src/` directory | Standard layout — proceed normally |

> **If monorepo:** Note "Monorepo detected. Analysis scoped to primary package: {dir}" and focus on the dominant package.
