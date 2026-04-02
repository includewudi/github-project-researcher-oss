# Step 3: Security Analysis

All security checks in one file. **Adapt `--include` flags to detected language.**

## Language-Specific Grep

### Python
```bash
grep -r "password\|secret\|api_key\|token" --include="*.py" --include="*.env*" . 2>/dev/null | grep -v "node_modules\|.git" | head -20
grep -r "eval\|exec\|subprocess.call\|os.system" --include="*.py" . 2>/dev/null | grep -v ".git"
grep -r "execute.*%s\|execute.*format\|execute.*f\"" --include="*.py" . 2>/dev/null
grep -r "pickle.load\|yaml.load\|eval\(.*input" --include="*.py" . 2>/dev/null
```

### JavaScript/TypeScript
```bash
grep -r "password\|secret\|api_key\|token" --include="*.js" --include="*.ts" . 2>/dev/null | grep -v "node_modules\|.git\|dist" | head -20
grep -r "eval(\|new Function(\|child_process" --include="*.js" --include="*.ts" . 2>/dev/null | grep -v "node_modules"
grep -r "__proto__\|constructor\[" --include="*.js" --include="*.ts" . 2>/dev/null | grep -v "node_modules"
```

### Go
```bash
grep -r "password\|secret\|apiKey\|token" --include="*.go" . 2>/dev/null | grep -v ".git\|vendor" | head -20
grep -r "exec.Command\|os/exec" --include="*.go" . 2>/dev/null | grep -v ".git"
```

### Rust
```bash
grep -r "unsafe\s*{" --include="*.rs" . 2>/dev/null | grep -v ".git\|target" | head -20
grep -r "\.unwrap()" --include="*.rs" . 2>/dev/null | grep -v ".git\|target" | wc -l
```

> **Other languages:** Adapt patterns. Focus on: secrets, eval/exec, SQL injection, deserialization.

## Comprehensive Red Flag Scan (11 patterns) — each 🔴 = -1, 🟡 = -0.5, from 5, floor 0
- 🔴 Data Exfil: curl/wget/fetch + external domain
- 🔴 Credential: process.env, .env, os.environ, keychain
- 🔴 FS Beyond Scope: ~/.ssh, ~/.aws, /etc/shadow, ~/.config
- 🔴 Agent Identity: MEMORY.md, USER.md, AGENTS.md, paired.json
- 🔴 Dynamic Exec: eval(), exec(), Function(), subprocess
- 🔴 Privilege Escalation: sudo, chmod 777, setuid, /etc/sudoers
- 🔴 Persistence: crontab, ~/.bashrc, launchd, systemd
- 🔴 Runtime Install: npm/pip/cargo install, curl|sh
- 🔴 Obfuscation: base64 decode+exec, minified
- 🟡→🔴 System Recon: /proc/PID/environ, ss, netstat, lsof
- 🔴 Browser Session: document.cookie, localStorage, Cookies DB

## 3.3.1 AI Agent Safety

Evolved from SkillScan study (arXiv:2601.10338): 26.1% of 42,447 agent skills contain vulnerabilities.

### Detect Agent Configs
```bash
ls -la AGENTS.md CLAUDE.md .cursorrules .cursor/ .cursor/rules/*.mdc .aider* .continue/ .github/copilot-instructions.md 2>/dev/null
find . -name "mcp*.json" -o -name ".mcp*" 2>/dev/null | grep -v node_modules
```

