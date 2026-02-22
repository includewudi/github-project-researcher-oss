# Step 1: Fetch Project Info

> **返回索引:** [SKILL_FULL.md](../../SKILL_FULL.md)

This step was evolved from researching Skill_Seekers where `gh` CLI was unauthenticated, requiring graceful fallback.

---

## 1.0 Tool Availability Check (MANDATORY)

Before fetching, detect which tools are available:

```bash
# Check gh CLI authentication
gh auth status 2>&1
```

**Decision Flow:**

| `gh auth status` Result | Strategy |
|--------------------------|----------|
| ✅ Authenticated | Use **Strategy A** (gh CLI) — fastest, richest data |
| ❌ Not authenticated / not installed | Use **Strategy B** (webfetch + GitHub web) |
| ⚠️ Rate limited | Use **Strategy C** (curl to public API, no auth) |

> **CRITICAL:** Do NOT proceed with `gh` commands if auth check fails. Every failed command wastes time and produces confusing error output. Switch strategy IMMEDIATELY.

---

## Strategy A: gh CLI (Preferred)

```bash
# Get repo metadata
gh repo view {owner}/{repo} --json name,description,url,stargazerCount,forkCount,issues,pullRequests,latestRelease,licenseInfo,primaryLanguage,languages,repositoryTopics,isArchived

# Archived repo short-circuit
# If isArchived is true, produce a 1-paragraph verdict and skip Steps 2-7:
#   "ARCHIVED: {owner}/{repo} — archived on {date}. Last commit: {date}. Stars: {n}. Skip."

# Get README content
gh api repos/{owner}/{repo}/readme --jq '.content' | base64 -d

# Get directory structure
gh api repos/{owner}/{repo}/git/trees/HEAD?recursive=1 --jq '.tree[].path' | head -100

# Get recent commits
gh api repos/{owner}/{repo}/commits --jq '.[0:10] | .[] | {sha: .sha[0:7], message: .commit.message | split("\n")[0], date: .commit.author.date}'

# Get open security advisories (if any)
gh api repos/{owner}/{repo}/security-advisories --jq '.[] | {severity, summary, state}'
```

---

## Strategy B: webfetch Fallback (No Auth)

When `gh` is unavailable, use `webfetch` tool to scrape GitHub web pages:

```
# Fetch repo main page — extracts stars, forks, description, language, license
webfetch(url="https://github.com/{owner}/{repo}", format="text")

# Fetch README — rendered markdown
webfetch(url="https://github.com/{owner}/{repo}/blob/main/README.md", format="markdown")
# If 404, try: /blob/master/README.md

# Fetch directory listing
webfetch(url="https://github.com/{owner}/{repo}/tree/main", format="text")

# Fetch recent commits
webfetch(url="https://github.com/{owner}/{repo}/commits/main", format="text")
```

**Data Mapping (webfetch → same metrics as gh):**

| Metric | Where to Find in webfetch Output |
|--------|----------------------------------|
| Stars | Repo page, near top |
| Forks | Repo page, near top |
| Description | Repo page, first line under title |
| Primary Language | Repo page, language bar |
| License | Repo page, sidebar or file listing |
| Last Commit | Commits page, first entry date |

---

## Strategy C: curl to Public API (Rate Limited Fallback)

```bash
# No auth required, 60 requests/hour limit
curl -s "https://api.github.com/repos/{owner}/{repo}" | jq '{name, description, stargazers_count, forks_count, open_issues_count, license, language, updated_at}'

# Get README
curl -s "https://api.github.com/repos/{owner}/{repo}/readme" | jq -r '.content' | base64 -d

# Get commits
curl -s "https://api.github.com/repos/{owner}/{repo}/commits?per_page=10" | jq '.[].commit | {message: .message | split("\n")[0], date: .author.date}'
```

---

## Extract Key Metrics

| Metric | What to Check |
|--------|---------------|
| Stars/Forks | Popularity and community adoption |
| Issues | Open issue count, response time |
| Last Commit | Active maintenance? |
| License | Compatible with your use case? |
| Dependencies | Dependency count and health |
| isArchived | If true, skip remaining steps |
