# Bash Scripting Style Guide

Scripting conventions for `research.sh` and any future bash scripts.

---

## Strict Mode (MANDATORY)

All scripts MUST start with:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

| Flag | Purpose |
|------|---------|
| `-e` | Exit immediately on error |
| `-u` | Treat unset variables as error |
| `-o pipefail` | Pipeline fails on first error |

---

## Variable Declarations

### Globals
```bash
# At script top, after strict mode
PORT=13456
HOST="127.0.0.1"
GITHUB_URL=""
```

### Locals
```bash
# Inside functions, always use local
my_function() {
    local url="$1"
    local owner=""
    local repo=""
}
```

### Constants
```bash
# Colors (single quotes for literal escapes)
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
```

---

## Functions

### Naming
```bash
# snake_case with verb prefix
log_info()   { ... }
parse_url()  { ... }
build_payload() { ... }
```

### Structure
```bash
# Helper functions first, main logic last
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }

main() {
    local url="$1"
    parse_url "$url"
    process_data
}

main "$@"
```

### Return Values
```bash
# Prefer command substitution for data
get_session_id() {
    echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])"
}

SESSION_ID=$(get_session_id)

# Use return codes for success/failure
check_health() {
    curl -sf "${BASE_URL}/health" >/dev/null 2>&1
}

if check_health; then
    log_ok "Server healthy"
fi
```

---

## Conditionals

### Preferred Style
```bash
# Use [[ ]] for all conditionals
if [[ -z "$VAR" ]]; then
    echo "Empty"
fi

if [[ "$STATUS" == "success" ]]; then
    echo "Done"
fi

# Combined conditions
if [[ -n "$URL" ]] && [[ "$URL" =~ ^https:// ]]; then
    process "$URL"
fi
```

### Pattern Matching
```bash
# Regex with =~
if [[ "$URL" =~ github\.com[:/]([^/]+)/([^/]+) ]]; then
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
fi

# Case statements for multiple options
case "$1" in
    --async)  ASYNC=true; shift ;;
    --port)   PORT="$2"; shift 2 ;;
    *)        log_error "Unknown: $1"; exit 1 ;;
esac
```

---

## Error Handling

### Check Commands
```bash
# With || for inline handling
curl -sf "${BASE_URL}/health" || {
    log_error "Server not reachable"
    exit 1
}

# With if for more complex logic
if ! curl -sf "${BASE_URL}/health" >/dev/null 2>&1; then
    log_error "Health check failed"
    log_info "Start server: opencode serve --port ${PORT}"
    exit 1
fi
```

### Cleanup with Trap
```bash
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]] && [[ "$RUNNER" == "opencode" ]] && [[ -n "${SESSION_ID:-}" ]]; then
        curl -sf -X POST "${BASE_URL}/session/${SESSION_ID}/abort" >/dev/null 2>&1 || true
    fi
}
trap cleanup EXIT
```

---

## JSON Processing

### Python (Preferred - Universal)
```bash
# Extract single value
VALUE=$(echo "$JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['key'])")

# With default value
VALUE=$(echo "$JSON" | python3 -c "import sys,json; print(json.load(sys.stdin).get('key', 'default'))")

# Nested access
VALUE=$(echo "$JSON" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['items'][0]['id'])")
```

### Multi-line Python
```bash
build_payload() {
    python3 << 'PYEOF'
import json, os

data = {
    "prompt": os.environ["RESEARCH_PROMPT"],
    "agent": os.environ["AGENT"]
}
print(json.dumps(data))
PYEOF
}
```

---

## Output Formatting

### Colors
```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'  # No Color / Reset

echo -e "${GREEN}[OK]${NC} Operation successful"
echo -e "${RED}[ERROR]${NC} Something failed" >&2
```

### Progress Indicators
```bash
# Spinner for long operations
printf "Processing..."
while ! check_complete; do
    printf "."
    sleep 1
done
echo " Done"

# Time elapsed
ELAPSED=0
while true; do
    printf "\rRunning... %02d:%02d" "$((ELAPSED / 60))" "$((ELAPSED % 60))"
    sleep 1
    ELAPSED=$((ELAPSED + 1))
done
```

---

## Argument Parsing

### Standard Pattern
```bash
while [[ $# -gt 0 ]]; do
    case "$1" in
        --port)     PORT="$2"; shift 2 ;;
        --async)    ASYNC=true; shift ;;
        --help|-h)  usage; exit 0 ;;
        -*)         log_error "Unknown option: $1"; usage; exit 1 ;;
        *)
            if [[ -z "$POSITIONAL_ARG" ]]; then
                POSITIONAL_ARG="$1"
            else
                log_error "Unexpected: $1"
                exit 1
            fi
            shift
            ;;
    esac
done
```

---

## Curl Best Practices

### Options
```bash
# Standard safe request
curl -sf "${URL}"              # -s silent, -f fail on HTTP error

# With timeout
curl -sf --max-time 30 "${URL}"

# Capture response and HTTP code
HTTP_CODE=$(curl -sf -o /tmp/response.txt -w "%{http_code}" "${URL}")

# POST with JSON
curl -sf -X POST "${URL}" \
    -H "Content-Type: application/json" \
    -d '{"key": "value"}'
```

### Error Handling
```bash
# Check HTTP code range
if [[ "$HTTP_CODE" -lt 200 || "$HTTP_CODE" -ge 300 ]]; then
    log_error "Request failed: HTTP ${HTTP_CODE}"
    cat /tmp/response.txt >&2
    exit 1
fi
```

---

## File Operations

### Temp Files
```bash
# Create with cleanup
TEMP_FILE=$(mktemp)
trap "rm -f '$TEMP_FILE'" EXIT

# Use the file
curl -sf "${URL}" -o "$TEMP_FILE"
```

### Check Existence
```bash
# File exists
if [[ -f "$FILE" ]]; then
    source "$FILE"
fi

# Directory exists
if [[ -d "$DIR" ]]; then
    cd "$DIR"
fi

# Executable exists
if command -v jq &>/dev/null; then
    USE_JQ=true
fi
```
