#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

export HOME="$tmpdir/home"
export VIEGPHUNT_THEME_STATE="$tmpdir/state/theme_state"
export VIEGPHUNT_COLORS_DIR="$tmpdir/colors"
export VIEGPHUNT_HYPR_THEME_FILE="$tmpdir/hypr/theme.conf"
export VIEGPHUNT_CURRENT_WALLPAPER="$tmpdir/current_wallpaper"
mkdir -p "$HOME" "$tmpdir/bin"

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_file_contains() {
    local file="$1"
    local expected="$2"
    grep -Fq "$expected" "$file" || fail "Expected '$file' to contain '$expected'"
}

run_theme() {
    "$repo_root/.config/viegphunt/theme_apply.sh" "$@"
}

install_fake_viegphunt_hooks() {
    mkdir -p "$HOME/.config/viegphunt"
    cat > "$HOME/.config/viegphunt/wallpaper_effects.sh" <<'SCRIPT'
#!/usr/bin/env bash
printf 'effects\n' >> "$HOME/hook.log"
SCRIPT
    cat > "$HOME/.config/viegphunt/theme_apply.sh" <<'SCRIPT'
#!/usr/bin/env bash
printf 'theme\n' >> "$HOME/hook.log"
SCRIPT
    chmod +x "$HOME/.config/viegphunt/wallpaper_effects.sh" "$HOME/.config/viegphunt/theme_apply.sh"
}

test_mono_none_generation() {
    run_theme --base mono --accent none --no-reload

    assert_file_contains "$VIEGPHUNT_THEME_STATE" "BASE_THEME=mono"
    assert_file_contains "$VIEGPHUNT_THEME_STATE" "ACCENT=none"
    assert_file_contains "$VIEGPHUNT_COLORS_DIR/colors.css" "@define-color background #0b0b0b;"
    assert_file_contains "$VIEGPHUNT_COLORS_DIR/colors.css" "@define-color accent #f5f5f5;"
    assert_file_contains "$VIEGPHUNT_COLORS_DIR/colors.rasi" "background: #0b0b0b;"
    assert_file_contains "$VIEGPHUNT_HYPR_THEME_FILE" '$active_border = rgba(f5f5f5aa)'
}

test_base_change_preserves_accent() {
    run_theme --base mono --accent blue --no-reload
    run_theme --base catppuccin --no-reload

    assert_file_contains "$VIEGPHUNT_THEME_STATE" "BASE_THEME=catppuccin"
    assert_file_contains "$VIEGPHUNT_THEME_STATE" "ACCENT=blue"
    assert_file_contains "$VIEGPHUNT_COLORS_DIR/colors.css" "@define-color background #1e1e2e;"
    assert_file_contains "$VIEGPHUNT_COLORS_DIR/colors.css" "@define-color accent #89b4fa;"
}

test_wallpaper_accent_uses_extracted_color() {
    cat > "$tmpdir/bin/magick" <<'SCRIPT'
#!/usr/bin/env bash
printf '# ImageMagick pixel enumeration: 1,1,255,srgb\n0,0: (18,52,86)  #123456  srgb(18,52,86)\n'
SCRIPT
    chmod +x "$tmpdir/bin/magick"
    PATH="$tmpdir/bin:$PATH"
    export PATH

    local wallpaper="$tmpdir/wallpaper.png"
    : > "$wallpaper"
    printf '%s\n' "$wallpaper" > "$VIEGPHUNT_CURRENT_WALLPAPER"

    run_theme --base mono --accent wallpaper --no-reload

    assert_file_contains "$VIEGPHUNT_THEME_STATE" "ACCENT=wallpaper"
    assert_file_contains "$VIEGPHUNT_COLORS_DIR/colors.css" "@define-color accent #123456;"
    assert_file_contains "$VIEGPHUNT_HYPR_THEME_FILE" '$active_border = rgba(123456aa)'
}

test_wallpaper_accent_falls_back_to_blue() {
    rm -f "$VIEGPHUNT_CURRENT_WALLPAPER"

    run_theme --base catppuccin --accent wallpaper --no-reload

    assert_file_contains "$VIEGPHUNT_COLORS_DIR/colors.css" "@define-color accent #89b4fa;"
    assert_file_contains "$VIEGPHUNT_HYPR_THEME_FILE" '$active_border = rgba(89b4faaa)'
}

