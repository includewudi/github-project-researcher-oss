# Plan: CLI runners (Gemini/Claude) + high-impact optimizations for github-project-researcher-oss

## TL;DR

> **Quick Summary**: Evolve `github-project-researcher-oss` with high-impact improvements only: strengthen repo trust/security posture, improve RESEARCH.md output quality, and improve usability. Add new `research.sh --runner {opencode|claude|gemini}` to remove hard dependency on OpenCode Server.
>
> **Deliverables**:
> - `research.sh` supports three runners (OpenCode Server, Claude CLI, Gemini CLI) with unified prompt + machine-parseable output.
> - Add CI quality gate (ShellCheck + bash syntax) + optional Scorecard audit step guidance.
> - Update skill docs/templates: Scorecard evidence, Cursor `.mdc` safety scan coverage, RESEARCH.md YAML front-matter, Ecosystem Audit gate.
> - Docs: demote server requirement where applicable, document `--runner`, and recommend `fast-edit` (OSS link).
>
> **Estimated Effort**: Medium
> **Parallel Execution**: YES — 4 waves + final verification
> **Critical Path**: Runner abstraction + docs alignment → CI gate → template/scoring updates → final QA

---

## Context

### Original Request
- Use existing research report (`RESEARCH.md`) to select optimizations that matter; exclude trivial/unimportant work.
- Cover priorities (1) repo trust/security posture, (2) output quality, (3) usability.
- Add Gemini CLI + Claude CLI support using a unified prompt.
- Include fast-edit OSS link (https://github.com/includewudi/fast-edit).
- User: “都选你推荐的做法，后面不用问我了” — apply planner defaults and proceed without further product questions.

### Key Evidence
- Local research report for this repo (generated externally):
  - `/Users/wudi/data/code/ai_tools/git_tools/github/includewudi/github-project-researcher-oss/RESEARCH.md`
  - Identified debts: no tests/CI, no ShellCheck CI, missing SECURITY.md guidance, SKILL_FULL large single-file.
- OpenSSF Scorecard API + weights: `https://api.scorecard.dev/projects/github.com/{owner}/{repo}`
- Gemini CLI official:
  - Repo: https://github.com/google-gemini/gemini-cli
  - Install: `npm i -g @google/gemini-cli` or `brew install gemini-cli`
  - `--output-format json` extracts `.response`; exit codes include 0/1/42/53.
- Claude CLI official:
  - Docs: https://docs.anthropic.com/en/docs/claude-code/cli-reference
  - Print mode: `claude -p --output-format json ...` extracts `.result`; exit codes 0/1/2.

### Metis Review (applied)
- Confirmed Gemini/Claude CLI are viable; both support headless `-p`/print mode and JSON output.
- Identified tool-permission gotchas:
  - Claude: avoid hanging permission prompts by **disabling tools** (`--tools ""`) OR use `--dangerously-skip-permissions`.
  - Gemini: default policy may drop tool usage; since we only need text output, keep it text-only (no tools).
- Confirmed required parsing asymmetry: Claude JSON field `.result`; Gemini JSON field `.response`.
- Noted docs inconsistencies: `agents/workflow.md` already mentions `.mdc` but `SKILL_FULL.md` lags.

---

## Work Objectives

### Core Objective
Support three execution backends for the same research workflow, while improving repo trust/security posture, output quality, and usability—without scope creep.

### Concrete Deliverables
- `research.sh`
  - `--runner opencode|claude|gemini`
  - Runner-specific preflight checks (binary presence + auth hints)
  - JSON output parsing to extract the assistant result text robustly
  - Preserve existing async behavior for OpenCode server runner
- GitHub Actions CI
  - ShellCheck + bash syntax check on PR and push
- Skill docs improvements to ensure output is:
  - More verifiable (Scorecard evidence)
  - More complete (Cursor `.mdc` scan)
  - More machine-usable (YAML front-matter)
  - Less wasteful (Ecosystem Audit gating)
- Documentation that references fast-edit OSS:
  - https://github.com/includewudi/fast-edit

### Must NOT Have (Guardrails)
- Do NOT split `SKILL_FULL.md` into subfiles in this iteration.
- Do NOT implement GraphQL competitor enrichment.
- Do NOT add batch mode unless it becomes necessary for runner work (keep out of scope).
- Do NOT require local interactive OAuth flows for CI; runner must support env var auth guidance.

---

## Verification Strategy (MANDATORY)

> **ZERO HUMAN INTERVENTION** — All verification is agent-executed.

### Test Decision
- **Infrastructure exists**: NO (no tests currently)
- **Automated tests**: Tests-after (lightweight) — add minimal smoke tests as bash scripts or simple harness if needed.
- **Primary Verification**: Agent-executed QA scenarios using Bash. CI smoke validates linting.

### QA Policy
Every task includes QA scenarios with concrete commands and evidence capture.
Evidence saved to `.sisyphus/evidence/`.

---

## Execution Strategy

### Parallel Execution Waves

Wave 1 (Start immediately — runner foundation + CI skeleton)
- Task 1: Add runner flag + runner dispatch skeleton in `research.sh`
- Task 2: Add CI workflow for ShellCheck + bash -n
- Task 3: Doc updates foundations: add `--runner` to CLI reference + demote server requirement language (README/AGENTS)
- Task 4: Add fast-edit recommendation (AGENTS + skill-dev guide)

Wave 2 (Runner implementations — parallel backends)
- Task 5: Implement Gemini runner (headless JSON output + parsing + auth checks)
- Task 6: Implement Claude runner (print JSON output + parsing + tool restriction)
- Task 7: Harden result extraction + output path detection (cross-runner)
- Task 8: Update cleanup/abort semantics per runner (avoid server abort if not server)

Wave 3 (Output quality + security posture improvements)
- Task 9: Add Scorecard API step and rubric guidance to `SKILL_FULL.md`
- Task 10: Fix `.mdc` scan mismatch in `SKILL_FULL.md` (sync with `agents/workflow.md`)
- Task 11: Add YAML front-matter to RESEARCH.md template
- Task 12: Add Step 4.2 Ecosystem Audit gating

Wave 4 (Integration + doc polish)
- Task 13: Update `SKILL.md`/`SKILL_FULL.md` “Default Behavior” to runner-agnostic and add examples for each runner
- Task 14: Add minimal self-check mode for non-server runners (`--dry-run` semantics per runner)
- Task 15: Release/readme validation + link checks

---

## TODOs

- [ ] 1. Add `--runner` interface + skeleton dispatch in `research.sh`

  **What to do**:
  - Add `--runner {opencode|claude|gemini}` option (default `opencode`).
  - Refactor prompt construction into `build_prompt()` instead of inline `export RESEARCH_PROMPT=...`.
  - Create runner-dispatch entry point (e.g., `run_with_runner()` that calls the appropriate runner function).
  - Keep existing server runner code behavior intact for now; just route through the dispatch.

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 2-4)
  - **Blocks**: Tasks 5-8
  - **Blocked By**: None

  **References**:
  - `research.sh:341-349` — current `RESEARCH_PROMPT` inline construction.
  - `research.sh:353-375` — `build_payload()` (OpenCode-server envelope).
  - `research.sh:388-563` — async+sync OpenCode server dispatch logic.

  **Acceptance Criteria**:
  - [ ] `./research.sh --help` shows `--runner` with allowed values.
  - [ ] Running `./research.sh --runner opencode --dry-run https://github.com/octocat/Hello-World` behaves exactly as before (server health check only) and exits 0.

  **QA Scenarios**:
  ```
  Scenario: Help output includes runner option
    Tool: Bash
    Steps:
      1. Run: ./research.sh --help | sed -n '1,120p'
      2. Assert output contains: "--runner" and "opencode|claude|gemini"
    Evidence: .sisyphus/evidence/task-1-help-runner.txt

  Scenario: Default runner remains opencode
    Tool: Bash
    Steps:
      1. Run: ./research.sh --dry-run https://github.com/octocat/Hello-World
      2. Assert output indicates server health check path (and no "claude"/"gemini" command checks)
    Evidence: .sisyphus/evidence/task-1-default-runner.txt
  ```

