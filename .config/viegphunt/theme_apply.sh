#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "$script_dir/theme_lib.sh"

theme_load_state

base="$BASE_THEME"
accent="$ACCENT"
reload=1

while [[ $# -gt 0 ]]; do
    case "$1" in
        --base)
            [[ $# -ge 2 ]] || { printf 'Missing value for --base\n' >&2; exit 2; }
            base="$(theme_normalize_base "$2")" || { printf 'Invalid base theme: %s\n' "$2" >&2; exit 2; }
            shift 2
            ;;
        --accent)
            [[ $# -ge 2 ]] || { printf 'Missing value for --accent\n' >&2; exit 2; }
            accent="$(theme_normalize_accent "$2")" || { printf 'Invalid accent: %s\n' "$2" >&2; exit 2; }
            shift 2
            ;;
        --refresh)
            shift
            ;;
        --no-reload)
            reload=0
            shift
            ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            exit 2
            ;;
    esac
done

theme_save_state "$base" "$accent"
theme_generate_files "$base" "$accent"

if (( reload )); then
    theme_reload_desktop
fi
