---
project: "{Project Name}"
repository_url: "{url}"
researched_at: "{date}"
overall_score: "{n}/80"
security_posture: "{n}/20"
verdict: "{Use / Don't Use / Use with Caution}"
tags: ["security", "{tag1}", "{tag2}"]
research_mode: "security"
---

# {Project Name} — Security Audit

**Researched:** {date}
**Repository:** {url}
**Local Path:** ~/.github-researcher/projects/{owner}/{repo}

## Executive Summary

{1-2 sentences: overall security posture, critical findings}

## Project Overview

| Metric | Value |
|--------|-------|
| Stars | {count} |
| Forks | {count} |
| Last Commit | {date} |
| Primary Language | {language} |

## Security Posture: {score}/20

| Category | Score | Details |
|----------|-------|---------|
| Supply Chain | {n}/5 | |
| Code Security | {n}/5 | |
| Infrastructure | {n}/5 | |
| AI Agent Safety | {n}/5 | |

**Risk Level:** {Low (16-20) / Medium (10-15) / High (5-9) / Critical (0-4)}

## Code Security Analysis

### Hardcoded Secrets
{Findings or "None detected"}

### Dangerous Patterns (eval/exec)
{Findings or "None detected"}

### Injection Risks
{SQL/command/code injection findings or "None detected"}

### Deserialization Safety
{Findings or "None detected"}

## Dependency Security

{Known CVEs, outdated dependencies, or "No known vulnerabilities detected"}

## AI Agent Safety Assessment

**Agent Config Files Found:** {list or "None"}
**Safety Level:** {Safe / Caution / Unsafe}

| Threat | Found? | Evidence |
|--------|--------|----------|
| T1 Prompt Injection | ✅/❌ | |
| T2 Data Exfiltration | ✅/❌ | |
| T3 Privilege Escalation | ✅/❌ | |
| T4 Supply Chain | ✅/❌ | |
| T5 Incentive Traps | ✅/❌ | |

**Agent Safety Score:** {n}/5

## CI/CD Security Assessment

**Workflows Found:** {count}
**Security Level:** {Secure / Needs Review / Vulnerable}

| Check | Status | Evidence |
|-------|--------|----------|
| C1 pull_request_target | ✅/🔴 | |
| C2 Permission scope | ✅/🟠 | |
| C3 Action pinning | ✅/🟠 | |
| C4 Script injection | ✅/🔴 | |
| C5 Secret exposure | ✅/🟠 | |
| C6 Self-hosted runners | ✅/🟡 | |

**CI/CD Security Score:** {n}/5

## Recommendations

1. {Critical fix if any}
2. {High priority improvement}
3. {Medium priority improvement}

## Verdict

**{Safe to use as skill / Review before use / Do NOT use as skill}**

{Reasoning}