- [ ] 2. Add GitHub Actions CI: ShellCheck + `bash -n`

  **What to do**:
  - Add workflow(s) under `.github/workflows/` that run on `push` and `pull_request`.
  - Steps:
    - Checkout
    - Install shellcheck (or use preinstalled on ubuntu-latest)
    - Run `shellcheck research.sh`
    - Run `bash -n research.sh`
  - Keep it minimal — no matrix needed.

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1,3,4)
  - **Blocks**: Final confidence + future refactors
  - **Blocked By**: None

  **References**:
  - `AGENTS.md` — already documents `shellcheck research.sh` and `bash -n research.sh` commands.

  **Acceptance Criteria**:
  - [ ] Workflow exists and runs those two checks.
  - [ ] Workflow passes on current `main` head.

  **QA Scenarios**:
  ```
  Scenario: CI workflow file present
    Tool: Bash
    Steps:
      1. Run: ls -la .github/workflows/
      2. Assert at least one .yml workflow exists for shellcheck
    Evidence: .sisyphus/evidence/task-2-ci-workflow-ls.txt

  Scenario: Local lint commands succeed
    Tool: Bash
    Steps:
      1. Run: shellcheck research.sh
      2. Run: bash -n research.sh
      3. Assert exit code 0 for both
    Evidence: .sisyphus/evidence/task-2-local-shellcheck.txt
  ```