test_weather_fallback() {
    cat > "$tmpdir/bin/curl" <<'SCRIPT'
#!/usr/bin/env bash
exit 22
SCRIPT
    chmod +x "$tmpdir/bin/curl"
    PATH="$tmpdir/bin:$PATH"
    export PATH

    local output
    output="$("$repo_root/.config/viegphunt/weather.sh")"
    [[ "$output" == "--" ]] || fail "Expected weather fallback '--', got '$output'"
}

test_weather_json_fallback() {
    cat > "$tmpdir/bin/curl" <<'SCRIPT'
#!/usr/bin/env bash
exit 22
SCRIPT
    chmod +x "$tmpdir/bin/curl"
    PATH="$tmpdir/bin:$PATH"
    export PATH

    local output
    output="$("$repo_root/.config/viegphunt/weather.sh" --json)"
    [[ "$output" == *'"text":"--"'* ]] || fail "Expected JSON weather text fallback, got '$output'"
    [[ "$output" == *'"tooltip":"Weather unavailable"'* ]] || fail "Expected JSON weather tooltip fallback, got '$output'"
}

test_wallpaper_select_does_not_update_state_when_awww_fails() {
    install_fake_viegphunt_hooks
    mkdir -p "$HOME/Pictures/Wallpapers"
    : > "$HOME/Pictures/Wallpapers/sample.png"
    rm -f "$VIEGPHUNT_CURRENT_WALLPAPER" "$HOME/hook.log"

    cat > "$tmpdir/bin/pidof" <<'SCRIPT'
#!/usr/bin/env bash
exit 1
SCRIPT
    cat > "$tmpdir/bin/rofi" <<'SCRIPT'
#!/usr/bin/env bash
printf 'sample\n'
SCRIPT
    cat > "$tmpdir/bin/awww" <<'SCRIPT'
#!/usr/bin/env bash
exit 44
SCRIPT
    chmod +x "$tmpdir/bin/pidof" "$tmpdir/bin/rofi" "$tmpdir/bin/awww"
    PATH="$tmpdir/bin:$PATH"
    export PATH

    if "$repo_root/.config/viegphunt/wallpaper_select.sh"; then
        fail "Expected wallpaper_select.sh to fail when awww img fails"
    fi

    [[ ! -e "$VIEGPHUNT_CURRENT_WALLPAPER" ]] || fail "wallpaper_select.sh wrote current wallpaper after awww failure"
    [[ ! -e "$HOME/hook.log" ]] || fail "wallpaper_select.sh ran follow-up hooks after awww failure"
}

test_wallpaper_random_does_not_update_state_when_awww_fails() {
    install_fake_viegphunt_hooks
    mkdir -p "$HOME/Pictures/Wallpapers"
    : > "$HOME/Pictures/Wallpapers/random.png"
    rm -f "$VIEGPHUNT_CURRENT_WALLPAPER" "$HOME/hook.log"

    cat > "$tmpdir/bin/awww" <<'SCRIPT'
#!/usr/bin/env bash
exit 44
SCRIPT
    chmod +x "$tmpdir/bin/awww"
    PATH="$tmpdir/bin:$PATH"
    export PATH

    if "$repo_root/.config/viegphunt/wallpaper_random.sh"; then
        fail "Expected wallpaper_random.sh to fail when awww img fails"
    fi

    [[ ! -e "$VIEGPHUNT_CURRENT_WALLPAPER" ]] || fail "wallpaper_random.sh wrote current wallpaper after awww failure"
    [[ ! -e "$HOME/hook.log" ]] || fail "wallpaper_random.sh ran follow-up hooks after awww failure"
}

test_theme_menu_cancel_is_successful_noop() {
    cat > "$tmpdir/bin/pidof" <<'SCRIPT'
#!/usr/bin/env bash
exit 1
SCRIPT
    cat > "$tmpdir/bin/rofi" <<'SCRIPT'
#!/usr/bin/env bash
exit 1
SCRIPT
    chmod +x "$tmpdir/bin/pidof" "$tmpdir/bin/rofi"
    PATH="$tmpdir/bin:$PATH"
    export PATH

    "$repo_root/.config/viegphunt/theme_menu.sh" base || fail "Expected base menu cancel to exit 0"
    "$repo_root/.config/viegphunt/theme_menu.sh" accent || fail "Expected accent menu cancel to exit 0"
}

test_mono_none_generation
test_base_change_preserves_accent
test_wallpaper_accent_uses_extracted_color
test_wallpaper_accent_falls_back_to_blue
test_weather_fallback
test_weather_json_fallback
test_wallpaper_select_does_not_update_state_when_awww_fails
test_wallpaper_random_does_not_update_state_when_awww_fails
test_theme_menu_cancel_is_successful_noop

printf 'All theme system tests passed\n'
