# Research Workflow Reference

Quick reference for the 7-step research workflow.

---

## Workflow Overview

```
1. Fetch Project Info → 2. Clone to Local → 3.0 Type Gate
                                              ↓
                                    ┌─────────┴─────────┐
                                    ↓                   ↓
                              3.D Docs             3. Code Analysis
                              Analysis             ├─ 3.1 Structure
                              ├─ 3.D.1 IA          ├─ 3.2 Dependencies
                              ├─ 3.D.2 Build       ├─ 3.3 Security
                              ├─ 3.D.3 Coverage    │  ├─ 3.3.1 Agent Safety
                              ├─ 3.D.4 Writing     │  └─ 3.3.2 CI/CD Security
                              └─ 3.D.5 Links       ├─ 3.4 Quality
                                                    ├─ 3.4.1 AI Detection
                                                    └─ 3.5 Architecture
                                    └─────────┬─────────┘
                                              ↓
4. Evaluate Fitness → 4.2 Ecosystem Audit → 4.5 Domain Fitness
                                              ↓
5. Generate RESEARCH.md → 6. Update KB → 7. Competitor Analysis
```

---

## Step 1: Fetch Project Info

### Tool Check (MANDATORY FIRST)
```bash
gh auth status 2>&1
```

| Result | Strategy |
|--------|----------|
| ✅ Authenticated | Strategy A: gh CLI |
| ❌ No auth | Strategy B: webfetch |
| ⚠️ Rate limited | Strategy C: curl |

### Strategy A: gh CLI
```bash
gh repo view {owner}/{repo} --json name,description,stargazerCount,licenseInfo
gh api repos/{owner}/{repo}/readme --jq '.content' | base64 -d
gh api repos/{owner}/{repo}/git/trees/HEAD?recursive=1 --jq '.tree[].path'
```

### Strategy B: webfetch
```
webfetch(url="https://github.com/{owner}/{repo}", format="text")
webfetch(url="https://github.com/{owner}/{repo}/blob/main/README.md")
```

### Strategy C: curl
```bash
curl -s "https://api.github.com/repos/{owner}/{repo}" | jq '{name, stargazers_count}'
```

---

## Step 2: Clone to Local

```bash
mkdir -p $CLONE_BASE/{author}
git clone https://github.com/{author}/{repo}.git $CLONE_BASE/{author}/{repo}
```

---

## Step 3.0: Project Type Gate

```bash
# Count files by type
CODE_COUNT=$(find . -type f \( -name "*.py" -o -name "*.ts" -o -name "*.js" \) -not -path './.git/*' | wc -l)
DOCS_COUNT=$(find . -type f \( -name "*.md" -o -name "*.rst" \) -not -path './.git/*' | wc -l)

# Check for docs tooling
ls conf.py mkdocs.yml 2>/dev/null
```

| Signal | Type | Route |
|--------|------|-------|
| `.rst/.md` dominates + `conf.py` | Docs | Step 3.D |
| `.py/.ts` dominates + `pyproject.toml` | Code | Step 3 |
| Both substantial | Mixed | 3.D → 3 |

---

## Step 3.D: Docs Analysis

### 3.D.1 Information Architecture
```bash
rg "toctree" --include="*.rst" -l
cat docs/contents.rst 2>/dev/null
```

### 3.D.2 Build Pipeline
```bash
cat conf.py | grep -E "extensions|theme"
cat mkdocs.yml | grep -E "theme:|plugins:"
```

### 3.D.4 Writing Quality (Score 0-2 each)
- Clarity: Can beginners follow?
- Structure: Consistent hierarchy?
- Voice: Consistent tone?
- Actionability: Copy-paste examples?

---

## Step 3: Code Analysis

### 3.A Language Detection (MANDATORY)
```bash
find . -type f -not -path './.git/*' | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15
```

### 3.1 Structure
```bash
find . -type f \( -name "*.py" -o -name "*.ts" \) | xargs wc -l | tail -1
ls -la src/ lib/ tests/
```

### 3.2 Dependencies
```bash
jq '.dependencies' package.json  # JS
cat requirements.txt              # Python
cat Cargo.toml                    # Rust
```

