#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
keybinding_conf="$repo_root/.config/hypr/conf/keybinding.conf"
key_hints="$repo_root/.config/viegphunt/key_hints.sh"

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

if grep -Eq '^[[:space:]]*bind[[:space:]]*=.*,[[:space:]]*togglesplit[[:space:]]*,' "$keybinding_conf"; then
    fail "Use 'layoutmsg, togglesplit' instead of deprecated standalone 'togglesplit' dispatcher"
fi

grep -Fq 'bind = $mainMod, J, layoutmsg, togglesplit' "$keybinding_conf" \
    || fail "Expected SUPER+J to dispatch layoutmsg togglesplit"

grep -Fq 'bind = $mainMod, Print, exec, hyprshot -m output -o $HOME/Pictures/Screenshots' "$keybinding_conf" \
    || fail "Expected SUPER+Print full screenshot binding"

grep -Fq 'bind = $mainMod Shift, Print, exec, hyprshot -m region -o $HOME/Pictures/Screenshots' "$keybinding_conf" \
    || fail "Expected SUPER+Shift+Print region screenshot binding"

if grep -Fq 'bind = $mainMod Shift, S, exec, hyprshot' "$keybinding_conf"; then
    fail "Old SUPER+Shift+S screenshot binding should be removed"
fi

for expected_hint in \
    'Base theme selector' \
    'Accent selector' \
    'Clipboard manager' \
    'Emoji selector' \
    'Choose wallpaper' \
    'Random wallpaper' \
    'Screenshot full screen' \
    'Screenshot region'; do
    grep -Fq "$expected_hint" "$key_hints" || fail "Expected key hints to contain '$expected_hint'"
done

printf 'Hyprland config tests passed\n'
