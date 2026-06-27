#!/usr/bin/env bash

theme_state_path() {
    printf '%s\n' "${VIEGPHUNT_THEME_STATE:-$HOME/.cache/viegphunt/theme_state}"
}

theme_colors_dir() {
    printf '%s\n' "${VIEGPHUNT_COLORS_DIR:-$HOME/.config/colors}"
}

theme_hypr_file() {
    printf '%s\n' "${VIEGPHUNT_HYPR_THEME_FILE:-$HOME/.config/hypr/conf/theme.conf}"
}

theme_current_wallpaper_file() {
    printf '%s\n' "${VIEGPHUNT_CURRENT_WALLPAPER:-$HOME/.cache/current_wallpaper}"
}

theme_normalize_base() {
    case "${1,,}" in
        catppuccin) printf 'catppuccin\n' ;;
        mono) printf 'mono\n' ;;
        *) return 1 ;;
    esac
}

theme_normalize_accent() {
    case "${1,,}" in
        none) printf 'none\n' ;;
        pink) printf 'pink\n' ;;
        blue) printf 'blue\n' ;;
        wallpaper | wallpaper-auto | wallpaper_auto) printf 'wallpaper\n' ;;
        *) return 1 ;;
    esac
}

theme_load_state() {
    BASE_THEME="catppuccin"
    ACCENT="pink"

    local state_file
    state_file="$(theme_state_path)"
    [[ -f "$state_file" ]] || return 0

    local key value normalized
    while IFS='=' read -r key value; do
        case "$key" in
            BASE_THEME)
                if normalized="$(theme_normalize_base "$value")"; then
                    BASE_THEME="$normalized"
                fi
                ;;
            ACCENT)
                if normalized="$(theme_normalize_accent "$value")"; then
                    ACCENT="$normalized"
                fi
                ;;
        esac
    done < "$state_file"
}

theme_save_state() {
    local base accent state_file
    base="$(theme_normalize_base "$1")"
    accent="$(theme_normalize_accent "$2")"
    state_file="$(theme_state_path)"

    mkdir -p "$(dirname "$state_file")"
    {
        printf 'BASE_THEME=%s\n' "$base"
        printf 'ACCENT=%s\n' "$accent"
    } > "$state_file"
}

theme_base_color() {
    local base="$1"
    local name="$2"

    case "$base:$name" in
        catppuccin:background) printf '#1e1e2e\n' ;;
        catppuccin:foreground) printf '#cdd6f4\n' ;;
        catppuccin:surface) printf '#313244\n' ;;
        catppuccin:muted) printf '#a6adc8\n' ;;
        catppuccin:border) printf '#585b70\n' ;;
        catppuccin:select) printf '#45475a\n' ;;
        catppuccin:inactive_border) printf '#595959\n' ;;
        catppuccin:pink) printf '#f5c2e7\n' ;;
        catppuccin:purple) printf '#cba6f7\n' ;;
        catppuccin:red) printf '#f38ba8\n' ;;
        catppuccin:orange) printf '#fab387\n' ;;
        catppuccin:yellow) printf '#f9e2af\n' ;;
        catppuccin:green) printf '#a6e3a1\n' ;;
        catppuccin:blue) printf '#89b4fa\n' ;;
        catppuccin:gray) printf '#45475a\n' ;;

        mono:background) printf '#0b0b0b\n' ;;
        mono:foreground) printf '#f5f5f5\n' ;;
        mono:surface) printf '#171717\n' ;;
        mono:muted) printf '#a8a8a8\n' ;;
        mono:border) printf '#4a4a4a\n' ;;
        mono:select) printf '#2a2a2a\n' ;;
        mono:inactive_border) printf '#4a4a4a\n' ;;
        mono:pink) printf '#dcdcdc\n' ;;
        mono:purple) printf '#cfcfcf\n' ;;
        mono:red) printf '#e6e6e6\n' ;;
        mono:orange) printf '#d6d6d6\n' ;;
        mono:yellow) printf '#c8c8c8\n' ;;
        mono:green) printf '#bbbbbb\n' ;;
        mono:blue) printf '#eeeeee\n' ;;
        mono:gray) printf '#3a3a3a\n' ;;
        *) return 1 ;;
    esac
}

