# Step 7: Competitor Analysis

> **Open when:** User needs competitive landscape or alternatives.

## 7.1 Keyword Derivation

```bash
gh repo view {owner}/{repo} --json repositoryTopics --jq '.repositoryTopics[]' 2>/dev/null
head -5 README.md 2>/dev/null
```

Combine: repo topics + README first line + category → 3-5 keywords.

> **Minimum bar:** Identify ≥5 active competitors (last commit within 12 months).

## 7.2 Discover Competitors

```bash
# GitHub search
gh search repos "{keywords}" --limit 20 --sort stars --json name,owner,description,stargazerCount,url
```

**Web search for curated lists:**
```
websearch: "awesome {domain} github"
websearch: "{project} alternatives"
websearch: "best {domain} frameworks {year}"
```

## 7.3 Feature Comparison Matrix

| Feature | {Project} | Competitor A | Competitor B | Competitor C |
|---------|-----------|--------------|--------------|--------------|
| Stars | {count} | {count} | {count} | {count} |
| Last Commit | {date} | {date} | {date} | {date} |
| License | {type} | {type} | {type} | {type} |
| Feature 1 | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ |
| Learning Curve | Easy/Med/Hard | ... | ... | ... |
| Documentation | Poor/Good/Exc | ... | ... | ... |

## 7.4 Positioning Map

```
                    Enterprise-Grade
                         ↑
                         |
     Full-Featured ←------+------→ Lightweight
                         |
                         ↓
                    Hobby/Learning
```

## 7.5 Recommendation Matrix

| Use Case | Recommended | Why |
|----------|-------------|-----|
| {Case 1} | {Project/Competitor} | {reasoning} |

## 7.6 Output: COMPETITORS.md

Save to `~/.github-researcher/projects/{owner}/{repo}/COMPETITORS.md`

```markdown
# Competitor Analysis: {Project}
**Generated:** {date}
**Domain:** {domain}

## Competitors Identified
| Project | Stars | Description | URL |

## Feature Comparison
{matrix}

## Positioning Map
{diagram}

## Use Case Recommendations
{table}

## Key Insights
- **Strengths:** {what project does best}
- **Weaknesses:** {where competitors excel}
- **Market Gap:** {unmet needs}
```
