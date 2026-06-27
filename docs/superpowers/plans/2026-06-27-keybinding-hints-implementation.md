# Keybinding Hints Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep `SUPER+H` keybinding hints aligned with the real Hyprland keybindings and add dedicated full/region screenshot shortcuts.

**Architecture:** Existing Hyprland bindings remain the source of truth. A shell test checks that important bindings and hint labels stay aligned. `key_hints.sh` remains a Yad table, but its rows are grouped by workflow so daily controls are easier to scan.

**Tech Stack:** Bash, Hyprland config, Yad.

---

### Task 1: Tests

**Files:**
- Modify: `tests/hypr_config_test.sh`

- [ ] Add assertions that `SUPER+Print` runs a full screenshot command and `SUPER+Shift+Print` runs a region screenshot command.
- [ ] Add assertions that `key_hints.sh` contains rows for theme base, accent, wallpaper, clipboard, emoji, full screenshot, and region screenshot.
- [ ] Run `bash tests/hypr_config_test.sh` and confirm it fails before implementation.

### Task 2: Keybindings

**Files:**
- Modify: `.config/hypr/conf/keybinding.conf`

- [ ] Replace the old `SUPER+Shift+S` region screenshot binding with:
  - `SUPER+Print`: full screenshot.
  - `SUPER+Shift+Print`: region screenshot.
- [ ] Keep output directory as `$HOME/Pictures/Screenshots`.

### Task 3: Hints

**Files:**
- Modify: `.config/viegphunt/key_hints.sh`

- [ ] Reorganize hints into practical groups: launchers, window/session, appearance/tools, workspaces, media.
- [ ] Include the new theme, wallpaper, clipboard, emoji, and screenshot shortcuts.
- [ ] Keep the Yad table implementation and existing `SUPER+H` entrypoint.

### Task 4: Verification

**Files:**
- Verify modified files.

- [ ] Run `bash tests/hypr_config_test.sh`.
- [ ] Run `bash tests/theme_system_test.sh`.
- [ ] Run `bash -n .config/viegphunt/key_hints.sh tests/hypr_config_test.sh`.
- [ ] Run `git diff --check`.
