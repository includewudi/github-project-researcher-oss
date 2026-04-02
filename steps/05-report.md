# Step 5: Generate RESEARCH.md

Output to `~/.github-researcher/projects/{owner}/{repo}/RESEARCH.md`.

## Template Reference

Choose template based on research mode:

| Mode | Template | Sections |
|------|----------|----------|
| Quick Assessment | `templates/research-quick.md` | Summary + Overview + Verdict |
| Deep Dive | `templates/research-deep.md` | Full report (default) |
| Security Audit | `templates/research-security.md` | Security-focused |

## Butler Contract

The ResearchExecutor expects RESEARCH.md at:
```
~/.github-researcher/projects/{owner}/{repo}/RESEARCH.md
```

The executor scans session messages for this path. **Always print the full path when done.**

## Obsidian Archive Hint

After generating RESEARCH.md, if doc-store is available:
> "Research complete. Archive to Obsidian vault? (y/n)"

Vault path convention: `knowledge-base/research/{owner}/{repo}/RESEARCH.md`

## Verification Checklist

```bash
# Confirm file exists
ls -la ~/.github-researcher/projects/{owner}/{repo}/RESEARCH.md

# Verify no placeholder content
grep -E "TODO|N/A|PLACEHOLDER|TBD" ~/.github-researcher/projects/{owner}/{repo}/RESEARCH.md
```

- [ ] RESEARCH.md at expected path
- [ ] YAML frontmatter with: project, repository_url, researched_at, overall_score
- [ ] All required sections present
- [ ] Scores filled with actual values
- [ ] Verdict explicit: Use / Don't Use / Use with Caution
- [ ] No "TODO" or "N/A" placeholders