- [ ] 3. Make docs runner-agnostic: demote OpenCode server requirement + document `--runner`

  **What to do**:
  - Update `README.md` and `README_ZH.md`:
    - Requirements: make OpenCode server mode required only for `--runner opencode`.
    - Add examples for `--runner claude` and `--runner gemini` (install/auth pointers only; no fake claims).
  - Update `AGENTS.md` and `agents/bash-style.md` examples that hardcode server constructs (PORT/BASE_URL/session abort) to be conditional or runner-scoped.
  - Update `SKILL.md` and `SKILL_FULL.md` sections `Default Behavior` + `CLI Reference` to include `--runner`.

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1,2,4)
  - **Blocks**: usability + correct future contributions
  - **Blocked By**: None

  **References**:
  - `README.md:Requirements` — currently hard-requires `opencode serve`.
  - `AGENTS.md` — describes `research.sh` as server-only.
  - `agents/bash-style.md` — contains server-only examples (PORT/BASE_URL/abort).
  - Explore report: server assumptions list (bg_79a0149d).

  **Acceptance Criteria**:
  - [ ] Docs clearly state three runners and their dependencies.
  - [ ] No text claims that OpenCode server is required for all usage.

  **QA Scenarios**:
  ```
  Scenario: README mentions all runners
    Tool: Bash
    Steps:
      1. Run: rg "--runner" -n README.md README_ZH.md AGENTS.md SKILL.md SKILL_FULL.md
      2. Assert results include all five files
    Evidence: .sisyphus/evidence/task-3-rg-runner-docs.txt

  Scenario: Requirements section demotes server requirement
    Tool: Bash
    Steps:
      1. Run: rg -n "server mode|opencode serve" README.md
      2. Assert wording indicates conditional requirement (runner opencode only)
    Evidence: .sisyphus/evidence/task-3-readme-requirements.txt
  ```

- [ ] 4. Mention and recommend `fast-edit` for large-file edits

  **What to do**:
  - Add a short section in `AGENTS.md` and `agents/skill-dev.md` recommending fast-edit for large/batch changes.
  - Include the OSS link exactly: https://github.com/includewudi/fast-edit
  - Be explicit: “Prefer fast-edit for SKILL_FULL.md / workflow.md large edits.”

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: none

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1 (with Tasks 1-3)
  - **Blocks**: None
  - **Blocked By**: None

  **Acceptance Criteria**:
  - [ ] fast-edit link appears in both files.

  **QA Scenarios**:
  ```
  Scenario: fast-edit link present
    Tool: Bash
    Steps:
      1. Run: rg -n "https://github.com/includewudi/fast-edit" AGENTS.md agents/skill-dev.md
      2. Assert 2 matches (one per file)
    Evidence: .sisyphus/evidence/task-4-fast-edit-link.txt
  ```