### 3.3 Security (adapt to language)
```bash
# Python
grep -r "password\|api_key" --include="*.py" .
grep -r "eval\|exec" --include="*.py" .
grep -r "pickle.load\|yaml.load" --include="*.py" .

# JS/TS
grep -r "eval(\|new Function(" --include="*.js" --include="*.ts" .
```

### 3.3.1 AI Agent Safety
```bash
# Find agent config files
find . -type f \( -name "AGENTS.md" -o -name "CLAUDE.md" -o -name ".cursorrules" \
  -o -name "*.mdc" -o -name "copilot-instructions.md" \) -not -path './.git/*'

# Scan for prompt injection / exfiltration / shell execution patterns
grep -rni "ignore previous\|disregard\|curl.*\|wget.*\|exec(\|subprocess" \
  AGENTS.md CLAUDE.md .cursorrules .cursor/rules/*.mdc 2>/dev/null
```

### 3.3.2 CI/CD Security
```bash
# Check for pull_request_target (high risk)
grep -r "pull_request_target" .github/workflows/ 2>/dev/null

# Check workflow permissions
grep -rA2 "permissions:" .github/workflows/ 2>/dev/null

# Unpinned actions (using @master or @main instead of SHA)
grep -r "uses:.*@\(main\|master\|latest\)" .github/workflows/ 2>/dev/null

# Script injection via untrusted input
grep -r '\${{.*github\.event' .github/workflows/ 2>/dev/null
```

### 3.4.1 AI Detection
```bash
ls -1 AGENTS.md CLAUDE.md .cursorrules 2>/dev/null | wc -l
ls -1 *.md 2>/dev/null | wc -l
```

---

## Step 3.5: Architecture

```bash
# Python
grep -r "class.*:" --include="*.py" . | grep -E "(Base|Abstract)"
grep -r "register\|factory" --include="*.py" .

# TypeScript
grep -r "class.*extends\|implements" --include="*.ts" .
grep -r "createFactory\|Provider" --include="*.ts" .
```

---

## Step 4: Fitness Evaluation

| Dimension | Score |
|-----------|-------|
| Functionality | /10 |
| Compatibility | /10 |
| Maintenance | /10 |
| Community | /10 |
| Security Posture | /20 |
| License | /10 |
| Integration | /10 |
| **Total** | **/80** |

---

## Step 4.2: Ecosystem Audit

For projects older than 2 years with recommendations:

1. **Gate check (4.2.0)**: Skip if project age < 2 years or `lastPushedAt` within 90 days with active releases
2. Extract claims inventory
3. Fire 3-6 librarian agents in parallel
4. Build modern replacements table
5. Add appendix to RESEARCH.md

---

## Step 4.5: Domain Fitness

For cross-domain evaluation:

| Aspect | Native | Target | Gap |
|--------|--------|--------|-----|
| Data Format | OHLCV | Tick data | Medium |
| Latency | EOD | Sub-second | High |

Score: /60 across 6 dimensions

---

## Step 5: Generate RESEARCH.md

Location: `$CLONE_BASE/{owner}/{repo}/RESEARCH.md`

Sections:
- Executive Summary
- Project Overview (table)
- Capabilities
- Use Cases
- Vulnerabilities & Concerns
- Security Posture (/20 quantified checklist)
- Fitness Evaluation
- Recommendation
- Quick Start

---

## Step 6: Update KB

Location: `$CLONE_BASE/KNOWLEDGE_BASE.md`

### KB Entry Format
```markdown
## {Project} ({date})

**Verdict:** {one-line}
**Key Insight:** {single learning}
**Reusable Pattern:** {pattern or technique worth reusing}
**Deep Dive:** [→](./{author}/{repo}/RESEARCH.md)
**Tags:** {2-5 tags}
```

### KB Hygiene Rules
- Append ONLY non-empty fields
- Keep index table at top
- Consolidate when >150 lines

---

## Step 7: Competitor Analysis

```bash
gh search repos "{keywords}" --limit 20 --sort stars
```

Output: Feature matrix + positioning map + use case recommendations
