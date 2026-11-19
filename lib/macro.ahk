;; Macro - the shared beginning of every macro. Include it instead of the
;; headers / core / joiner / ui block, after the script's cfg:
;;
;;   #include %A_ScriptDir%\..\presets\game_settings.ahk
;;   #include %A_ScriptDir%\cfg\cfg_%A_Scriptname%
;;   #include %A_ScriptDir%\..\lib\macro.ahk
;;
;; Creates the super-globals `ui` (UiManager) and `status` (a plain UiWindow,
;; shown at once - write its body yourself):
;;
;;   status.new_text("msg", "GO", "main", "auto")
;;   status.edit_text("msg", "work")
;;
;; Joins the joiner group, binds the group keys (reload / unload / pause) and
;; gates every hotkey below to the game window. The status outline turns grey
;; while the group is paused. A second window is just ui.new_window(...).
;;
;; Everything here runs at include time, so the script reads top to bottom.

#include %A_LineFile%\..\headers.ahk
#include %A_LineFile%\..\core.ahk
#include %A_LineFile%\..\joiner.ahk
#include %A_LineFile%\..\ui.ahk
#include %A_LineFile%\..\wf.ahk

global ui, status, _StatusOutline
ui     := new UiManager()
status := ui.new_window("status", new UiVector(_MacroX(), _MacroY()), new UiVector(120, 25)
    , {blur: 1, outline: [1, 1, 1, 1]})
_StatusOutline := status.outline_color
status.show()

Joiner.join(Func("_MacroLayout"))

Hotkey, *%MiscReloadMacroKey%, _MiscReload
Hotkey, *%MiscUnloadMacroKey%, _MiscUnload
Hotkey, *%MiscPauseKey%, _MiscPause
; Everything below this point is bound only while the game is active
Hotkey, IfWinActive, ahk_exe Warframe.x64.exe
#IfWinActive ahk_exe Warframe.x64.exe

_MacroX() {
    return Ceil(A_ScreenWidth * 0.0066)
}

_MacroY() {
    return Ceil(A_ScreenHeight * 0.47)
}

; slot 1 = the topmost macro; the stack keeps launch order
_MacroLayout(slot, count, paused) {
    global status, _StatusOutline
    status.move_to(_MacroX(), _MacroY() + (slot - 1) * (status.size.y + 4))
    status.outline_color := paused ? "666666" : _StatusOutline
    status.set_outline(status.outline)
}

;; Group keys. Functions, not labels: a label would end the script's
;; auto-execute section, and the script's own code follows this include.
;; Suspend, Permit keeps them alive while the group is paused.

_MiscReload() {
    Suspend, Permit
    Joiner.reload()
}

_MiscUnload() {
    Suspend, Permit
    Joiner.exit()
}

_MiscPause() {
    Suspend, Permit
    Joiner.pause(!Joiner.paused)
}