- [ ] 5. Implement Gemini runner (headless JSON + parsing)

  **What to do**:
  - Add `run_with_gemini()` implementation using:
    - `gemini --output-format json --model ... "${PROMPT}"` (stdin may be used as context)
  - Parse `.response` from JSON (prefer jq; fallback to python3).
  - Preflight:
    - `command -v gemini`
    - auth hints: `GEMINI_API_KEY` or `GOOGLE_APPLICATION_CREDENTIALS` or cached OAuth.
  - Do **not** rely on Gemini tool-use features; treat as text-in/text-out.

  **Recommended Agent Profile**:
  - **Category**: `quick`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 6)
  - **Blocks**: Task 7
  - **Blocked By**: Task 1

  **References**:
  - Gemini CLI docs: https://geminicli.com/docs
  - Gemini CLI repo: https://github.com/google-gemini/gemini-cli
  - JSON output: `.response` field (official docs)

  **Acceptance Criteria**:
  - [ ] `./research.sh --runner gemini --dry-run https://github.com/octocat/Hello-World` succeeds without contacting OpenCode server.
  - [ ] When GEMINI_API_KEY is missing, script prints actionable guidance and exits non-zero (or warns clearly if using cached OAuth is acceptable per design).

  **QA Scenarios**:
  ```
  Scenario: Gemini runner preflight detects missing binary
    Tool: Bash
    Steps:
      1. Temporarily mask PATH in subshell: PATH="" ./research.sh --runner gemini --dry-run https://github.com/octocat/Hello-World
      2. Assert error message includes "gemini CLI not found" and install hint "npm install -g @google/gemini-cli"
    Evidence: .sisyphus/evidence/task-5-gemini-missing-binary.txt

  Scenario: Gemini runner uses JSON output mode
    Tool: Bash
    Steps:
      1. Run: ./research.sh --runner gemini --help
      2. Assert docs mention `--output-format json` parsing behavior
    Evidence: .sisyphus/evidence/task-5-gemini-json-mode.txt
  ```

- [ ] 6. Implement Claude runner (print JSON + parsing + tool restriction)

  **What to do**:
  - Add `run_with_claude()` implementation using print mode:
    - `claude -p --output-format json ...`
  - Parse `.result` from JSON.
  - Avoid permission hangs by disabling tools (preferred): `--tools ""`.
    - Alternative: `--dangerously-skip-permissions` (document why not default).
  - Preflight:
    - `command -v claude`
    - auth hint: `ANTHROPIC_API_KEY` (OAuth is interactive and not suitable for CI).

  **Recommended Agent Profile**:
  - **Category**: `quick`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 2 (with Task 5)
  - **Blocks**: Task 7
  - **Blocked By**: Task 1

  **References**:
  - Claude CLI reference: https://docs.anthropic.com/en/docs/claude-code/cli-reference
  - Output JSON shape contains `.result`.

  **Acceptance Criteria**:
  - [ ] `./research.sh --runner claude --dry-run https://github.com/octocat/Hello-World` succeeds without contacting OpenCode server.
  - [ ] Claude runner runs with tools disabled by default and does not block on permission prompts.

  **QA Scenarios**:
  ```
  Scenario: Claude runner preflight detects missing binary
    Tool: Bash
    Steps:
      1. Run in subshell with PATH="": PATH="" ./research.sh --runner claude --dry-run https://github.com/octocat/Hello-World
      2. Assert error message includes "claude CLI not found" and install hint URL (claude.ai/install.sh)
    Evidence: .sisyphus/evidence/task-6-claude-missing-binary.txt

  Scenario: Claude runner uses JSON output mode and parses .result
    Tool: Bash
    Steps:
      1. Run: ./research.sh --runner claude --help
      2. Assert help mentions JSON parsing of `.result`
    Evidence: .sisyphus/evidence/task-6-claude-json-parse.txt
  ```

