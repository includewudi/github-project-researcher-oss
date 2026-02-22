# Step 4: Evaluate Fitness

> **返回索引:** [SKILL_FULL.md](../../SKILL_FULL.md)

Compare against user's specific needs:

| Dimension | Questions to Answer |
|-----------|---------------------|
| **Functionality** | Does it do what user needs? |
| **Compatibility** | Language, runtime, OS support? |
| **Maintenance** | Active development? Responsive maintainers? |
| **Community** | Size, activity, documentation quality? |
| **Security Posture** | Quantified security checklist (see below) |
| **License** | Compatible with user's use case? |
| **Integration** | Easy to integrate? Good API? |

---

## Fitness Score

```
Functionality:      /10
Compatibility:      /10
Maintenance:        /10
Community:          /10
Security Posture:   /20  (quantified checklist below)
License:            /10
Integration:        /10
─────────────────────────
Total:              /80
```

---

## Dimension Scoring Anchors

Each non-security dimension uses a binary checklist to reduce subjectivity:

### Functionality (/10)

| # | Check | Points |
|---|-------|--------|
| F1 | Core feature set matches user needs | +3 |
| F2 | API/CLI documentation exists | +2 |
| F3 | Configuration options for customization | +2 |
| F4 | Error messages are actionable | +1 |
| F5 | Backward compatibility maintained | +2 |

### Compatibility (/10)

| # | Check | Points |
|---|-------|--------|
| P1 | Runs on user's target OS/runtime | +3 |
| P2 | Language version requirements documented | +2 |
| P3 | No conflicting peer dependencies | +2 |
| P4 | Docker/container support available | +1 |
| P5 | Cross-platform CI verified | +2 |

### Maintenance (/10)

| # | Check | Points |
|---|-------|--------|
| M1 | Last commit within 90 days | +2 |
| M2 | Issues responded to within 14 days | +2 |
| M3 | Changelog or release notes maintained | +2 |
| M4 | CI pipeline exists and passes | +2 |
| M5 | CODEOWNERS or active maintainer list | +2 |

### Community (/10)

| # | Check | Points |
|---|-------|--------|
| O1 | Stars > 100 (or appropriate for niche) | +2 |
| O2 | Contributors > 5 | +2 |
| O3 | README quality (quick start, examples) | +2 |
| O4 | Discussion forum or Discord/Slack exists | +2 |
| O5 | Stack Overflow tags or community content | +2 |

### License (/10)

| # | Check | Points |
|---|-------|--------|
| L1 | License file present in repo | +3 |
| L2 | License compatible with user's use case | +3 |
| L3 | No CLA requirement for contributions | +2 |
| L4 | Dependencies have compatible licenses | +2 |

### Integration (/10)

| # | Check | Points |
|---|-------|--------|
| G1 | Install in ≤3 commands | +2 |
| G2 | Working quick-start example | +2 |
| G3 | Programmatic API (not just CLI) | +2 |
| G4 | Plugin/extension system | +2 |
| G5 | TypeScript types / type stubs available | +2 |

---

## Security Posture Checklist (/20)

**Replaces the former subjective `Security: /10` with a quantified, evidence-based checklist.**

### Supply Chain Security (0-5)

| # | Check | How to Verify |
|---|-------|---------------|
| S1 | Lockfile exists | `ls package-lock.json yarn.lock Pipfile.lock Cargo.lock go.sum` |
| S2 | Dependencies pinned (not `*` or `latest`) | Check dep file for unpinned ranges |
| S3 | Dependency update tool enabled | `ls .github/dependabot.yml renovate.json` |
| S4 | No binary artifacts in repo | `find . -name "*.exe" -o -name "*.dll" -o -name "*.so"` |
| S5 | Releases signed or provenance available | Check release assets for `.sig`, SLSA provenance |

### Code Security (0-5)

| # | Check | How to Verify |
|---|-------|---------------|
| C1 | No hardcoded secrets found | Step 3.3 secret grep results |
| C2 | No dangerous eval/exec patterns | Step 3.3 eval/exec grep results |
| C3 | Input validation present | Check for validation libs or manual checks |
| C4 | No SQL injection patterns | Step 3.3 SQL injection grep results |
| C5 | Safe deserialization practices | Step 3.3 deserialization grep results |

### Infrastructure Security (0-5)

| # | Check | How to Verify |
|---|-------|---------------|
| I1 | `SECURITY.md` exists | `ls SECURITY.md .github/SECURITY.md` |
| I2 | Branch protection signals | Check for CODEOWNERS or branch protection |
| I3 | CI/CD has tests | `.github/workflows/` contains test step |
| I4 | SAST tool configured | `ls .github/workflows/codeql*.yml .semgrep.yml` |
| I5 | CI/CD workflows secure | Step 3.3.2 CI/CD security score ≥ 4/5 |

### AI Agent Safety (0-5)

| # | Check | How to Verify |
|---|-------|---------------|
| A1 | No agent config files, or configs are benign | Step 3.3.1 results |
| A2 | No data exfiltration patterns in configs | Step 3.3.1 T2 check |
| A3 | No shell execution instructions in configs | Step 3.3.1 T3 check |
| A4 | No supply chain amplification | Step 3.3.1 T4 check |
| A5 | No prompt injection / behavior hijacking | Step 3.3.1 T1 check |

---

## Output in RESEARCH.md

```markdown
## Security Posture: {score}/20

| Category | Score | Details |
|----------|-------|---------|
| Supply Chain | {n}/5 | {failed checks if any} |
| Code Security | {n}/5 | {failed checks if any} |
| Infrastructure | {n}/5 | {failed checks if any} |
| AI Agent Safety | {n}/5 | {failed checks if any} |

**Risk Level:** {Low (16-20) / Medium (10-15) / High (5-9) / Critical (0-4)}
```

> **Interpretation Guide:**
> - **16-20**: Production-ready security posture
> - **10-15**: Acceptable with known risks — document mitigations
> - **5-9**: Significant gaps — use with caution, consider alternatives
> - **0-4**: Do NOT use in production without major remediation

---

## Scorecard API (Optional Enrichment)

When available, supplement with OpenSSF Scorecard data:

```bash
curl -s "https://api.scorecard.dev/projects/github.com/{owner}/{repo}" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(f'Scorecard: {data.get(\"score\", \"N/A\")}/10')
"
```
