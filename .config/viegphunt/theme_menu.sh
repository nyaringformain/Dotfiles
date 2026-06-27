#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

if pidof rofi >/dev/null 2>&1; then
    pkill rofi
fi

case "$mode" in
    base)
        choice="$(printf 'Catppuccin\nMono\n' | rofi -dmenu -p 'Base Theme')"
        case "$choice" in
            Catppuccin) "$script_dir/theme_apply.sh" --base catppuccin ;;
            Mono) "$script_dir/theme_apply.sh" --base mono ;;
            *) exit 0 ;;
        esac
        ;;
    accent)
        choice="$(printf 'None\nPink\nBlue\nWallpaper Auto\n' | rofi -dmenu -p 'Accent')"
        case "$choice" in
            None) "$script_dir/theme_apply.sh" --accent none ;;
            Pink) "$script_dir/theme_apply.sh" --accent pink ;;
            Blue) "$script_dir/theme_apply.sh" --accent blue ;;
            "Wallpaper Auto") "$script_dir/theme_apply.sh" --accent wallpaper ;;
            *) exit 0 ;;
        esac
        ;;
    *)
        printf 'Usage: %s base|accent\n' "$0" >&2
        exit 2
        ;;
esac
