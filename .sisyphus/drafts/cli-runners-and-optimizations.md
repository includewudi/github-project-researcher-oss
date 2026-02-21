# Draft: CLI runners (gemini/claude) + prioritized optimizations

## Requirements (confirmed)
- Optimize github-project-researcher-oss based on RESEARCH.md report, focused on high-impact improvements only.
- Cover priorities 1/2/3: repository trust/security posture, research output quality, and usability.
- Add guidance to use fast-edit and include OSS link: https://github.com/includewudi/fast-edit
- Add support for Gemini CLI and Claude CLI via a unified prompt interface (user has not run locally; planner should research).
- User: "都选你推荐的做法，后面不用问我了" 
  -> Adopt planner-recommended defaults for remaining choices.

## Technical Decisions (defaults applied)
- Implement a runner abstraction in research.sh: `--runner {opencode|claude|gemini}`.
- Use a single canonical prompt template; allow minimal runner-specific wrappers (flags/system prompt/output mode).
- Acceptance target: generate RESEARCH.md to canonical location `$CLONE_BASE/{owner}/{repo}/RESEARCH.md` for all runners when feasible; otherwise provide fallback capturing runner raw output with explicit marker.
- Prefer wrapper mode (not modifying OpenCode) for Gemini/Claude.

## Scope Boundaries
- INCLUDE:
  - CI quality gate: ShellCheck + bash -n via GitHub Actions (repo trust/security posture).
  - Add Scorecard API usage in skill security evaluation guidance.
  - Strengthen agent safety scan to include Cursor `.cursor/rules/*.mdc`.
  - RESEARCH.md template improvement: YAML front-matter.
  - Ecosystem audit (4.2) gating to avoid waste on code-only projects.
  - Usability improvements: focus modes, session resume, bilingual prompt option.
  - Documentation updates for fast-edit.
- EXCLUDE (for now):
  - Splitting SKILL_FULL.md into subfiles.
  - GraphQL competitor enrichment (defer).
  - Batch mode (defer unless trivial alongside runner refactor).

## Research Findings
- RESEARCH.md (local path): /Users/wudi/data/code/ai_tools/git_tools/github/includewudi/github-project-researcher-oss/RESEARCH.md
  - Technical debts: no tests/CI, no ShellCheck CI, SKILL_FULL single file.
  - Security posture gaps: missing SECURITY.md, branch protection, CI, SAST, Dependabot.
- OpenSSF Scorecard weighting + recommended checks retrieved; suggests using api.scorecard.dev as primary security evidence.

## Open Questions
- Pending: authoritative Gemini CLI + Claude CLI official docs and invocation patterns.
- Pending: pinpoint minimal refactor points in research.sh for runner abstraction and existing OpenCode assumptions in docs.