- [ ] 7. Harden cross-runner result capture and output path detection

  **What to do**:
  - Unify how the script captures the model output in a file (e.g., a temp JSON + extracted text file).
  - Ensure `RESEARCH.md` path detection works for:
    - OpenCode server runner (existing behavior, but add fallback).
    - CLI runners: if they output only text, rely on known canonical path `$CLONE_BASE/$OWNER/$REPO/RESEARCH.md`.
  - Make stderr/noise non-fatal; parse stdout only.

  **Recommended Agent Profile**:
  - **Category**: `deep`

  **Parallelization**:
  - **Can Run In Parallel**: NO (integration)
  - **Parallel Group**: Wave 2 (after 5 & 6)
  - **Blocks**: Tasks 13-15
  - **Blocked By**: Tasks 5, 6

  **References**:
  - `research.sh:577-595` — current regex extraction for RESEARCH.md path.
  - Multi-LLM wrapper patterns: https://github.com/simonmysun/ell (PIPESTATUS + dispatch)

  **Acceptance Criteria**:
  - [ ] If path regex extraction fails, script checks canonical path and prints it if present.
  - [ ] Script exits non-zero with clear message when neither extracted path nor canonical path exists.

  **QA Scenarios**:
  ```
  Scenario: Path extraction fallback triggers
    Tool: Bash
    Preconditions: Create a dummy RESEARCH.md at expected canonical path for a test repo clone folder.
    Steps:
      1. Run: ./research.sh --runner opencode --dry-run https://github.com/octocat/Hello-World
      2. Simulate missing regex output path (by setting a flag/mocking) and confirm fallback checks canonical path
    Evidence: .sisyphus/evidence/task-7-path-fallback.txt

  Scenario: Error when no RESEARCH.md found
    Tool: Bash
    Steps:
      1. Run: ./research.sh --runner gemini https://github.com/octocat/Hello-World --timeout 1
      2. Assert message explains expected canonical RESEARCH.md location
    Evidence: .sisyphus/evidence/task-7-no-research-md.txt
  ```

- [ ] 8. Update cleanup/abort + dry-run semantics per runner

  **What to do**:
  - Ensure `cleanup()` only calls server abort endpoint for `RUNNER=opencode` and when `SESSION_ID` is set.
  - For CLI runners, cleanup should not attempt network abort.
  - Implement `--dry-run` semantics:
    - opencode: server health check only (existing)
    - claude/gemini: binary presence + show detected auth method hints; do not execute prompts.

  **Recommended Agent Profile**:
  - **Category**: `quick`

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on runner functions existing)
  - **Parallel Group**: Wave 2 (after Tasks 5-7)
  - **Blocks**: Task 14
  - **Blocked By**: Tasks 1, 5, 6, 7

  **References**:
  - `research.sh:379-386` — current trap cleanup abort call.
  - Claude docs: `--no-session-persistence`, `--output-format json`.
  - Gemini docs: `--output-format json`.

  **Acceptance Criteria**:
  - [ ] `--dry-run` never contacts OpenCode server when runner != opencode.
  - [ ] Ctrl+C does not attempt `/abort` for non-server runners.

  **QA Scenarios**:
  ```
  Scenario: Dry-run for CLI runner avoids network
    Tool: Bash
    Steps:
      1. Run: ./research.sh --runner claude --dry-run https://github.com/octocat/Hello-World
      2. Assert output contains only preflight checks, no BASE_URL/health strings
    Evidence: .sisyphus/evidence/task-8-dry-run-non-network.txt

  Scenario: Cleanup does not abort in CLI runner
    Tool: Bash
    Steps:
      1. Run: RUNNER=gemini ./research.sh --runner gemini --timeout 1 https://github.com/octocat/Hello-World || true
      2. Assert no attempt to call /session/.../abort in logs
    Evidence: .sisyphus/evidence/task-8-cleanup-no-abort.txt
  ```

- [ ] 9. Add Scorecard API-based security evidence to the workflow

  **What to do**:
  - In `SKILL_FULL.md`, add a sub-step to query Scorecard API:
    - `https://api.scorecard.dev/projects/github.com/{owner}/{repo}`
  - If available, embed:
    - aggregate score
    - top failing CRITICAL/HIGH checks
    - remediation notes (e.g., Dangerous-Workflow, Token-Permissions, Dependency-Update-Tool).
  - If not available, fallback to existing local checklist.
  - Keep the existing Security Posture /20 rubric, but add “external evidence” section.

  **Recommended Agent Profile**:
  - **Category**: `writing`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 10-12)
  - **Blocks**: Task 13
  - **Blocked By**: None

  **References**:
  - OpenSSF Scorecard checks: https://github.com/ossf/scorecard/blob/main/docs/checks.md
  - Scorecard API endpoint: https://api.scorecard.dev/

  **Acceptance Criteria**:
  - [ ] SKILL_FULL.md includes explicit Scorecard API query + how to interpret results.

  **QA Scenarios**:
  ```
  Scenario: Scorecard API mention present
    Tool: Bash
    Steps:
      1. Run: rg -n "api.scorecard.dev" SKILL_FULL.md
      2. Assert at least 1 match in the security/fitness sections
    Evidence: .sisyphus/evidence/task-9-scorecard-rg.txt
  ```

