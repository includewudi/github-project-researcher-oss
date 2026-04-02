# Step 3d: Documentation Analysis

> **Routing:** Step 3.0 routes here for docs-first projects.

## 3d.1 Information Architecture

```bash
# Sphinx
rg "toctree" --include="*.rst" -l 2>/dev/null
cat docs/contents.rst.inc 2>/dev/null || cat index.rst 2>/dev/null

# MkDocs
cat mkdocs.yml 2>/dev/null | grep -A 100 "^nav:"

# Map top-level sections
find docs/ -maxdepth 2 -name "*.rst" -o -name "*.md" 2>/dev/null | sort
```

**Output:** IA Map — sections, depth, entry points, orphan pages.

## 3d.2 Build Pipeline

```bash
# Sphinx
cat conf.py 2>/dev/null | grep -E "extensions|theme|html_theme"
cat Makefile 2>/dev/null | grep -E "^[a-z]+:"

# MkDocs
cat mkdocs.yml 2>/dev/null | grep -E "theme:|plugins:|markdown_extensions:"

# CI for docs
cat .github/workflows/*.yml 2>/dev/null | grep -E "sphinx|mkdocs|readthedocs|deploy"
ls .readthedocs.yml 2>/dev/null
```

**Output:** Build tool, theme, extensions, CI pipeline, hosting target.

## 3d.3 Content Coverage

```bash
# Volume per section
for dir in docs/*/; do echo "$(find "$dir" -name '*.rst' -o -name '*.md' | wc -l) $dir"; done | sort -rn

# Stub/empty files
find docs/ -name "*.rst" -o -name "*.md" | xargs grep -lE "^$|TODO|FIXME|placeholder|coming soon" 2>/dev/null

# Staleness (macOS)
find docs/ -name "*.rst" -o -name "*.md" -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -20
```

**Output:** Coverage heatmap — deep vs thin sections, stale areas.

## 3d.4 Writing Quality (/8)

Score each 0-2 (0=poor, 1=adequate, 2=excellent):

| Dimension | What to Check |
|-----------|---------------|
| **Clarity** | Can a beginner follow? Terms defined? |
| **Structure** | Consistent headings? Logical ordering? |
| **Voice** | Consistent tone? Opinionated where appropriate? |
| **Actionability** | Concrete examples? Copy-paste commands? |

## 3d.5 Link Health

```bash
# External URLs
rg "https?://" --include="*.rst" --include="*.md" -o --no-filename | sort -u > /tmp/urls.txt
wc -l /tmp/urls.txt

# Flag stale domains
rg "https?://" --include="*.rst" --include="*.md" -o | grep -iE "deprecated|archived|dead|obsolete|pythonhosted\.org" 2>/dev/null
```

**Output:** Total links, flagged potentially broken/stale links.
