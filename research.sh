#!/usr/bin/env bash
#
# research.sh — One-click GitHub project research via OpenCode Server
#
# Usage:
#   ./research.sh <github_url> [options]
#
# Examples:
#   ./research.sh https://github.com/vercel/next.js
#   ./research.sh https://github.com/vercel/next.js --async
#   ./research.sh https://github.com/vercel/next.js --port 4096
#   ./research.sh https://github.com/vercel/next.js --agent build --model "github-copilot/claude-sonnet-4"
#   ./research.sh https://github.com/vercel/next.js --async --log
#
# Options:
#   --port PORT       OpenCode server port (default: 13456)
#   --async           Async mode: submit and poll, don't block terminal
#   --log             Save session log to log directory
#   --log-dir DIR     Custom log directory (default: ~/.github-researcher/logs)
#   --verbose         Show real-time message updates in async mode
#   --agent AGENT     Agent to use (default: sisyphus)
#   --model MODEL     Model override, format: provider/model (e.g. github-copilot/claude-opus-4.6)
#   --timeout SECS    Timeout in seconds for sync mode (default: 3600 = 1 hour)
#   --dry-run         Parse URL and health check only, don't start research
#   --help            Show this help message

set -euo pipefail

# ─── Defaults ───────────────────────────────────────────────────────────────────

PORT=13456
HOST="127.0.0.1"
AGENT="sisyphus"
MODEL=""
TIMEOUT=3600
ASYNC=false
DRY_RUN=false
VERBOSE=false
SAVE_LOG=false
LOG_DIR="${GITHUB_RESEARCHER_LOG_DIR:-$HOME/.github-researcher/logs}"
GITHUB_URL=""
SESSION_ID=""
OWNER=""
REPO=""
LOG_FILE=""

# ─── Colors ─────────────────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

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
  ./research.sh https://github.com/vercel/next.js --async
  ./research.sh https://github.com/vercel/next.js --async --log --verbose
  ./research.sh https://github.com/vercel/next.js --port 4096
  ./research.sh https://github.com/vercel/next.js --agent build --model "github-copilot/claude-sonnet-4"

Options:
  --port PORT       OpenCode server port (default: 13456)
  --async           Async mode: submit and poll, don't block terminal
  --log             Save session log to log directory
  --log-dir DIR     Custom log directory (default: ~/.github-researcher/logs)
  --verbose         Show real-time message updates in async mode
  --agent AGENT     Agent to use (default: sisyphus)
  --model MODEL     Model override, format: provider/model
  --timeout SECS    Timeout in seconds for sync mode (default: 3600)
  --dry-run         Parse URL and health check only
  --help            Show this help message
USAGE
    exit 0
}

# ─── Parse Arguments ────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
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
    
    echo "" >> "$LOG_FILE"
    echo "$messages" | python3 << 'PYEOF' >> "$LOG_FILE"
import sys, json
from datetime import datetime

data = json.load(sys.stdin)
msgs = data if isinstance(data, list) else data.get('messages', data.get('items', []))

for msg in msgs:
    info = msg.get('info', {})
    parts = msg.get('parts', [])
    role = info.get('role', 'unknown')
    ts = info.get('timestamp', '')
    
    print(f"\n### [{role.upper()}] {ts}\n")
    
    for part in parts:
        if part.get('type') == 'text':
            text = part.get('text', '')
            print(text)
            print()
PYEOF

    cat >> "$LOG_FILE" << EOF

---

## Session End

**Completed:** $(date '+%Y-%m-%d %H:%M:%S')
EOF
    
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
        echo "$messages" | python3 << PYEOF
import sys, json

data = json.load(sys.stdin)
msgs = data if isinstance(data, list) else data.get('messages', data.get('items', []))
skip = $LAST_MSG_COUNT

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
PYEOF
        LAST_MSG_COUNT=$current_count
    fi
}

# ─── Display Header ─────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}GitHub Project Researcher${NC}"
echo -e "────────────────────────────────────────"
echo -e "  Project:  ${CYAN}${FULL_NAME}${NC}"
echo -e "  URL:      ${GITHUB_URL}"
echo -e "  Server:   ${BASE_URL}"
echo -e "  Agent:    ${AGENT}"
[[ -n "$MODEL" ]] && echo -e "  Model:    ${MODEL}"
echo -e "  Mode:     $(${ASYNC} && echo 'async' || echo 'sync')"
${VERBOSE} && echo -e "  Verbose:  enabled"
${SAVE_LOG} && echo -e "  Log:      enabled"
echo -e "────────────────────────────────────────"
echo ""