theme_extract_wallpaper_accent() {
    local current_file wallpaper output color
    current_file="$(theme_current_wallpaper_file)"
    [[ -f "$current_file" ]] || return 1

    IFS= read -r wallpaper < "$current_file" || return 1
    [[ "$wallpaper" = /* && -f "$wallpaper" ]] || return 1

    output=""
    if command -v magick >/dev/null 2>&1; then
        output="$(magick "$wallpaper" -resize 1x1 txt:- 2>/dev/null || true)"
    elif command -v convert >/dev/null 2>&1; then
        output="$(convert "$wallpaper" -resize 1x1 txt:- 2>/dev/null || true)"
    fi

    color="$(printf '%s\n' "$output" | grep -Eom1 '#[0-9A-Fa-f]{6}' | head -n 1 || true)"
    [[ -n "$color" ]] || return 1
    printf '%s\n' "${color,,}"
}

theme_resolve_accent() {
    local base="$1"
    local accent="$2"

    case "$accent" in
        none) theme_base_color "$base" "foreground" ;;
        pink) printf '#f5c2e7\n' ;;
        blue) printf '#89b4fa\n' ;;
        wallpaper) theme_extract_wallpaper_accent || printf '#89b4fa\n' ;;
        *) return 1 ;;
    esac
}

theme_contrast_color() {
    local hex="${1#\#}"
    local upper r g b brightness
    upper="$(printf '%s' "$hex" | tr '[:lower:]' '[:upper:]')"
    r=$((16#${upper:0:2}))
    g=$((16#${upper:2:2}))
    b=$((16#${upper:4:2}))
    brightness=$(((r * 299 + g * 587 + b * 114) / 1000))

    if (( brightness > 150 )); then
        printf '#0b0b0b\n'
    else
        printf '#f5f5f5\n'
    fi
}

theme_generate_files() {
    local base accent colors_dir hypr_file
    base="$(theme_normalize_base "$1")"
    accent="$(theme_normalize_accent "$2")"
    colors_dir="$(theme_colors_dir)"
    hypr_file="$(theme_hypr_file)"

    local background foreground surface muted border base_select inactive
    local accent_hex select selected_foreground rasi_border active_raw inactive_raw
    background="$(theme_base_color "$base" background)"
    foreground="$(theme_base_color "$base" foreground)"
    surface="$(theme_base_color "$base" surface)"
    muted="$(theme_base_color "$base" muted)"
    border="$(theme_base_color "$base" border)"
    base_select="$(theme_base_color "$base" select)"
    inactive="$(theme_base_color "$base" inactive_border)"
    accent_hex="$(theme_resolve_accent "$base" "$accent")"

    if [[ "$accent" == "none" ]]; then
        select="$base_select"
        selected_foreground="$foreground"
        rasi_border="$border"
    else
        select="$accent_hex"
        selected_foreground="$(theme_contrast_color "$accent_hex")"
        rasi_border="$accent_hex"
    fi

    active_raw="${accent_hex#\#}"
    inactive_raw="${inactive#\#}"

    mkdir -p "$colors_dir" "$(dirname "$hypr_file")"

    cat > "$colors_dir/colors.css" <<EOF
/* Generated by theme_apply.sh */
@define-color background $background;
@define-color foreground $foreground;
@define-color surface $surface;
@define-color muted $muted;
@define-color select $select;
@define-color bordercolor $border;
@define-color accent $accent_hex;
@define-color selected-foreground $selected_foreground;

@define-color pink $(theme_base_color "$base" pink);
@define-color purple $(theme_base_color "$base" purple);
@define-color red $(theme_base_color "$base" red);
@define-color orange $(theme_base_color "$base" orange);
@define-color yellow $(theme_base_color "$base" yellow);
@define-color green $(theme_base_color "$base" green);
@define-color blue $(theme_base_color "$base" blue);
@define-color gray $(theme_base_color "$base" gray);
EOF

    cat > "$colors_dir/colors.rasi" <<EOF
/* Generated by theme_apply.sh */
* {
    background: $background;
    foreground: $foreground;
    surface: $surface;
    muted: $muted;
    select: $select;
    accent: $accent_hex;
    selected-foreground: $selected_foreground;

    pink: $(theme_base_color "$base" pink);
    purple: $(theme_base_color "$base" purple);
    red: $(theme_base_color "$base" red);
    orange: $(theme_base_color "$base" orange);
    yellow: $(theme_base_color "$base" yellow);
    green: $(theme_base_color "$base" green);
    blue: $(theme_base_color "$base" blue);
    gray: $(theme_base_color "$base" gray);

    active-background: @select;
    urgent-background: @red;
    urgent-foreground: @background;
    selected-background: @active-background;
    selected-urgent-background: @urgent-background;
    selected-active-background: @active-background;
    bordercolor: $rasi_border;
}
EOF

    cat > "$hypr_file" <<EOF
# Generated by theme_apply.sh
\$active_border = rgba(${active_raw}aa)
\$inactive_border = rgba(${inactive_raw}aa)
EOF
}

theme_reload_desktop() {
    if command -v hyprctl >/dev/null 2>&1; then
        hyprctl reload >/dev/null 2>&1 || true
    fi

    if command -v pgrep >/dev/null 2>&1 && command -v pkill >/dev/null 2>&1; then
        if pgrep -x waybar >/dev/null 2>&1; then
            pkill -SIGUSR2 -x waybar >/dev/null 2>&1 || true
        fi
    fi
}
