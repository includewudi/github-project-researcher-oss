# Step 3.D: Documentation Project Deep Analysis

> **返回索引:** [SKILL_FULL.md](../../SKILL_FULL.md)

**When to Use:** Routed here by Step 3.0 for repos that are primarily documentation (guides, tutorials, references).

This step was evolved from researching `realpython/python-guide` — a Sphinx-based documentation project where standard code analysis (class hierarchies, security patterns, dependency audit) was meaningless.

---

## 3.D.1 Information Architecture & Navigation

```bash
# Find documentation structure (Sphinx)
rg "toctree" --include="*.rst" -l 2>/dev/null
cat docs/contents.rst.inc 2>/dev/null || cat index.rst 2>/dev/null

# Find documentation structure (MkDocs)
cat mkdocs.yml 2>/dev/null | grep -A 100 "^nav:"

# Map top-level sections
find docs/ -maxdepth 2 -name "*.rst" -o -name "*.md" 2>/dev/null | sort
```

**Output:** IA Map — list of sections, depth, entry points, any orphan pages.

---

## 3.D.2 Build Pipeline & Tooling

```bash
# Sphinx projects
cat conf.py 2>/dev/null | grep -E "extensions|theme|html_theme"
cat Makefile 2>/dev/null | grep -E "^[a-z]+:"

# MkDocs projects
cat mkdocs.yml 2>/dev/null | grep -E "theme:|plugins:|markdown_extensions:"

# CI/CD for docs
cat .github/workflows/*.yml 2>/dev/null | grep -E "sphinx|mkdocs|readthedocs|deploy"
ls .readthedocs.yml 2>/dev/null
```

**Output:** Build tool, theme, extensions, CI pipeline (if any), hosting target.

---

## 3.D.3 Content Coverage & Gaps

```bash
# Count content volume per section
for dir in docs/*/; do echo "$(find "$dir" -name '*.rst' -o -name '*.md' | wc -l) $dir"; done | sort -rn

# Find stub/empty files
find docs/ -name "*.rst" -o -name "*.md" | xargs grep -lE "^$|TODO|FIXME|placeholder|coming soon" 2>/dev/null

# Last-modified signals per section
# macOS
find docs/ -name "*.rst" -o -name "*.md" -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -20
# Linux
# find docs/ \( -name "*.rst" -o -name "*.md" \) -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -20
```

**Output:** Coverage heatmap — which sections are deep vs thin, which are stale.

---

## 3.D.4 Writing Quality & Consistency

Score each dimension 0-2 (0=poor, 1=adequate, 2=excellent):

| Dimension | Score | What to Check |
|-----------|-------|---------------|
| **Clarity** | /2 | Can a beginner follow instructions? Are terms defined? |
| **Structure** | /2 | Consistent heading hierarchy? Logical section ordering? |
| **Voice** | /2 | Consistent tone? Opinionated where appropriate? |
| **Actionability** | /2 | Concrete examples? Copy-paste commands? |
| **Total** | **/8** | |

---

## 3.D.5 Link Health

```bash
# Extract all external URLs
rg "https?://" --include="*.rst" --include="*.md" -o --no-filename | sort -u > /tmp/urls.txt
wc -l /tmp/urls.txt

# Flag obviously stale domains
rg "https?://" --include="*.rst" --include="*.md" -o | grep -iE "deprecated|archived|dead|obsolete|pythonhosted\.org" 2>/dev/null
```

**Output:** Total link count, flagged potentially broken/stale links.

---

## 3.D.6 RESEARCH.md Section Template

For documentation projects, replace the standard "Architecture Analysis" section with:

```markdown
## Documentation Analysis

### Information Architecture

{IA map — sections, depth, entry points}

### Build Pipeline

| Component | Value |
|-----------|-------|
| Build Tool | {Sphinx/MkDocs/...} |
| Theme | {theme name} |
| Extensions | {list} |
| Hosting | {RTD/GitHub Pages/self-hosted} |
| CI | {yes/no — workflow file} |

### Content Coverage

| Section | Files | Depth | Freshness |
|---------|-------|-------|-----------|
| {section} | {count} | {shallow/deep} | {active/stale} |

### Writing Quality: {score}/8

| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | /2 | {notes} |
| Structure | /2 | {notes} |
| Voice | /2 | {notes} |
| Actionability | /2 | {notes} |

### Link Health

- Total external links: {count}
- Flagged stale/broken: {count}
- {Notable issues}

### Key Findings

- {Finding 1}
- {Finding 2}
```
