# Blocks destructive or remote-execution commands. Exit 2 = block.
# PATH (jq, grep) is injected by the nix wrapper in default.nix.
set -uo pipefail
cmd=$(jq -r '.tool_input.command // empty')
[ -z "$cmd" ] && exit 0

patterns=(
  'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*[[:space:]]+(/|~|\$HOME)([[:space:]]|/?\*?$)'
  '(^|[[:space:];&|])mkfs'
  '(^|[[:space:];&|])dd[[:space:]]+if='
  ':\(\)[[:space:]]*\{'
  'chmod[[:space:]]+-R[[:space:]]+777'
  '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z)?sh'
  'base64[[:space:]]+(-d|--decode)[^|]*\|[[:space:]]*(ba|z)?sh'
  'git[[:space:]]+push[^;&|]*(--force|-f([[:space:]]|$))'
  'dangerously-skip-permissions'
  '(^|[[:space:];&|])sudo[[:space:]]'
)
for p in "${patterns[@]}"; do
  if grep -Eq -- "$p" <<<"$cmd"; then
    echo "[danger-guard] Commande bloquée (motif: $p). Si c'est voulu, l'utilisateur doit la lancer lui-même hors Claude Code." >&2
    exit 2
  fi
done
exit 0
