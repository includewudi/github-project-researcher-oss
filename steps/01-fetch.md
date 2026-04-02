# Step 1: Fetch Project Info

Detect available tools → pick strategy → collect metadata.

## Tool Availability Check (MANDATORY)

```bash
gh auth status 2>&1
```

| `gh auth status` Result | Strategy |
|--------------------------|----------|
| ✅ Authenticated | **Strategy A** — gh CLI (fastest, richest data) |
| ❌ Not installed/unauth | **Strategy B** — webfetch (no retry gh) |
| ⚠️ Rate limited | **Strategy C** — curl (60 req/hr, no retry gh) |

## Strategy A: gh CLI

```bash
# Repo metadata
gh repo view {owner}/{repo} --json name,description,url,stargazerCount,forkCount,issues,pullRequests,latestRelease,licenseInfo,primaryLanguage,languages,repositoryTopics,isArchived

# Archived? → 1-paragraph verdict, skip steps 2-7

# README
gh api repos/{owner}/{repo}/readme --jq '.content' | base64 -d

# Directory tree
gh api repos/{owner}/{repo}/git/trees/HEAD?recursive=1 --jq '.tree[].path' | head -100

# Recent commits
gh api repos/{owner}/{repo}/commits --jq '.[0:10] | .[] | {sha: .sha[0:7], message: .commit.message | split("\n")[0], date: .commit.author.date}'

# Security advisories
gh api repos/{owner}/{repo}/security-advisories --jq '.[] | {severity, summary, state}'
```

## Strategy B: webfetch

```
webfetch(url="https://github.com/{owner}/{repo}", format="text")
webfetch(url="https://github.com/{owner}/{repo}/blob/main/README.md", format="markdown")
# 404? Try /blob/master/README.md
webfetch(url="https://github.com/{owner}/{repo}/tree/main", format="text")
webfetch(url="https://github.com/{owner}/{repo}/commits/main", format="text")
```

| Metric | Where in webfetch Output |
|--------|--------------------------|
| Stars, Forks, Description | Repo page, near top |
| Primary Language | Language bar |
| License | Sidebar |
| Last Commit | Commits page, first entry |

## Strategy C: curl (public API, no auth)

```bash
curl -s "https://api.github.com/repos/{owner}/{repo}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'Stars: {d[\"stargazers_count\"]}, Forks: {d[\"forks_count\"]}, Language: {d[\"language\"]}')"
curl -s "https://api.github.com/repos/{owner}/{repo}/readme" | python3 -c "import sys,json,base64; print(base64.b64decode(json.load(sys.stdin)['content']).decode())"
```

## Extract Key Metrics

| Metric | Why It Matters |
|--------|---------------|
| Stars/Forks | Popularity and community adoption |
| Last Commit | Active maintenance? |
| License | Compatible with user's use case? |
| isArchived | If true → skip remaining steps |
