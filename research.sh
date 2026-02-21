#!/usr/bin/env bash
#
# research.sh — One-click GitHub project research
#
# Supports three execution backends (runners):
#   opencode  — OpenCode Server API (default, supports --async)
#   claude    — Claude Code CLI (print mode, headless)
#   gemini    — Gemini CLI (headless JSON output)
#
# Usage:
#   ./research.sh <github_url> [options]
#
# Examples:
#   ./research.sh https://github.com/vercel/next.js
#   ./research.sh https://github.com/vercel/next.js --async
#   ./research.sh https://github.com/vercel/next.js --runner claude
#   ./research.sh https://github.com/vercel/next.js --runner gemini --model gemini-2.5-flash
#   ./research.sh https://github.com/vercel/next.js --port 4096
#   ./research.sh https://github.com/vercel/next.js --agent build --model "github-copilot/claude-sonnet-4"
#   ./research.sh https://github.com/vercel/next.js --async --log
#
# Options:
#   --runner RUNNER   Execution backend: opencode|claude|gemini (default: opencode)
#   --port PORT       OpenCode server port (default: 13456, opencode runner only)
#   --async           Async mode: submit and poll (opencode runner only)
#   --log             Save session log to log directory (opencode runner only)
#   --log-dir DIR     Custom log directory (default: ~/.github-researcher/logs)
#   --verbose         Show real-time message updates in async mode
#   --agent AGENT     Agent to use (default: sisyphus, opencode runner only)
#   --model MODEL     Model override (format depends on runner)
#   --timeout SECS    Timeout in seconds (default: 3600 = 1 hour)
#   --dry-run         Preflight check only, don't start research
#   --help            Show this help message

set -euo pipefail

# ─── Defaults ───────────────────────────────────────────────────────────────────

RUNNER="opencode"
PORT=13456
HOST="127.0.0.1"
AGENT="sisyphus"
MODEL=""
TIMEOUT=3600
ASYNC=false
DRY_RUN=false
VERBOSE=false
SAVE_LOG=false
LOG_DIR="$HOME/.github-researcher/logs"
CLONE_DIR="$HOME/.github-researcher/projects"
GITHUB_URL=""
SESSION_ID=""
OWNER=""
REPO=""
LOG_FILE=""
RESPONSE_FILE=""

# ─── Load local config (gitignored) ─────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/.env.local" ]]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/.env.local"
fi

# ─── Colors ─────────────────────────────────────────────────────────────────────

# Respect NO_COLOR (https://no-color.org/) and non-interactive terminals
if [[ -n "${NO_COLOR:-}" ]] || [[ ! -t 1 ]]; then
    RED="" GREEN="" YELLOW="" BLUE="" CYAN="" MAGENTA="" BOLD="" DIM="" NC=""
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    MAGENTA='\033[0;35m'
    BOLD='\033[1m'
    DIM='\033[2m'
    NC='\033[0m' # No Color
fi

# ─── Helper Functions ───────────────────────────────────────────────────────────

log_info()  { 
    echo -e "${BLUE}[INFO]${NC} $*"
    [[ -n "$LOG_FILE" ]] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $*" >> "$LOG_FILE"
}
log_ok()    { 
    echo -e "${GREEN}[OK]${NC} $*"
    [[ -n "$LOG_FILE" ]] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] [OK] $*" >> "$LOG_FILE"
}
log_warn()  { 
    echo -e "${YELLOW}[WARN]${NC} $*"
    [[ -n "$LOG_FILE" ]] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $*" >> "$LOG_FILE"
}
log_error() { 
    echo -e "${RED}[ERROR]${NC} $*" >&2
    [[ -n "$LOG_FILE" ]] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $*" >> "$LOG_FILE"
}
log_step()  { 
    echo -e "${CYAN}${BOLD}[STEP]${NC} $*"
    [[ -n "$LOG_FILE" ]] && echo "[$(date '+%Y-%m-%d %H:%M:%S')] [STEP] $*" >> "$LOG_FILE"
}
log_msg() {
    echo -e "${DIM}${MAGENTA}[MSG]${NC} $*"
    [[ -n "$LOG_FILE" ]] && echo "$*" >> "$LOG_FILE"
}

