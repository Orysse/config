# Local journal of every tool call and subagent start.
# PATH (jq, date, head) is injected by the nix wrapper in default.nix.
set -uo pipefail
LOG="$HOME/.claude/audit.log"
input=$(cat)
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
sid=$(jq -r '.session_id // "-"' <<<"$input")
evt=$(jq -r '.hook_event_name // "-"' <<<"$input")
tool=$(jq -r '.tool_name // .agent_type // "-"' <<<"$input")
detail=$(jq -c '.tool_input // {}' <<<"$input" | head -c 600)
umask 077
printf '%s\t%s\t%s\t%s\t%s\n' "$ts" "$sid" "$evt" "$tool" "$detail" >> "$LOG"
exit 0
