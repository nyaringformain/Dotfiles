# Theme System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the base-theme and accent system described in `docs/superpowers/specs/2026-06-27-theme-system-design.md`.

**Architecture:** A small shell library owns theme state, palette resolution, wallpaper accent extraction, and generation of tool-specific color files. Thin shell entrypoints expose Rofi menus, weather output, and theme application. Existing Hyprland, Waybar, Rofi, and wallpaper scripts consume the generated files.

**Tech Stack:** Bash, Rofi, Hyprland config, Waybar JSON/CSS, GTK CSS color definitions, Rasi variables, wttr.in via curl.

---

### Task 1: Theme Generation Tests

**Files:**
- Create: `tests/theme_system_test.sh`

- [ ] **Step 1: Write failing tests**

Create a Bash test runner that uses a temporary `HOME`, overrides theme output paths with environment variables, and verifies these behaviors:

- `theme_apply.sh --base mono --accent none --no-reload` writes `BASE_THEME=mono`, `ACCENT=none`, grayscale CSS/Rasi colors, and grayscale Hyprland borders.
- Changing only base preserves the current accent.
- `accent=wallpaper` uses the current wallpaper path file and a fake `magick` command to extract `#123456`.
- Missing wallpaper extraction falls back to fixed blue `#89b4fa`.
- Weather script prints `--` when `curl` fails.

- [ ] **Step 2: Run tests to verify they fail**

Run:

```bash
bash tests/theme_system_test.sh
```

Expected: failure because theme scripts do not exist yet.

### Task 2: Theme Library And Apply Script

**Files:**
- Create: `.config/viegphunt/theme_lib.sh`
- Create: `.config/viegphunt/theme_apply.sh`
- Modify: `.config/colors/colors.css`
- Modify: `.config/colors/colors.rasi`
- Create: `.config/hypr/conf/theme.conf`

- [ ] **Step 1: Implement state and palette functions**

Add functions to:

- Read and write `~/.cache/viegphunt/theme_state`.
- Default to `BASE_THEME=catppuccin`, `ACCENT=pink`.
- Validate base values: `catppuccin`, `mono`.
- Validate accent values: `none`, `pink`, `blue`, `wallpaper`.
- Resolve fixed accent colors.
- Extract a wallpaper accent through `magick` or `convert`.
- Generate CSS, Rasi, and Hyprland color files.

- [ ] **Step 2: Implement theme_apply.sh**

Support:

- `--base <catppuccin|mono>`
- `--accent <none|pink|blue|wallpaper>`
- `--refresh`
- `--no-reload`

The script must preserve unspecified state fields, generate output files, and reload Hyprland/Waybar only when reload is enabled.

- [ ] **Step 3: Run tests**

Run:

```bash
bash tests/theme_system_test.sh
```

Expected: tests pass.

### Task 3: Menus, Keybindings, And Consumers

**Files:**
- Create: `.config/viegphunt/theme_menu.sh`
- Modify: `.config/hypr/conf/keybinding.conf`
- Modify: `.config/hypr/conf/appearance.conf`
- Modify: `.config/rofi/config.rasi`
- Modify: `.config/waybar/style.css`

- [ ] **Step 1: Add Rofi theme menu**

`theme_menu.sh base` should offer `Catppuccin` and `Mono`.

`theme_menu.sh accent` should offer `None`, `Pink`, `Blue`, and `Wallpaper Auto`.

Both modes should call `theme_apply.sh` with the selected value.

- [ ] **Step 2: Add Hyprland keybindings**

Add:

```text
SUPER + T       -> ~/.config/viegphunt/theme_menu.sh base
SUPER + Shift+T -> ~/.config/viegphunt/theme_menu.sh accent
```

- [ ] **Step 3: Source generated Hyprland colors**

`appearance.conf` should source `~/.config/hypr/conf/theme.conf` and use generated `$active_border` and `$inactive_border` variables.

- [ ] **Step 4: Update Rofi and Waybar styles**

Rofi and Waybar should use generated `@accent`, `@select`, and `@bordercolor` variables instead of hardcoded pink/blue highlights.

### Task 4: Wallpaper And Weather Integration

**Files:**
- Create: `.config/viegphunt/weather.sh`
- Modify: `.config/waybar/config`
- Modify: `.config/viegphunt/wallpaper_select.sh`
- Modify: `.config/viegphunt/wallpaper_random.sh`
- Modify: `.config/viegphunt/wallpaper_effects.sh`
- Modify: `.config/hypr/conf/autostart.conf`

- [ ] **Step 1: Add weather script**

`weather.sh` should call `wttr.in` with a short timeout and print `--` if weather cannot be fetched.

- [ ] **Step 2: Add Waybar weather module**

Add `custom/weather` to the right-side module list.

- [ ] **Step 3: Track current wallpaper**

After applying a selected or random wallpaper, write its absolute path to `~/.cache/current_wallpaper` and refresh the theme.

- [ ] **Step 4: Make wallpaper_effects read the tracked path**

Prefer `~/.cache/current_wallpaper`, then fall back to `awww query`.

- [ ] **Step 5: Apply theme before Waybar startup**

Run `theme_apply.sh --refresh --no-reload` before starting Waybar in Hyprland autostart.

### Task 5: Verification

**Files:**
- Verify all modified files.

- [ ] **Step 1: Run automated tests**

Run:

```bash
bash tests/theme_system_test.sh
```

Expected: all tests pass.

- [ ] **Step 2: Run shell syntax checks**

Run:

```bash
bash -n .config/viegphunt/theme_lib.sh .config/viegphunt/theme_apply.sh .config/viegphunt/theme_menu.sh .config/viegphunt/weather.sh .config/viegphunt/wallpaper_select.sh .config/viegphunt/wallpaper_random.sh .config/viegphunt/wallpaper_effects.sh
```

Expected: exit code 0.

- [ ] **Step 3: Inspect key generated config snippets**

Run:

```bash
sed -n '1,120p' .config/colors/colors.css
sed -n '1,120p' .config/colors/colors.rasi
sed -n '1,80p' .config/hypr/conf/theme.conf
```

Expected: generated files contain Catppuccin defaults and fixed pink accent.