usage() {
    cat << 'USAGE'
Usage: research.sh <github_url> [options]

Examples:
  ./research.sh https://github.com/vercel/next.js
  ./research.sh https://github.com/vercel/next.js --async --log --verbose
  ./research.sh https://github.com/vercel/next.js --runner claude
  ./research.sh https://github.com/vercel/next.js --runner gemini --model gemini-2.5-flash
  ./research.sh https://github.com/vercel/next.js --agent build --model "github-copilot/claude-sonnet-4"

Runners:
  opencode          OpenCode Server API (default). Supports --async, --log, --verbose.
  claude            Claude Code CLI (print mode). Requires: claude CLI + ANTHROPIC_API_KEY.
  gemini            Gemini CLI (headless). Requires: gemini CLI + GEMINI_API_KEY.

Options:
  --runner RUNNER   Execution backend: opencode|claude|gemini (default: opencode)
  --port PORT       OpenCode server port (default: 13456, opencode only)
  --async           Async mode: submit and poll (opencode only)
  --log             Save session log (opencode only)
  --log-dir DIR     Custom log directory (default: ~/.github-researcher/logs)
  --verbose         Show real-time messages (opencode only)
  --agent AGENT     Agent to use (default: sisyphus, opencode only)
  --model MODEL     Model override (format depends on runner)
  --timeout SECS    Timeout in seconds (default: 3600)
  --dry-run         Preflight check only, don't start research
  --help            Show this help message
USAGE
    exit 0
}

# ─── Parse Arguments ────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        --runner)   RUNNER="$2"; shift 2 ;;
        --port)     PORT="$2"; shift 2 ;;
        --async)    ASYNC=true; shift ;;
        --log)      SAVE_LOG=true; shift ;;
        --log-dir)  LOG_DIR="$2"; shift 2 ;;
        --verbose)  VERBOSE=true; shift ;;
        --agent)    AGENT="$2"; shift 2 ;;
        --model)    MODEL="$2"; shift 2 ;;
        --timeout)  TIMEOUT="$2"; shift 2 ;;
        --dry-run)  DRY_RUN=true; shift ;;
        --help|-h)  usage ;;
        -*)         log_error "Unknown option: $1"; usage ;;
        *)
            if [[ -z "$GITHUB_URL" ]]; then
                GITHUB_URL="$1"
            else
                log_error "Unexpected argument: $1"
                usage
            fi
            shift
            ;;
    esac
done

if [[ -z "$GITHUB_URL" ]]; then
    log_error "Missing required argument: <github_url>"
    echo ""
    usage
fi

case "$RUNNER" in
    opencode|claude|gemini) ;;
    *)
        log_error "Invalid runner: $RUNNER (must be opencode, claude, or gemini)"
        exit 1
        ;;
esac

[[ "$PORT" =~ ^[0-9]+$ ]] || { log_error "Invalid --port: $PORT (must be numeric)"; exit 1; }
[[ "$TIMEOUT" =~ ^[0-9]+$ ]] || { log_error "Invalid --timeout: $TIMEOUT (must be numeric)"; exit 1; }

if [[ "$RUNNER" != "opencode" ]]; then
    $ASYNC && log_warn "--async is only supported for --runner opencode"
    $SAVE_LOG && log_warn "--log is only supported for --runner opencode"
    $VERBOSE && log_warn "--verbose is only supported for --runner opencode"
fi

# ─── Parse GitHub URL ───────────────────────────────────────────────────────────

parse_github_url() {
    local url="$1"

    url="${url%/}"
    url="${url%.git}"

    if [[ "$url" =~ github\.com[:/]([^/]+)/([^/]+) ]]; then
        OWNER="${BASH_REMATCH[1]}"
        REPO="${BASH_REMATCH[2]}"
    else
        log_error "Cannot parse GitHub URL: $url"
        log_error "Expected format: https://github.com/owner/repo"
        exit 1
    fi
}

