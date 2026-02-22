# Step 3: Deep Analysis (Code Projects)

> **返回索引:** [SKILL_FULL.md](../../SKILL_FULL.md)

> **Routing:** You arrive here from Step 3.0 when the project is a **code library** (not docs-first). For documentation projects, see Step 3.D.

This step was evolved from researching Skill_Seekers where all grep patterns were Python-only, missing potential multi-language projects.

---

## 3.A Language Detection (MANDATORY before analysis)

Auto-detect the project's primary language(s) before running any grep commands:

```bash
# Count files by extension to detect primary language(s)
find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './venv/*' -not -path './.venv/*' | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15
```

**Language → File Extension Mapping:**

| Language | Extensions | Dependency File | Entry Points |
|----------|-----------|-----------------|--------------|
| **Python** | `*.py` | `pyproject.toml`, `requirements.txt`, `setup.py` | `__init__.py`, `main.py`, `app.py` |
| **JavaScript** | `*.js`, `*.mjs`, `*.cjs` | `package.json` | `index.js`, `app.js`, `server.js` |
| **TypeScript** | `*.ts`, `*.tsx` | `package.json`, `tsconfig.json` | `index.ts`, `main.ts` |
| **Go** | `*.go` | `go.mod`, `go.sum` | `main.go`, `cmd/` |
| **Rust** | `*.rs` | `Cargo.toml` | `main.rs`, `lib.rs` |
| **Java** | `*.java` | `pom.xml`, `build.gradle` | `Main.java`, `Application.java` |
| **C/C++** | `*.c`, `*.cpp`, `*.h`, `*.hpp` | `CMakeLists.txt`, `Makefile` | `main.c`, `main.cpp` |
| **Ruby** | `*.rb` | `Gemfile` | `app.rb`, `config.ru` |
| **PHP** | `*.php` | `composer.json` | `index.php` |
| **Swift** | `*.swift` | `Package.swift` | `main.swift`, `App.swift` |
| **Kotlin** | `*.kt`, `*.kts` | `build.gradle.kts` | `Main.kt`, `Application.kt` |

**Set `$LANG_EXTS` for subsequent commands:**

Based on detection, construct the include flags. Examples:
- Python project: `--include="*.py"`
- TypeScript project: `--include="*.ts" --include="*.tsx"`
- Multi-language: `--include="*.py" --include="*.ts" --include="*.js"`

> **IMPORTANT:** Use the detected `$LANG_EXTS` in ALL grep/find commands in Steps 3.1–3.5 and 3.D. Do NOT hardcode `*.py`.

---

## 3.1 Code Structure Analysis

```bash
# Count lines by detected language (use detected extensions)
find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.js" \) -not -path './.git/*' | xargs wc -l 2>/dev/null | tail -1

# Find main entry points (adapt to detected language)
ls -la src/ lib/ app/ 2>/dev/null || ls -la *.py *.js *.ts 2>/dev/null | head -10

# Check for tests
ls -la test/ tests/ __tests__/ spec/ 2>/dev/null

# Test quality signals (adapt extensions to detected language)
TEST_FILES=$(find . -type f \( -path "*/test*" -o -path "*/spec*" -o -path "*__tests__*" \) \( -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.go" -o -name "*.rs" \) -not -path './.git/*' -not -path './node_modules/*' 2>/dev/null | wc -l)
SRC_FILES=$(find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.js" -o -name "*.go" -o -name "*.rs" \) -not -path './.git/*' -not -path './node_modules/*' -not -path '*/test*' -not -path '*/spec*' 2>/dev/null | wc -l)
echo "Test:Source ratio: ${TEST_FILES}:${SRC_FILES}"

# Assertion density
grep -rc "assert\|expect\|should\|require\|must" test/ tests/ __tests__/ spec/ 2>/dev/null | tail -1

# Mock overuse check
grep -rc "mock\|stub\|patch\|spy\|fake" test/ tests/ __tests__/ spec/ 2>/dev/null | tail -1

# CI runs tests?
grep -rlE "pytest|npm test|go test|cargo test|jest|mocha|vitest" .github/workflows/ 2>/dev/null
```

---

## 3.2 Dependency Analysis

| File | Command |
|------|---------|
| `package.json` | `jq '.dependencies, .devDependencies' package.json` |
| `requirements.txt` | `cat requirements.txt` |
| `pyproject.toml` | `cat pyproject.toml` |
| `go.mod` | `cat go.mod` |
| `Cargo.toml` | `cat Cargo.toml` |

**Check for:**
- Outdated dependencies (known CVEs)
- Excessive dependencies (bloat)
- Unmaintained dependencies

---

## 3.3 Security Analysis

See: [Step 3.3 Security](./03.3-security.md) for detailed security checks including:
- 3.3.1 AI Agent Safety Analysis
- 3.3.2 CI/CD Security Analysis

---

## 3.4 Code Quality Analysis

```bash
# Check for documentation
ls -la README* docs/ *.md 2>/dev/null

# Check for CI/CD
ls -la .github/workflows/ .gitlab-ci.yml .travis.yml Jenkinsfile 2>/dev/null

# Check code style configs
ls -la .eslintrc* .prettierrc* pyproject.toml setup.cfg .flake8 2>/dev/null
```

---

## 3.4.1 AI-Generated Project Detection

This step was evolved from researching Skill_Seekers, which had 30+ AI-generated markdown files (QA_*, PHASE_*, RELEASE_*, AGENTS.md, CLAUDE.md) in the repo root.

**Detection Signals:**

```bash
# Count AI-indicator files in repo root
ls -1 QA_* PHASE_* RELEASE_* *_SUMMARY.md *_REPORT.md AGENTS.md CLAUDE.md .cursorrules .cursor/ aider* 2>/dev/null | wc -l

# Check for AI agent config files
ls -la AGENTS.md CLAUDE.md .cursorrules .cursor/ .aider* .continue/ 2>/dev/null

# Count total markdown files in root (high count = signal)
ls -1 *.md 2>/dev/null | wc -l

# Check git log for AI-style commit messages
git log --oneline -20 2>/dev/null | grep -iE "refactor:|feat:|fix:|chore:|docs:|implement|add support for" | wc -l
```

**AI-Generated Project Indicators:**

| Signal | Detection | Confidence |
|--------|-----------|------------|
| `AGENTS.md` or `CLAUDE.md` in root | Direct evidence of AI agent usage | **High** |
| `.cursorrules` or `.cursor/` directory | Cursor AI configuration | **High** |
| 10+ markdown files in root with structured names (`QA_*`, `PHASE_*`, `RELEASE_*`) | AI-generated documentation artifacts | **High** |
| Uniform commit messages matching Conventional Commits perfectly | AI-generated commits | **Medium** |
| `*_SUMMARY.md`, `*_REPORT.md` pattern | AI analysis output files | **Medium** |

**How This Affects Analysis:**

| Aspect | Adjustment |
|--------|------------|
| **Code Quality** | AI-generated code can be clean but repetitive. Check for copy-paste patterns. |
| **Documentation** | Discount AI-generated docs for "documentation quality" — focus on README and inline comments. |
| **Test Coverage** | AI often generates tests that look complete but have shallow assertions. Verify quality. |
| **Architecture** | AI-generated projects may have over-abstracted structures. Check if abstractions are justified. |
