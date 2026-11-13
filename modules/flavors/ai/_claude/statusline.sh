# Status line: model, context, subscription session (5h) and weekly (7d) usage.
# rate_limits only exists for Pro/Max subscribers, after the first API response.
# PATH (jq, date) is injected by the nix wrapper in default.nix.
jq -r --argjson now "$(date +%s)" '
  def pct(x): (x | floor | tostring) + "%";
  def rem(t):
    if t == null then ""
    else (t - $now) as $s
      | if $s <= 0 then ""
        else " ↻" + (
          if $s >= 86400 then "\($s / 86400 | floor)j\(($s % 86400) / 3600 | floor)h"
          elif $s >= 3600 then "\($s / 3600 | floor)h\(($s % 3600) / 60 | floor)m"
          else "\($s / 60 | floor)m" end)
        end
    end;
  [ "[\(.model.display_name // "?")]",
    "ctx \(pct(.context_window.used_percentage // 0))",
    (.rate_limits.five_hour | select(. != null) | "5h \(pct(.used_percentage))\(rem(.resets_at))"),
    (.rate_limits.seven_day | select(. != null) | "7j \(pct(.used_percentage))\(rem(.resets_at))")
  ] | join(" · ")'