# ─── Step 1: Health Check ───────────────────────────────────────────────────────

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
    exit 0
fi

# ─── Step 2: Create Session ─────────────────────────────────────────────────────

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

# Setup log directory after session ID is known
if $SAVE_LOG; then
    setup_log_dir
fi

# ─── Step 3: Build Prompt ───────────────────────────────────────────────────────

export RESEARCH_PROMPT="加载 github-project-researcher 技能，研究 ${GITHUB_URL} 。

要求：
1. 走完 Step 1 到 Step 7 的全部流程
2. 自动执行每个步骤，不需要等待我确认
3. 根据 Step 3.0 的项目类型门控自动判断走代码分析还是文档分析路径
4. 如果项目有推荐/建议且超过2年，执行 Step 4.2 生态审计
5. 按照 Step 6.1 的KB卫生规则更新知识库
6. 完成后输出 RESEARCH.md 的完整路径"

export AGENT MODEL

build_payload() {
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

# ─── Step 4: Send Research Request ──────────────────────────────────────────────

cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]] && [[ -n "${SESSION_ID:-}" ]]; then
        log_warn "Aborting session ${SESSION_ID}..."
        curl -sf -X POST "${BASE_URL}/session/${SESSION_ID}/abort" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT

if $ASYNC; then
    # ── Async Mode: Submit + Poll with Real-time Updates ─────────────────────

    log_step "3/4  Sending research request (async)..."

    PAYLOAD=$(build_payload)

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

    POLL_INTERVAL=10
    ELAPSED=0
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
        exit 0
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
    # ── Sync Mode: Block Until Complete ──────────────────────────────────────

    log_step "3/4  Sending research request (sync, timeout: ${TIMEOUT}s)..."
    log_info "This may take 5-30 minutes. Press Ctrl+C to abort."
    echo ""

    PAYLOAD=$(build_payload)

    RESPONSE_FILE=$(mktemp)
    trap "rm -f '$RESPONSE_FILE'; cleanup" EXIT

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
        exit 1
    }

    if [[ "$HTTP_CODE" -lt 200 || "$HTTP_CODE" -ge 300 ]]; then
        log_error "Server returned HTTP ${HTTP_CODE}"
        cat "$RESPONSE_FILE" >&2
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

# ─── Output ─────────────────────────────────────────────────────────────────────

echo ""
echo -e "${BOLD}────────────────────────────────────────${NC}"
echo -e "${GREEN}${BOLD}Research Complete${NC}"
echo -e "${BOLD}────────────────────────────────────────${NC}"
echo ""
echo -e "  Session:  ${SESSION_ID}"
echo -e "  Project:  ${CYAN}${FULL_NAME}${NC}"
[[ -n "$LOG_FILE" ]] && echo -e "  Log:      ${LOG_FILE}"
echo ""

RESEARCH_MD=$(echo "$RESULT" | grep -oE '/[^ ]*RESEARCH\.md' | head -1)
if [[ -n "$RESEARCH_MD" ]]; then
    echo -e "  Output:   ${GREEN}${RESEARCH_MD}${NC}"
    if [[ -f "$RESEARCH_MD" ]]; then
        FILE_SIZE=$(wc -c < "$RESEARCH_MD" | tr -d ' ')
        LINE_COUNT=$(wc -l < "$RESEARCH_MD" | tr -d ' ')
        echo -e "  Size:     ${FILE_SIZE} bytes, ${LINE_COUNT} lines"
    fi
else
    echo -e "  ${YELLOW}RESEARCH.md path not found in output.${NC}"
    echo -e "  Check:    \${GITHUB_RESEARCHER_CLONE_DIR:-\$HOME/.github-researcher/projects}/${OWNER}/${REPO}/"
fi

echo ""
echo -e "${BOLD}Summary (last portion of agent response):${NC}"
echo -e "────────────────────────────────────────"
echo "$RESULT" | tail -30
echo -e "────────────────────────────────────────"
echo ""