- [ ] 10. Fix `.cursor/rules/*.mdc` scanning in `SKILL_FULL.md`

  **What to do**:
  - Ensure Step 3.3.1 scans `.cursor/rules/*.mdc` and `copilot-instructions.md` alongside existing files.
  - Sync exact patterns with `agents/workflow.md` (which already references `.mdc`).

  **Recommended Agent Profile**:
  - **Category**: `quick`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3 (with Tasks 9,11,12)
  - **Blocks**: None
  - **Blocked By**: None

  **References**:
  - `agents/workflow.md` — already mentions `.mdc` scanning.
  - `SKILL_FULL.md` Step 3.3.1 — missing `.mdc` patterns.

  **Acceptance Criteria**:
  - [ ] `SKILL_FULL.md` includes `.cursor/rules/*.mdc` and `copilot-instructions.md` in the scan list.

  **QA Scenarios**:
  ```
  Scenario: .mdc patterns exist in SKILL_FULL.md
    Tool: Bash
    Steps:
      1. Run: rg -n "\\.cursor/rules/\\*\\.mdc" SKILL_FULL.md
      2. Assert at least 1 match
    Evidence: .sisyphus/evidence/task-10-mdc-rg.txt
  ```

- [ ] 11. Add YAML front-matter to the RESEARCH.md template

  **What to do**:
  - Add a YAML block at the start of Step 5 template:
    - project, repository_url, researched_at, overall_score, security_posture, verdict, tags.
  - Keep the rest of markdown template unchanged.

  **Recommended Agent Profile**:
  - **Category**: `writing`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: potential future aggregation tooling
  - **Blocked By**: None

  **References**:
  - `SKILL_FULL.md` Step 5 template section.

  **Acceptance Criteria**:
  - [ ] YAML front-matter appears in the template and uses concrete keys.

  **QA Scenarios**:
  ```
  Scenario: YAML front-matter present
    Tool: Bash
    Steps:
      1. Run: rg -n "^---$" SKILL_FULL.md
      2. Assert matches occur near Step 5 template section (not accidental elsewhere)
    Evidence: .sisyphus/evidence/task-11-yaml-frontmatter.txt
  ```

- [ ] 12. Add Step 4.2 Ecosystem Audit gating (skip when no claims)

  **What to do**:
  - Add a Step 4.2.0 gate:
    - Identify claim-bearing text in README/docs.
    - If fewer than a threshold (e.g., <5), skip ecosystem audit to avoid wasted librarian work.
  - Clarify applicability: docs-heavy or claim-heavy projects.

  **Recommended Agent Profile**:
  - **Category**: `writing`

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 3
  - **Blocks**: Faster runs with `--focus`
  - **Blocked By**: None

  **References**:
  - `SKILL_FULL.md` Step 4.2.

  **Acceptance Criteria**:
  - [ ] Step 4.2 gate exists and defines the skip rule.

  **QA Scenarios**:
  ```
  Scenario: Gate section exists
    Tool: Bash
    Steps:
      1. Run: rg -n "Step 4\\.2\\.0" SKILL_FULL.md
      2. Assert at least 1 match
    Evidence: .sisyphus/evidence/task-12-ecosystem-gate.txt
  ```

