#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
keybinding_conf="$repo_root/.config/hypr/conf/keybinding.conf"

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

if grep -Eq '^[[:space:]]*bind[[:space:]]*=.*,[[:space:]]*togglesplit[[:space:]]*,' "$keybinding_conf"; then
    fail "Use 'layoutmsg, togglesplit' instead of deprecated standalone 'togglesplit' dispatcher"
fi

grep -Fq 'bind = $mainMod, J, layoutmsg, togglesplit' "$keybinding_conf" \
    || fail "Expected SUPER+J to dispatch layoutmsg togglesplit"

printf 'Hyprland config tests passed\n'