parse_github_url "$GITHUB_URL"
FULL_NAME="${OWNER}/${REPO}"
BASE_URL="http://${HOST}:${PORT}"

# ─── Build Research Prompt ───────────────────────────────────────────────────

build_prompt() {
    cat << PROMPT
加载 github-project-researcher 技能，研究 ${GITHUB_URL} 。

要求：
1. 走完全部研究流程（信息采集、克隆、深度分析、评估、输出、知识库、竞品）
2. 自动执行每个步骤，不需要等待我确认
3. 根据项目类型门控自动判断走代码分析还是文档分析路径
4. 如果项目有推荐/建议且超过2年，执行生态审计
5. 按照KB卫生规则更新知识库
6. 完成后输出 RESEARCH.md 的完整路径
PROMPT
}

RESEARCH_PROMPT="$(build_prompt)"
export RESEARCH_PROMPT AGENT MODEL

# ─── Setup Log Directory ────────────────────────────────────────────────────────

setup_log_dir() {
    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local session_dir="${LOG_DIR}/${OWNER}_${REPO}_${timestamp}"
    
    mkdir -p "$session_dir"
    LOG_FILE="${session_dir}/SESSION.md"
    
    cat > "$LOG_FILE" << EOF
# Research Session: ${FULL_NAME}

**Started:** $(date '+%Y-%m-%d %H:%M:%S')
**Repository:** ${GITHUB_URL}
**Session ID:** ${SESSION_ID}
**Agent:** ${AGENT}
**Model:** ${MODEL:-default}

---

## Session Log

EOF
    
    log_info "Logging to: ${session_dir}"
}

save_session_messages() {
    local messages
    messages=$(curl -sf "${BASE_URL}/session/${SESSION_ID}/message" 2>/dev/null) || return
    
    {
        echo ""
        MESSAGES_JSON="$messages" python3 -c "
import os, json

data = json.loads(os.environ['MESSAGES_JSON'])
msgs = data if isinstance(data, list) else data.get('messages', data.get('items', []))

for msg in msgs:
    info = msg.get('info', {})
    parts = msg.get('parts', [])
    role = info.get('role', 'unknown')
    ts = info.get('timestamp', '')
    
    print(f'\n### [{role.upper()}] {ts}\n')
    
    for part in parts:
        if part.get('type') == 'text':
            text = part.get('text', '')
            print(text)
            print()
"
        cat << EOF

---

## Session End

**Completed:** $(date '+%Y-%m-%d %H:%M:%S')
EOF
    } >> "$LOG_FILE"
    
    log_ok "Session log saved: ${LOG_FILE}"
}

# Function to fetch and display latest messages
LAST_MSG_COUNT=0