### Threat Analysis (if configs found)
```bash
# T1: Prompt Injection
grep -iE "ignore previous|ignore above|you are now|new role|disregard|override|forget your" AGENTS.md CLAUDE.md .cursorrules 2>/dev/null

# T2: Data Exfiltration
grep -iE "curl.*http|fetch\(|requests\.(post|get)|wget |nc |base64|exfil|send.*to.*server" AGENTS.md CLAUDE.md .cursorrules 2>/dev/null

# T3: Privilege Escalation
grep -iE "sudo|chmod|rm -rf|eval\(|exec\(|os\.system|subprocess|\.ssh/|\.env|/etc/passwd" AGENTS.md CLAUDE.md .cursorrules 2>/dev/null

# T4: Supply Chain
grep -iE "npm install|pip install|npx |cargo install|go install|brew install|curl.*\|.*sh" AGENTS.md CLAUDE.md .cursorrules 2>/dev/null
```
## Supply Chain Deep Scan
| Pattern | Detection | Severity |
|---------|-----------|----------|
| Pipe-to-shell | `curl | sh`, `wget | bash` | 🔴 |
| One-shot exec | `npx unknown`, `pipx run -y` | 🔴 |
| Auto-update/build | VERSION fetch or postinstall file replace | 🔴 |
| Dep/source risk | typosquatting, takeover, CI/CD, registry | 🟡 |
Defense: Audit what RUNS. Pin versions. Download, review, execute.
### Agent Identity & Escalation
- **Identity Files**: Scan MEMORY.md, USER.md, SOUL.md access
- **Progressive Escalation**: Multi-part docs: benign→privileged gradient
- **FP notes**: T1 "new role" OK in personas; T2 HTTP OK in SDKs; T3 eval OK in builds; T4 install OK in setup

### Agent Safety Score (/5)

| Check | Points |
|-------|--------|
| No agent configs, or configs are benign | +1 |
| No data exfiltration patterns | +1 |
| No shell execution instructions | +1 |
| No supply chain amplification | +1 |
| No prompt injection patterns | +1 |

## 3.3.2 CI/CD Security

### Detect
```bash
ls -la .github/workflows/*.yml .github/workflows/*.yaml 2>/dev/null
```

### Analyze
```bash
# C1: pull_request_target + checkout (critical)
grep -l "pull_request_target" .github/workflows/*.yml 2>/dev/null

# C2: Overly permissive permissions
grep -E "permissions:.*write-all" .github/workflows/*.yml 2>/dev/null

# C3: Unpinned actions
grep -E "uses:.*@(main|master|latest|v[0-9]+)$" .github/workflows/*.yml 2>/dev/null

# C4: Script injection via untrusted input
grep -E "\$\{\{.*github\.event\.(issue|pull_request|comment)" .github/workflows/*.yml 2>/dev/null

# C5: Secrets in PR workflows
grep -B 5 -A 5 "secrets\." .github/workflows/*.yml 2>/dev/null | grep -E "pull_request|fork"

# C6: Self-hosted runners
grep -E "runs-on:.*self-hosted" .github/workflows/*.yml 2>/dev/null
```

### CI/CD Security Score (/5)

| Check | Points |
|-------|--------|
| No `pull_request_target` + checkout combo | +1 |
| Least-privilege permissions | +1 |
| Actions pinned by SHA | +1 |
| No script injection via untrusted data | +1 |
## 4-Level Risk Rating
| Level | Meaning | Action | Security /20 |
|-------|---------|--------|-------------|
| 🟢 LOW | No exec/collection, trusted | Proceed | 18-20 |
| 🟡 MEDIUM | Limited capability, some risk | Document | 14-17 |
| 🔴 HIGH | Credentials, system mods | Flag | 8-13 |
| ⛔ REJECT | Confirmed malicious | Do NOT recommend | 0-7 |
Trust Tier: T1 Official→Moderate; T2 Security→Moderate; T3 High-star→High; T4 Unknown→Maximum.

## Vulnerability Categories Summary

| Category | What to Look For |
|----------|-----------------|
| **Injection** | SQL, Command, Code injection |
| **Secrets** | Hardcoded API keys, passwords |
| **Dependencies** | Known CVEs |
| **Auth** | Weak authentication, missing CSRF |
| **Crypto** | Weak algorithms, hardcoded keys |
