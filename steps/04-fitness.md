# Step 4: Fitness Evaluation

7-dimension scoring /80 + Security Posture /20. **Every score backed by checklist.**

## Fitness Score (/80)

```
Functionality:      /10
Compatibility:      /10
Maintenance:        /10
Community:          /10
Security Posture:   /20  (see below)
License:            /10
Integration:        /10
─────────────────────────
Total:              /80
```

## Dimension Checklists

### Functionality (/10)
| # | Check | Pts |
|---|-------|-----|
| F1 | Core features match user needs | +3 |
| F2 | API/CLI documentation exists | +2 |
| F3 | Configuration options for customization | +2 |
| F4 | Error messages are actionable | +1 |
| F5 | Backward compatibility maintained | +2 |

### Compatibility (/10)
| # | Check | Pts |
|---|-------|-----|
| P1 | Runs on user's target OS/runtime | +3 |
| P2 | Language version requirements documented | +2 |
| P3 | No conflicting peer dependencies | +2 |
| P4 | Docker/container support available | +1 |
| P5 | Cross-platform CI verified | +2 |

### Maintenance (/10)
| # | Check | Pts |
|---|-------|-----|
| M1 | Last commit within 90 days | +2 |
| M2 | Issues responded to within 14 days | +2 |
| M3 | Changelog or release notes maintained | +2 |
| M4 | CI pipeline exists and passes | +2 |
| M5 | CODEOWNERS or active maintainer list | +2 |

### Community (/10)
| # | Check | Pts |
|---|-------|-----|
| O1 | Stars > 100 (or appropriate for niche) | +2 |
| O2 | Contributors > 5 | +2 |
| O3 | README quality (quick start, examples) | +2 |
| O4 | Discussion forum or Discord/Slack exists | +2 |
| O5 | Stack Overflow tags or community content | +2 |

### License (/10)
| # | Check | Pts |
|---|-------|-----|
| L1 | License file present | +3 |
| L2 | Compatible with user's use case | +3 |
| L3 | No CLA requirement | +2 |
| L4 | Dependencies have compatible licenses | +2 |

### Integration (/10)
| # | Check | Pts |
|---|-------|-----|
| G1 | Install in ≤3 commands | +2 |
| G2 | Working quick-start example | +2 |
| G3 | Programmatic API (not just CLI) | +2 |
| G4 | Plugin/extension system | +2 |
| G5 | TypeScript types / type stubs | +2 |

## Security Posture (/20)

### Supply Chain (0-5)
| # | Check | Verify |
|---|-------|--------|
| S1 | Lockfile exists | `ls package-lock.json yarn.lock Pipfile.lock go.sum` |
| S2 | Dependencies pinned | Check dep file for unpinned ranges |
| S3 | Dependency update tool | `ls .github/dependabot.yml renovate.json` |
| S4 | No binary artifacts | `find . -name "*.exe" -o -name "*.dll" -o -name "*.so"` |
| S5 | Releases signed/provenance | Check release assets |

### Code Security (0-5)
| # | Check | Verify |
|---|-------|--------|
| C1 | No hardcoded secrets | Step 3-security grep results |
| C2 | No dangerous eval/exec | Step 3-security grep results |
| C3 | Input validation present | Check for validation libs |
| C4 | No SQL injection | Step 3-security grep results |
| C5 | Safe deserialization | Step 3-security grep results |

### Infrastructure (0-5)
| # | Check | Verify |
|---|-------|--------|
| I1 | SECURITY.md exists | `ls SECURITY.md .github/SECURITY.md` |
| I2 | Branch protection signals | CODEOWNERS or branch protection |
| I3 | CI has tests | workflow contains test step |
| I4 | SAST tool configured | `ls .github/workflows/codeql*.yml .semgrep.yml` |
| I5 | CI/CD workflows secure | Step 3-security CI/CD score ≥ 4/5 |

### AI Agent Safety (0-5)
| # | Check | Verify |
|---|-------|--------|
| A1-A5 | See steps/03-security.md Agent Safety Score | |

### Risk Levels

| Score | Level | Action |
|-------|-------|--------|
| 16-20 | **Low** | Production-ready |
| 10-15 | **Medium** | Acceptable with known risks |
| 5-9 | **High** | Use with caution, consider alternatives |
| 0-4 | **Critical** | Do NOT use without remediation |

## 4.2 Ecosystem Audit (if claims >5)

```bash
CLAIM_COUNT=$(rg -c "recommend|best practice|should|avoid|prefer|use.*instead|don't use" --include="*.md" --include="*.rst" . 2>/dev/null | awk -F: '{s+=$2} END {print s+0}')
```

| Claims | Action |
|--------|--------|
| < 5 | Skip Step 4.2 |
| 5-15 | Lightweight audit (2-3 librarian agents) |
| > 15 | Full audit (3-6 librarian agents) |

1. Extract claims inventory (priority: High/Medium/Low)
2. Fire parallel librarian agents to check currency
3. Build Modern Replacements table
4. Append as `## Appendix: Modern Replacements` in RESEARCH.md

## 4.5 Domain Fitness (cross-domain)

### Gap Analysis
| Aspect | Native Domain | Target Domain | Gap |
|--------|--------------|---------------|-----|

### Reusability Matrix
| Component | Reusable? | Modification Needed | Effort |
|-----------|-----------|---------------------|--------|

### Strategies
- **A: Wrap & Extend** — use core, replace periphery
- **B: Fork & Modify** — fork and modify internals
- **C: Hybrid** — pick best from multiple projects
- **D: Inspiration Only** — extract patterns, build custom

### Domain Fitness Score (/60)
```
Data Compatibility:     /10
Execution Model:        /10
Latency Profile:        /10
Feature Reusability:    /10
Backtesting Validity:   /10
Community Support:      /10
──────────────────────────
Domain Fitness:         /60
Recommendation: Use As-Is / Adapt / Hybrid / Build Custom
```
