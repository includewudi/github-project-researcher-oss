# Step 7: Competitor Analysis

> **返回索引:** [SKILL_FULL.md](../../SKILL_FULL.md)

**When to Use:** When user needs to understand the competitive landscape or find alternatives.

---

## 7.0 Keyword Derivation (before search)

```bash
# Extract search keywords from repo metadata
gh repo view {owner}/{repo} --json repositoryTopics --jq '.repositoryTopics[]' 2>/dev/null
head -5 README.md 2>/dev/null

# Combine: repo topics + README first line + project category
# Use 3-5 most descriptive keywords for competitor search
```

> **Minimum bar:** Identify ≥5 active competitors (last commit within 12 months).

---

## 7.1 Discover Competitors

```bash
# GitHub search for similar projects
gh search repos "{keywords}" --limit 20 --sort stars --json name,owner,description,stargazerCount,url

# Example for quant framework competitors
gh search repos "quantitative trading python" --limit 20 --sort stars
gh search repos "backtesting framework" --limit 20 --sort stars
```

**Web search for curated lists:**

```
websearch: "awesome {domain} github"
websearch: "{project} alternatives"
websearch: "best {domain} frameworks {year}"
```

---

## 7.2 Build Competitor Matrix

| Feature | {Project} | Competitor A | Competitor B | Competitor C |
|---------|-----------|--------------|--------------|--------------|
| **Stars** | {count} | {count} | {count} | {count} |
| **Last Commit** | {date} | {date} | {date} | {date} |
| **License** | {type} | {type} | {type} | {type} |
| **Primary Language** | {lang} | {lang} | {lang} | {lang} |
| **Feature 1** | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ |
| **Feature 2** | ✅/❌ | ✅/❌ | ✅/❌ | ✅/❌ |
| **Learning Curve** | {Easy/Medium/Hard} | ... | ... | ... |
| **Documentation** | {Poor/Good/Excellent} | ... | ... | ... |

---

## 7.3 Positioning Analysis

```
MARKET POSITIONING MAP

                    Enterprise-Grade
                         ↑
                         |
    Full-Featured ←------+------→ Lightweight
                         |
                         ↓
                    Hobby/Learning

{Project}: [position description]
Competitor A: [position description]
```

---

## 7.4 Recommendation Matrix

| Use Case | Recommended | Why |
|----------|-------------|-----|
| {Use Case 1} | {Project/Competitor} | {reasoning} |
| {Use Case 2} | {Project/Competitor} | {reasoning} |
| **Hybrid Approach** | {Combination} | {when to combine} |

---

## 7.5 Generate COMPETITORS.md

```markdown
# Competitor Analysis: {Project}

**Generated:** {date}
**Domain:** {e.g., Quantitative Trading Frameworks}

## Competitors Identified

| Project | Stars | Description | URL |
|---------|-------|-------------|-----|
| ... | ... | ... | ... |

## Feature Comparison

{Feature matrix from 7.2}

## Positioning Map

{ASCII diagram from 7.3}

## Use Case Recommendations

{Table from 7.4}

## Key Insights

- **{Project}'s Strengths:** {what it does best}
- **{Project}'s Weaknesses:** {where competitors excel}
- **Gap in Market:** {unmet needs}

## Conclusion

{Clear recommendation based on user's stated needs}
```

---

## 7.6 Quick Competitor Check Pattern (5 min)

```bash
# 1. Search GitHub
gh search repos "{project domain}" --limit 10 --sort stars --json name,stargazerCount,description | jq -r '.[] | "\(.stargazerCount)\t\(.name)"' | sort -rn

# 2. Check awesome list
# Search: "awesome {domain}"

# 3. Quick verdict
# Pick top 3 competitors, note key differentiators
```
