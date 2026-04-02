---
name: github-project-researcher
description: Use when researching GitHub projects — analyzing capabilities, architecture, security, fitness (including cross-domain), competitors, cloning to local library, generating RESEARCH.md. Self-evolving through accumulated knowledge.
---

# GitHub Project Researcher

Prompt-only skill for GitHub project research. Analyze, score, compare — output RESEARCH.md.

**Clone base:** `~/.github-researcher/projects/{owner}/{repo}/`
**Butler contract:** RESEARCH.md at `~/.github-researcher/projects/{owner}/{repo}/RESEARCH.md`

---

## What should I do? (Decision Tree)

```
User's request
  │
  ├─ Quick Assessment (5 min)
  │    Steps: 1 → 2 → README scan → verdict
  │    Template: templates/research-quick.md
  │
  ├─ Deep Dive (30 min) ← DEFAULT / Butler mode
  │    Steps: 1 → 2 → 3.0 → 3/3D → 4 → 5 → 6
  │    Template: templates/research-deep.md
  │
  ├─ Security Audit (15 min)
  │    Steps: 1 → 2 → 3-security → 4 (Security Posture only)
  │    Template: templates/research-security.md
  │    Optional: SlowMist enhanced review (Web3/agent/strict mode)
  │
  ├─ Architecture Discovery (20 min)
  │    Steps: 1 → 2 → 3-architecture → document
  │    Template: templates/research-deep.md (Architecture focus)
  │
  ├─ Cross-Domain Eval (25 min)
  │    Steps: 1 → 2 → 3 → 4 → 4.5
  │    Template: templates/research-deep.md + Domain Fitness section
  │
  └─ Competitor Analysis (30 min)
       Steps: 1 → 2 → 3 → 4 → 5 → 7
       Template: templates/research-deep.md + COMPETITORS.md
```

---

## ⚠️ Safety Rules (inline, mandatory)

### Rule 1: TodoList before starting

Create TodoList with all planned steps. Mark `in_progress` before starting each, `completed` immediately after.

### Rule 2: Language auto-detect is MANDATORY

Run language detection before ANY grep. Set `--include` flags based on result. Never hardcode `*.py`.

```bash
find . -type f -not -path './.git/*' -not -path './node_modules/*' -not -path './venv/*' \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -15
```

### Rule 3: Graceful degradation — never retry failed strategy

```
gh auth status
  ├─ ✅ Authenticated → Strategy A (gh CLI)
  ├─ ❌ Not installed/unauth → Strategy B (webfetch) — do NOT retry gh
  └─ ⚠️ Rate limited → Strategy C (curl, 60 req/hr) — do NOT retry gh
```

### Rule 4: Evidence-based — every claim needs data

No fabricated metrics. No "approximately" without actual counts. Every score backed by checklist.

### Rule 5: Large repo / edge case handling

- Repo >100MB → `git clone --depth 1`
- Monorepo → detect workspace config, scope to dominant package
- Archived → 1-paragraph verdict, skip steps 2-7
- Empty repo → minimal RESEARCH.md, skip analysis

---

## Use Case Table

| Pattern | Steps | Time | Template |
|---------|-------|------|----------|
| **Quick Assessment** | 1 → 2 → README → verdict | 5 min | `research-quick.md` |
| **Deep Dive** | Full 1-6 | 30 min | `research-deep.md` |
| **Security Audit** | 1 → 2 → 3-security → scoring | 15 min | `research-security.md` |
| **Architecture Discovery** | 1 → 2 → 3-architecture | 20 min | `research-deep.md` |
| **Cross-Domain Eval** | 1-4 → 4.5 | 25 min | `research-deep.md` |
| **Competitor Analysis** | 1-5 → 7 | 30 min | `research-deep.md` |
| **Ecosystem Audit** | Extract claims → parallel librarians | 15 min | (appendix) |
| **Documentation Project** | 1 → 2 → 3.0 → 3d-docs | 20 min | `research-deep.md` |

---

## Workflow Overview

```
1. Fetch Info → 2. Clone → 3.0 Type Gate
                                ↓
                    ┌───────────┴───────────┐
                    ↓                       ↓
              3d-docs Analysis      3-analysis
              ├─ IA mapping         ├─ 3.1 Structure
              ├─ Build pipeline     ├─ 3.2 Dependencies
              ├─ Coverage           ├─ 3.4 Quality
              └─ Writing quality    └─ 3.4.1 AI detection
                    └───────────┬───────────┘
                                ↓
              3-security ──── 3-architecture
                  ↓               ↓
              4. Fitness (/80 + Security /20)
              4.2 Ecosystem (if claims >5)
              4.5 Domain Fitness (if cross-domain)
                  ↓
              5. Generate RESEARCH.md → 6. Update KB → 7. Competitors
```

---

## When to Open Sub-Documents

| File | Open When |
|------|-----------|
| `steps/01-fetch.md` | Starting any research — strategy selection |
| `steps/02-clone.md` | After fetch — clone + edge cases |
| `steps/03-type-gate.md` | After clone — route to code vs docs |
| `steps/03-analysis.md` | Code project — structure, deps, quality |
| `steps/03d-docs.md` | Docs project — IA, build, coverage |
| `steps/03-security.md` | Security audit or code analysis; includes SlowMist escalation triggers |
| `steps/03-architecture.md` | Complex project — patterns, hierarchy |
| `steps/04-fitness.md` | Before evaluation — scoring checklists |
| `steps/05-report.md` | Writing RESEARCH.md — template reference |
| `steps/06-kb.md` | After report — KB update rules |
| `steps/07-competitors.md` | Competitor analysis requested |
| `templates/research-quick.md` | Quick assessment output |
| `templates/research-deep.md` | Full deep dive output |
| `templates/research-security.md` | Security audit output |
| `templates/kb-entry.md` | Per-project KB entry format |

---

## Edge Cases

| Case | Action |
|------|--------|
| **Private repo** | Requires `gh auth login` — Strategy B/C cannot access |
| **Archived repo** | 1-paragraph verdict, skip steps 2-7 |
| **Empty repo** | Minimal RESEARCH.md, skip analysis |
| **Monorepo** | Detect workspace config, scope to dominant package |
| **No README** | Use description + topics from gh/webfetch |
| **Binary-heavy** | Focus on config/build files, note limited analysis |
| **All strategies fail** | Report errors, ask user to verify `gh auth login` |

---

## Verification Checklist (after Step 5)

- [ ] RESEARCH.md exists at `~/.github-researcher/projects/{owner}/{repo}/RESEARCH.md`
- [ ] YAML frontmatter present with: project, repository_url, researched_at, overall_score
- [ ] All required sections present (Executive Summary through Recommendation)
- [ ] Scores filled with actual values (no "TODO" or "N/A" placeholders)
- [ ] Security Posture score present (/20 with category breakdown)
- [ ] Verdict is explicit: Use / Don't Use / Use with Caution
- [ ] Local path referenced correctly
