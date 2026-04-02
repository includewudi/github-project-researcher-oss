# Step 3: Code Analysis (Structure, Dependencies, Quality)

> **Routing:** You arrive here from Step 3.0 for code libraries. For docs, see `03d-docs.md`.
> **Security:** Run in parallel — see `steps/03-security.md` for all security checks (code, agent safety, CI/CD).

## 3.A Language Detection (MANDATORY — see SKILL.md Rule 2)

```bash
find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './venv/*' \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15
```

**Set `--include` flags based on result.** Never hardcode `*.py`.

| Language | Extensions | Dep File | Entry Points |
|----------|-----------|----------|-------------|
| Python | `*.py` | `pyproject.toml`, `requirements.txt` | `__init__.py`, `main.py` |
| JS/TS | `*.ts`, `*.tsx`, `*.js` | `package.json`, `tsconfig.json` | `index.ts`, `app.ts` |
| Go | `*.go` | `go.mod` | `main.go`, `cmd/` |
| Rust | `*.rs` | `Cargo.toml` | `main.rs`, `lib.rs` |
| Java | `*.java` | `pom.xml`, `build.gradle` | `Main.java` |
| C/C++ | `*.c`, `*.cpp` | `CMakeLists.txt`, `Makefile` | `main.c` |

## 3.1 Structure Analysis

```bash
# Lines of code by detected language
find . -type f -name "*.EXT" -not -path './.git/*' | xargs wc -l 2>/dev/null | tail -1

# Entry points
ls -la src/ lib/ app/ 2>/dev/null || ls -la *.EXT 2>/dev/null | head -10

# Test quality
TEST_FILES=$(find . -type f -path "*/test*" -name "*.EXT" -not -path './.git/*' -not -path './node_modules/*' 2>/dev/null | wc -l)
SRC_FILES=$(find . -type f -name "*.EXT" -not -path './.git/*' -not -path '*/test*' -not -path './node_modules/*' 2>/dev/null | wc -l)
echo "Test:Source ratio: ${TEST_FILES}:${SRC_FILES}"

# Assertion density
grep -rc "assert\|expect\|should\|require" test/ tests/ __tests__/ spec/ 2>/dev/null | tail -1

# CI runs tests?
grep -rlE "pytest|npm test|go test|cargo test|jest|mocha|vitest" .github/workflows/ 2>/dev/null
```

## 3.2 Dependencies

| Dep File | Command |
|----------|---------|
| `package.json` | `python3 -c "import json; d=json.load(open('package.json')); print(json.dumps({**d.get('dependencies',{}), **d.get('devDependencies',{})}, indent=2))"` |
| `pyproject.toml` | `cat pyproject.toml` |
| `go.mod` | `cat go.mod` |
| `Cargo.toml` | `cat Cargo.toml` |

**Check for:** outdated deps, excessive deps, unmaintained deps.

## 3.4 Quality Signals

```bash
# Documentation exists?
ls -la README* docs/ *.md 2>/dev/null

# CI/CD?
ls -la .github/workflows/ .gitlab-ci.yml .travis.yml Jenkinsfile 2>/dev/null

# Code style configs?
ls -la .eslintrc* .prettierrc* pyproject.toml setup.cfg .flake8 2>/dev/null
```

## 3.4.1 AI-Generated Project Detection

```bash
# AI-indicator files
ls -1 QA_* PHASE_* RELEASE_* *_SUMMARY.md *_REPORT.md AGENTS.md CLAUDE.md .cursorrules .cursor/ aider* 2>/dev/null | wc -l

# Git log for AI-style commits
git log --oneline -20 2>/dev/null | grep -iE "refactor:|feat:|fix:|chore:|implement|add support for" | wc -l
```

| Signal | Confidence |
|--------|-----------|
| `AGENTS.md` or `CLAUDE.md` in root | **High** |
| `.cursorrules` or `.cursor/` directory | **High** |
| 10+ structured markdown files in root | **High** |
| Perfect Conventional Commits pattern | **Medium** |

> **Impact:** Discount AI-generated docs for quality scoring. Check tests for shallow assertions. Verify abstractions are justified.
