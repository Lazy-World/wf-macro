;; Shared macro setup: theme, group binds (reload / unload / pause),
;; the status window and the Warframe gate.
;; Include after lib\ and cfg\, with `guiLabel` set beforehand.
;; Exposes the window as the super-global `status`:
;;   status.text := "..."   ; body value, read it back with status.text
;;   status.reset()         ; body value back to "off"
;; Ends with the Warframe gate (misc\require_warframe.ahk): script hotkeys go after it.
#include misc\ui_theme.ahk

Hotkey, *%MiscReloadMacroKey%, MiscReloadMacro
Hotkey, *%MiscUnloadMacroKey%, MiscUnloadMacro
Hotkey, *%MiscPauseKey%, MiscPause

global status := new StatusWindow(Ceil(gScreen[1] * 0.0066), Ceil(gScreen[2] * 0.47), guiLabel, {"show": false})
Joiner.join(Func("MacroLayout"))

MacroLayout(slot, count, paused) {
    status.suspended := paused
    status.place(slot, slot = count)
}

#include misc\require_warframe.ahk