fetch_latest_messages() {
    local messages
    messages=$(curl -sf "${BASE_URL}/session/${SESSION_ID}/message" 2>/dev/null) || return 0
    
    local current_count
    current_count=$(echo "$messages" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msgs = data if isinstance(data, list) else data.get('messages', data.get('items', []))
print(len(msgs))
" 2>/dev/null)
    
    if [[ "$current_count" -gt "$LAST_MSG_COUNT" ]]; then
        MESSAGES_JSON="$messages" SKIP="$LAST_MSG_COUNT" python3 -c "
import os, json

data = json.loads(os.environ['MESSAGES_JSON'])
msgs = data if isinstance(data, list) else data.get('messages', data.get('items', []))
skip = int(os.environ['SKIP'])

for msg in msgs[skip:]:
    info = msg.get('info', {})
    parts = msg.get('parts', [])
    role = info.get('role', 'unknown')
    
    if role == 'assistant':
        for part in parts:
            if part.get('type') == 'text':
                text = part.get('text', '')
                preview = text[:300] + ('...' if len(text) > 300 else '')
                print(preview)
                print('---')
"
        LAST_MSG_COUNT=$current_count
    fi
}

# ─── Display Header ─────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}GitHub Project Researcher${NC}"
echo -e "────────────────────────────────────────"
echo -e "  Project:  ${CYAN}${FULL_NAME}${NC}"
echo -e "  URL:      ${GITHUB_URL}"
echo -e "  Runner:   ${RUNNER}"
[[ "$RUNNER" == "opencode" ]] && echo -e "  Server:   ${BASE_URL}"
echo -e "  Agent:    ${AGENT}"
[[ -n "$MODEL" ]] && echo -e "  Model:    ${MODEL}"
if [[ "$RUNNER" == "opencode" ]]; then
    echo -e "  Mode:     $(${ASYNC} && echo 'async' || echo 'sync')"
    ${VERBOSE} && echo -e "  Verbose:  enabled"
    ${SAVE_LOG} && echo -e "  Log:      enabled"
fi
echo -e "────────────────────────────────────────"
echo ""

# ─── Runner: OpenCode Server ─────────────────────────────────────────────────

build_opencode_payload() {
    python3 << 'PYEOF'
import json, os

prompt = os.environ["RESEARCH_PROMPT"]
agent = os.environ["AGENT"]
model = os.environ.get("MODEL", "")

payload = {
    "parts": [{"type": "text", "text": prompt}],
    "agent": agent,
}

if model:
    if "/" in model:
        provider_id, model_id = model.split("/", 1)
        payload["model"] = {"providerID": provider_id, "modelID": model_id}
    else:
        payload["model"] = {"modelID": model}

print(json.dumps(payload, ensure_ascii=False))
PYEOF
}

run_with_opencode() {
    log_step "1/4  Health check..."

    HEALTH=$(curl -sf "${BASE_URL}/global/health" 2>/dev/null) || {
        log_error "OpenCode server not reachable at ${BASE_URL}"
        log_error "Start it with: opencode serve --port ${PORT}"
        exit 1
    }

    HEALTHY=$(echo "$HEALTH" | python3 -c "import sys,json; print(json.load(sys.stdin).get('healthy', False))" 2>/dev/null)
    VERSION=$(echo "$HEALTH" | python3 -c "import sys,json; print(json.load(sys.stdin).get('version', '?'))" 2>/dev/null)

    if [[ "$HEALTHY" != "True" ]]; then
        log_error "Server reports unhealthy: ${HEALTH}"
        exit 1
    fi

    log_ok "Server healthy (v${VERSION})"

    if $DRY_RUN; then
        echo ""
        log_info "Dry run complete. Would research: ${FULL_NAME}"
        return 0
    fi

    log_step "2/4  Creating session..."

    SESSION_RESPONSE=$(curl -sf -X POST "${BASE_URL}/session" \
        -H "Content-Type: application/json" \
        -d "{\"title\": \"Research: ${FULL_NAME}\"}" 2>/dev/null) || {
        log_error "Failed to create session"
        exit 1
    }

    SESSION_ID=$(echo "$SESSION_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null) || {
        log_error "Failed to parse session ID from response: ${SESSION_RESPONSE}"
        exit 1
    }

    log_ok "Session created: ${SESSION_ID}"

    if $SAVE_LOG; then
        setup_log_dir
    fi

    local PAYLOAD
    PAYLOAD=$(build_opencode_payload)

    if $ASYNC; then
        log_step "3/4  Sending research request (async)..."

        HTTP_CODE=$(curl -sf -o /dev/null -w "%{http_code}" -X POST \
            "${BASE_URL}/session/${SESSION_ID}/prompt_async" \
            -H "Content-Type: application/json" \
            -d "$PAYLOAD" 2>/dev/null) || {
            log_error "Failed to submit async request"
            exit 1
        }

        if [[ "$HTTP_CODE" -lt 200 || "$HTTP_CODE" -ge 300 ]]; then
            log_error "Async submit failed with HTTP ${HTTP_CODE}"
            exit 1
        fi

        log_ok "Request submitted"
        log_step "4/4  Polling for completion..."

        if $VERBOSE; then
            echo ""
            echo -e "${DIM}--- Real-time messages ---${NC}"
        fi

        local POLL_INTERVAL=10
        local ELAPSED=0
        LAST_MSG_COUNT=0

        while true; do
            if [[ $ELAPSED -ge $TIMEOUT ]]; then
                echo ""
                log_error "Timeout after ${TIMEOUT}s. Session ${SESSION_ID} may still be running."
                log_info "Check status:  curl ${BASE_URL}/session/status"
                log_info "Abort:         curl -X POST ${BASE_URL}/session/${SESSION_ID}/abort"
                exit 1
            fi

            STATUS_JSON=$(curl -sf "${BASE_URL}/session/status" 2>/dev/null) || {
                log_warn "Status check failed, retrying..."
                sleep "$POLL_INTERVAL"
                ELAPSED=$((ELAPSED + POLL_INTERVAL))
                continue
            }

            SESSION_STATUS=$(echo "$STATUS_JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
info = data.get('${SESSION_ID}', {})
if isinstance(info, dict):
    print(info.get('type', 'unknown'))
else:
    print('unknown')
" 2>/dev/null)

            case "$SESSION_STATUS" in
                idle)
                    echo ""
                    log_ok "Research complete!"
                    break
                    ;;
                retry)
                    log_warn "[${ELAPSED}s] Rate limited, retrying automatically..."
                    ;;
                *)
                    if $VERBOSE; then
                        fetch_latest_messages
                    else
                        printf "\r  ${YELLOW}Running...${NC} %02d:%02d elapsed  " "$((ELAPSED / 60))" "$((ELAPSED % 60))"
                    fi
                    ;;
            esac

            sleep "$POLL_INTERVAL"
            ELAPSED=$((ELAPSED + POLL_INTERVAL))
        done
        echo ""

        log_info "Fetching results..."

        MESSAGES=$(curl -sf "${BASE_URL}/session/${SESSION_ID}/message" 2>/dev/null) || {
            log_warn "Could not fetch messages. Check session manually:"
            log_info "  Session ID: ${SESSION_ID}"
            return 0
        }

        if $SAVE_LOG; then
            save_session_messages
        fi

        RESULT=$(echo "$MESSAGES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
msgs = data if isinstance(data, list) else data.get('messages', data.get('items', []))
for msg in reversed(msgs):
    role = msg.get('role', '')
    info = msg.get('info', {})
    if info.get('role') == 'assistant' or role == 'assistant':
        parts = msg.get('parts', [])
        for part in parts:
            if part.get('type') == 'text':
                print(part.get('text', '')[:2000])
                sys.exit(0)
print('[No assistant response found]')
" 2>/dev/null)

    else
        log_step "3/4  Sending research request (sync, timeout: ${TIMEOUT}s)..."
        log_info "This may take 5-30 minutes. Press Ctrl+C to abort."
        echo ""

        if $SAVE_LOG; then
            setup_log_dir
        fi

        RESPONSE_FILE=$(mktemp)

        HTTP_CODE=$(curl -sf -o "$RESPONSE_FILE" -w "%{http_code}" \
            --max-time "$TIMEOUT" \
            -X POST "${BASE_URL}/session/${SESSION_ID}/message" \
            -H "Content-Type: application/json" \
            -d "$PAYLOAD" 2>/dev/null) || {
            CURL_EXIT=$?
            if [[ $CURL_EXIT -eq 28 ]]; then
                log_error "Timeout after ${TIMEOUT}s"
                log_info "Session ${SESSION_ID} may still be running."
                log_info "Check status:  curl ${BASE_URL}/session/status"
            else
                log_error "Request failed (curl exit code: ${CURL_EXIT})"
            fi
            rm -f "$RESPONSE_FILE"
            exit 1
        }

        if [[ "$HTTP_CODE" -lt 200 || "$HTTP_CODE" -ge 300 ]]; then
            log_error "Server returned HTTP ${HTTP_CODE}"
            cat "$RESPONSE_FILE" >&2
            rm -f "$RESPONSE_FILE"
            exit 1
        fi

        log_ok "Research complete!"

        log_step "4/4  Extracting results..."

        RESULT=$(python3 -c "
import sys, json

with open('${RESPONSE_FILE}', 'r') as f:
    data = json.load(f)

parts = data.get('parts', [])
if not parts:
    parts = data.get('info', {}).get('parts', [])

for part in parts:
    if part.get('type') == 'text':
        text = part.get('text', '')
        if len(text) > 2000:
            print('... (truncated) ...')
            print(text[-2000:])
        else:
            print(text)
        sys.exit(0)

print('[No text content in response]')
" 2>/dev/null)

        if $SAVE_LOG; then
            save_session_messages
        fi

        rm -f "$RESPONSE_FILE"
    fi
}

# ─── Runner: Claude CLI ─────────────────────────────────────────────────────

run_with_claude() {
    log_step "1/2  Preflight check (Claude CLI)..."

    if ! command -v claude &>/dev/null; then
        log_error "claude CLI not found"
        log_error "Install: curl -fsSL https://claude.ai/install.sh | bash"
        log_error "Docs:    https://docs.anthropic.com/en/docs/claude-code/cli-reference"
        exit 1
    fi

    if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
        log_warn "ANTHROPIC_API_KEY not set — claude may require interactive login"
        log_info "Set it with: export ANTHROPIC_API_KEY='sk-ant-...'"
    fi

    log_ok "Claude CLI found: $(claude --version 2>/dev/null || echo 'unknown version')"

    if $DRY_RUN; then
        echo ""
        log_info "Dry run complete. Would research: ${FULL_NAME}"
        return 0
    fi

    log_step "2/2  Running research (Claude CLI, timeout: ${TIMEOUT}s)..."
    log_info "This may take 5-30 minutes. Press Ctrl+C to abort."
    echo ""

    local claude_args=("-p" "--output-format" "json")
    [[ -n "$MODEL" ]] && claude_args+=("--model" "$MODEL")

    local RAW_OUTPUT
    RAW_OUTPUT=$(timeout "$TIMEOUT" claude "${claude_args[@]}" "$RESEARCH_PROMPT" 2>/dev/null) || {
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            log_error "Timeout after ${TIMEOUT}s"
        else
            log_error "Claude CLI failed (exit code: ${exit_code})"
        fi
        exit 1
    }

    log_ok "Research complete!"

    RESULT=$(echo "$RAW_OUTPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('result', data.get('text', '[No result field in response]')))
except (json.JSONDecodeError, KeyError):
    print(sys.stdin.read())
" 2>/dev/null) || RESULT="$RAW_OUTPUT"
}

# ─── Runner: Gemini CLI ─────────────────────────────────────────────────────

run_with_gemini() {
    log_step "1/2  Preflight check (Gemini CLI)..."

    if ! command -v gemini &>/dev/null; then
        log_error "gemini CLI not found"
        log_error "Install: npm install -g @google/gemini-cli"
        log_error "  or:    brew install gemini-cli"
        log_error "Docs:    https://github.com/google-gemini/gemini-cli"
        exit 1
    fi

    if [[ -z "${GEMINI_API_KEY:-}" ]] && [[ -z "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
        log_warn "GEMINI_API_KEY not set — gemini may require interactive login"
        log_info "Set it with: export GEMINI_API_KEY='...'"
    fi

    log_ok "Gemini CLI found: $(gemini --version 2>/dev/null || echo 'unknown version')"

    if $DRY_RUN; then
        echo ""
        log_info "Dry run complete. Would research: ${FULL_NAME}"
        return 0
    fi

    log_step "2/2  Running research (Gemini CLI, timeout: ${TIMEOUT}s)..."
    log_info "This may take 5-30 minutes. Press Ctrl+C to abort."
    echo ""

    local gemini_args=()
    [[ -n "$MODEL" ]] && gemini_args+=("--model" "$MODEL")

    local RAW_OUTPUT
    RAW_OUTPUT=$(echo "$RESEARCH_PROMPT" | timeout "$TIMEOUT" gemini "${gemini_args[@]}" 2>/dev/null) || {
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            log_error "Timeout after ${TIMEOUT}s"
        elif [[ $exit_code -eq 42 ]]; then
            log_error "Gemini CLI: bad input (exit 42)"
        elif [[ $exit_code -eq 53 ]]; then
            log_error "Gemini CLI: turn limit reached (exit 53)"
        else
            log_error "Gemini CLI failed (exit code: ${exit_code})"
        fi
        exit 1
    }

    log_ok "Research complete!"

    RESULT=$(echo "$RAW_OUTPUT" | python3 -c "
import sys, json
text = sys.stdin.read()
try:
    data = json.loads(text)
    print(data.get('response', data.get('text', text)))
except (json.JSONDecodeError, KeyError):
    print(text)
" 2>/dev/null) || RESULT="$RAW_OUTPUT"
}

# ─── Cleanup ─────────────────────────────────────────────────────────────────

cleanup() {
    local exit_code=$?
    [[ -n "${RESPONSE_FILE:-}" ]] && rm -f "$RESPONSE_FILE"
    if [[ $exit_code -ne 0 ]] && [[ "$RUNNER" == "opencode" ]] && [[ -n "${SESSION_ID:-}" ]]; then
        log_warn "Aborting session ${SESSION_ID}..."
        curl -sf -X POST "${BASE_URL}/session/${SESSION_ID}/abort" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

# ─── Runner Dispatch ─────────────────────────────────────────────────────────

RESULT=""

case "$RUNNER" in
    opencode) run_with_opencode ;;
    claude)   run_with_claude ;;
    gemini)   run_with_gemini ;;
esac

if $DRY_RUN; then
    exit 0
fi

# ─── Output ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}────────────────────────────────────────${NC}"
echo -e "${GREEN}${BOLD}Research Complete${NC}"
echo -e "${BOLD}────────────────────────────────────────${NC}"
echo ""
[[ -n "${SESSION_ID:-}" ]] && echo -e "  Session:  ${SESSION_ID}"
echo -e "  Project:  ${CYAN}${FULL_NAME}${NC}"
[[ -n "$LOG_FILE" ]] && echo -e "  Log:      ${LOG_FILE}"
echo ""

RESEARCH_MD=$(echo "$RESULT" | grep -oE '/[^ ]*RESEARCH\.md' | head -1)
# Fallback to canonical path for CLI runners
if [[ -z "$RESEARCH_MD" ]]; then
    CANONICAL_PATH="${CLONE_DIR}/${OWNER}/${REPO}/RESEARCH.md"
    [[ -f "$CANONICAL_PATH" ]] && RESEARCH_MD="$CANONICAL_PATH"
fi
if [[ -n "$RESEARCH_MD" ]]; then
    echo -e "  Output:   ${GREEN}${RESEARCH_MD}${NC}"
    if [[ -f "$RESEARCH_MD" ]]; then
        FILE_SIZE=$(wc -c < "$RESEARCH_MD" | tr -d ' ')
        LINE_COUNT=$(wc -l < "$RESEARCH_MD" | tr -d ' ')
        echo -e "  Size:     ${FILE_SIZE} bytes, ${LINE_COUNT} lines"
    fi
else
    echo -e "  ${YELLOW}RESEARCH.md path not found in output.${NC}"
    echo -e "  Check:    ${CLONE_DIR}/${OWNER}/${REPO}/"
fi

echo ""
echo -e "${BOLD}Summary (last portion of agent response):${NC}"
echo -e "────────────────────────────────────────"
echo "$RESULT" | tail -30
echo -e "────────────────────────────────────────"
echo ""
