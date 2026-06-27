#!/usr/bin/env bash
set -euo pipefail

json_mode=0
if [[ "${1:-}" == "--json" ]]; then
    json_mode=1
fi

json_escape() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    value="${value//$'\r'/}"
    value="${value//$'\n'/ }"
    printf '%s' "$value"
}

weather_unavailable() {
    if (( json_mode )); then
        printf '{"text":"--","tooltip":"Weather unavailable"}\n'
    else
        printf -- '--\n'
    fi
}

location="${VIEGPHUNT_WEATHER_LOCATION:-}"
location="${location// /+}"

text_url="https://wttr.in/${location}?format=%c+%t"
tooltip_url="https://wttr.in/${location}?format=%l:+%C,+feels+like+%f,+humidity+%h,+wind+%w"

if weather="$(curl -fsS --max-time 3 "$text_url" 2>/dev/null)"; then
    weather="${weather//$'\r'/}"
    weather="${weather//$'\n'/ }"
    if [[ -n "$weather" ]]; then
        if (( json_mode )); then
            tooltip="$(curl -fsS --max-time 3 "$tooltip_url" 2>/dev/null || true)"
            tooltip="${tooltip//$'\r'/}"
            tooltip="${tooltip//$'\n'/ }"
            [[ -n "$tooltip" ]] || tooltip="$weather"
            printf '{"text":"%s","tooltip":"%s"}\n' "$(json_escape "$weather")" "$(json_escape "$tooltip")"
        else
            printf '%s\n' "$weather"
        fi
        exit 0
    fi
fi

weather_unavailable
