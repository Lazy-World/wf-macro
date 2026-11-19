# wf-macro

AutoHotkey **v1.1** macros for Warframe (`C:\Program Files\AutoHotkey\v1.1.37.02\AutoHotkeyU64.exe`). Read this before editing; most of it is not obvious from the code.

## Never launch a repo script as a test

Running the macros in-game is the user's job. A macro binds global hotkeys, uses `#SingleInstance Force` (which kills a running instance of itself), posts to the joiner group, and can send input to the game. "Just run it to see if it parses" is not safe.

Safe checks instead:

1. **Syntax + include chain** for every script (compiles, does not execute):

   ```
   "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in <script.ahk> /out <temp>\x.exe /base "C:\Program Files\AutoHotkey\v1.1.37.02\Unicode 64-bit.bin" /silent
   ```

2. **Runtime of the shared bootstrap** — a throwaway file under `%TEMP%`, never in the repo. It joins the group for a few milliseconds, so don't run it while a macro is in active use:

   ```ahk
   MiscReloadMacroKey := "F24"
   MiscUnloadMacroKey := "F23"
   MiscPauseKey := "F22"
   #include D:\__git\personal\wf-macro\lib\macro.ahk

   status.new_text("key", "TEST:", "main", "left x10 ym")
   status.new_text("value", "", "accent", "left x" (10 + status.measure("key")[1] + 15) " yp")
   status.edit_text("value", "TEST")
   ExitApp
   ```

   Run it with `/ErrorStdOut` and check stderr + exit code.

## Git Bash gotcha

Git Bash rewrites `/ErrorStdOut` into `D:/.../ErrorStdOut`, and AHK then opens a blocking "Script file not found" dialog. Always run with `MSYS_NO_PATHCONV=1` and Windows paths (`cygpath -w`), or use PowerShell.

## AHK v1 facts that shaped the design

- Function definitions do **not** end the auto-execute section; labels do. `lib/macro.ahk` is included at the top and ends with functions, so script code after it still runs. Never put a label in a top-level include.
- `Hotkey, *%Key%, FunctionName` works with a function defined later in the same file (verified by firing). Keep group handlers as functions; a label would end the auto-execute section.
- Group handlers start with `Suspend, Permit` so they still work while the group is paused.
- Duplicate `#Include` of the same file (`core.ahk` from several libs) is deduplicated by path; the compile check confirms the chain.
- `#IfWinActive` / `Hotkey, IfWinActive` apply textually. Group keys are bound before the gate; script hotkeys after it are game-only.
- `WinSet` acts on the calling thread's Last Found Window. Any new `WinSet` in `lib/ui.ahk` must pass `ahk_id %h%` (see `UiLine.set_color`).

## Structure

- `lib/headers.ahk` — directives and process settings.
- `lib/core.ahk` — 1:1 wrappers over native AHK (`Wait`, `SendKey`, `Hold`, `MouseCenter`). Nothing game-specific.
- `lib/wf.ahk` — Warframe-only helpers (`WfActive`, `PixelSeen`).
- `lib/ui.ahk` — overlay widgets (`UiWindow`, `UiText`, `UiSlider`, ...).
- `lib/joiner.ahk` — runs all launched macros as one group (pause / reload / exit, stacking order).
- `lib/macro.ahk` — the shared beginning: includes the libs above, creates `ui`, `status` and its hat `status_head`, joins the group, binds group keys, gates hotkeys to the game.
- `scripts/<name>.ahk` — a macro; `scripts/cfg/cfg_<name>.ahk` — its settings (data only).

Include order is fixed: `presets/game_settings.ahk` → `cfg` → `lib/macro.ahk`. Do not add the lib includes back to scripts.

Keep scripts explicit: three includes, a UI block, hotkeys, label handlers. No bootstrap class, no `Macro.begin()`, no template status. The status is a plain `UiWindow`: each macro adds its own `key` and `value` texts (white `main` left, yellow `accent` after it) and sets the value with `edit_text("value", ...)`; the hat shows `suspended` while the group is paused.

## Known limitation

Stack position uses each window's own height, so windows of different heights drift apart in the group. If needed: publish the height in the joiner marker title and use a cumulative offset.