- [ ] 13. Update skill docs “Default Behavior” to include runner examples

  **What to do**:
  - In `SKILL.md` and `SKILL_FULL.md`, update “Default Behavior” and “CLI Reference” sections:
    - Include `--runner` option
    - Provide minimal examples for each runner
    - Keep the “prompt-only skill” usage examples

  **Recommended Agent Profile**:
  - **Category**: `writing`

  **Parallelization**:
  - **Can Run In Parallel**: NO (depends on tasks 1-12 sources being correct)
  - **Parallel Group**: Wave 4
  - **Blocked By**: Tasks 3,9-12

  **Acceptance Criteria**:
  - [ ] docs match actual research.sh options.

  **QA Scenarios**:
  ```
  Scenario: CLI reference updated
    Tool: Bash
    Steps:
      1. Run: rg -n "--runner" SKILL.md SKILL_FULL.md
      2. Assert both files include runner option
    Evidence: .sisyphus/evidence/task-13-runner-in-skill-docs.txt
  ```

- [ ] 14. Implement per-runner `--dry-run` semantics + self-check output

  **What to do**:
  - Ensure `--dry-run`:
    - opencode: validates server
    - gemini/claude: validates binary + prints detected auth env strategy
  - Ensure consistent exit codes and messaging.

  **Recommended Agent Profile**:
  - **Category**: `quick`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 4
  - **Blocked By**: Tasks 5,6,8

  **Acceptance Criteria**:
  - [ ] `--dry-run` behaves correctly for each runner.

  **QA Scenarios**:
  ```
  Scenario: Dry-run output differs per runner
    Tool: Bash
    Steps:
      1. Run: ./research.sh --runner opencode --dry-run https://github.com/octocat/Hello-World
      2. Run: ./research.sh --runner gemini --dry-run https://github.com/octocat/Hello-World || true
      3. Run: ./research.sh --runner claude --dry-run https://github.com/octocat/Hello-World || true
      4. Assert opencode mentions /global/health; others mention binaries and API key env vars
    Evidence: .sisyphus/evidence/task-14-dry-run-matrix.txt
  ```

- [ ] 15. Readme/link consistency + terminology cleanup

  **What to do**:
  - Ensure all references to OpenCode, Gemini CLI, Claude CLI, and fast-edit are correct and consistent.
  - Ensure install instructions do not claim unverified behavior.
  - Ensure `research.sh` usage examples are aligned with supported runners.

  **Recommended Agent Profile**:
  - **Category**: `writing`

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 4 final
  - **Blocked By**: Tasks 3,13,14

  **Acceptance Criteria**:
  - [ ] `rg "anthropics/opencode"` returns 0 matches.
  - [ ] `rg "includewudi/github-project-researcher-oss"` appears only where intended.

  **QA Scenarios**:
  ```
  Scenario: Link checks via ripgrep
    Tool: Bash
    Steps:
      1. Run: rg -n "anthropics/opencode" -S . || true
      2. Run: rg -n "anomalyco/opencode" README.md README_ZH.md SKILL.md SKILL_FULL.md AGENTS.md
      3. Assert first command returns no matches; second returns at least 1
    Evidence: .sisyphus/evidence/task-15-link-sanity.txt
  ```

---

## Final Verification Wave

- F1. Plan Compliance Audit (oracle): confirm deliverables exist, guardrails held.
- F2. Script Quality Review (unspecified-high): run ShellCheck locally + ensure CI matches.
- F3. Runner Smoke QA (unspecified-high): run QA scenarios for each runner path using stubs (command presence checks), and server runner dry-run.
- F4. Docs Consistency Check (deep): ensure all references to server are conditional; ensure fast-edit link present.

---

## Commit Strategy
- Commit per wave:
  - `feat(cli): add runner abstraction (opencode/claude/gemini)`
  - `ci: add shellcheck + bash syntax workflow`
  - `docs(skill): improve security evidence + templates`

---

## Success Criteria
- [ ] `research.sh --help` documents `--runner` and runner-specific requirements.
- [ ] In server mode, existing behavior preserved (`--async`, `--log`, `--verbose`, `--port`).
- [ ] In claude/gemini runner modes, script runs headlessly and extracts result text from JSON output.
- [ ] CI runs ShellCheck + bash -n on PRs and pushes.
- [ ] Skill docs and templates updated: Scorecard API guidance, `.mdc` scan coverage, YAML front-matter, Audit gating.
- [ ] fast-edit link present in docs: https://github.com/includewudi/fast-edit
