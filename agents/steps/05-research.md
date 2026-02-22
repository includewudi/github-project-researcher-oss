# Step 5: Generate Research Document

> **返回索引:** [SKILL_FULL.md](../../SKILL_FULL.md)

Create `RESEARCH.md` in the cloned directory:

```markdown
---
project: "{Project Name}"
repository_url: "{url}"
researched_at: "{date}"
overall_score: "{n}/80"
security_posture: "{n}/20"
verdict: "{Use / Don't Use / Use with Caution}"
tags: ["{tag1}", "{tag2}"]
---

# {Project Name} Research Report

**Researched:** {date}
**Repository:** {url}
**Local Path:** $CLONE_BASE/{author}/{repo}

## Executive Summary

{1-3 sentence summary of what this project does and key findings}

## Project Overview

| Metric | Value |
|--------|-------|
| Stars | {count} |
| Forks | {count} |
| Last Commit | {date} |
| License | {license} |
| Primary Language | {language} |
| Open Issues | {count} |

## Capabilities

{What this project can do - bullet list}

## Use Cases

{When to use this project}

## Vulnerabilities & Concerns

{Security issues, code quality concerns, or "None found"}

## Security Posture: {score}/20

| Category | Score | Details |
|----------|-------|---------|
| Supply Chain | {n}/5 | {failed checks if any} |
| Code Security | {n}/5 | {failed checks if any} |
| Infrastructure | {n}/5 | {failed checks if any} |
| AI Agent Safety | {n}/5 | {failed checks if any} |

**Risk Level:** {Low (16-20) / Medium (10-15) / High (5-9) / Critical (0-4)}

### AI Agent Safety

{Step 3.3.1 findings — threat categories detected, agent config files found, or "No agent configuration files detected"}

### CI/CD Security

{Step 3.3.2 findings — workflow issues detected, or "No CI/CD security issues found"}

## Fitness Evaluation

{If user specified needs, evaluate against them}

| Dimension | Score | Notes |
|-----------|-------|-------|
| ... | /10 | ... |

## Recommendation

{Clear recommendation: Use / Don't Use / Use with Caution + reasoning}

## Quick Start

{How to get started using this project - extracted from README or synthesized}

## Related Projects

{Similar or complementary projects worth considering}
```

---

## Location

```
$CLONE_BASE/{owner}/{repo}/RESEARCH.md
```
