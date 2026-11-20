;; Macro - the shared beginning of every macro. Include it instead of the
;; headers / core / joiner / ui block, after the script's cfg:
;;
;;   #include %A_ScriptDir%\..\presets\game_settings.ahk
;;   #include %A_ScriptDir%\cfg\cfg_%A_Scriptname%
;;   #include %A_ScriptDir%\..\lib\macro.ahk
;;
;; Creates the super-globals `ui` (UiManager), `status_head` (the hat over the
;; stack) and `status` (the macro's own row). A macro fills its row explicitly:
;;
;;   status.new_text("key", "HILDR:", "main", "left x6 ym")
;;   status.new_text("value", "", "accent", "left x" (6 + status.measure("key")[1] + 6) " yp")
;;   status.edit_text("value", "work")
;;
;; Joins the joiner group, binds the group keys (reload / unload / pause) and
;; gates every hotkey below to the game window. The hat shows "suspended"
;; while the group is paused. A second window is just ui.new_window(...).
;;
;; Everything here runs at include time, so the script reads top to bottom.

#include %A_LineFile%\..\headers.ahk
#include %A_LineFile%\..\core.ahk
#include %A_LineFile%\..\joiner.ahk
#include %A_LineFile%\..\ui.ahk
#include %A_LineFile%\..\wf.ahk

global ui, status, status_head
_MacroW := 130, _MacroHeadH := 22, _MacroRowH := 25, _MacroGap := 4

ui := new UiManager()
status_head := ui.new_window("status.head", new UiVector(_MacroX(), _MacroY()), new UiVector(_MacroW, _MacroHeadH)
    , {margin: 2, blur: 1, outline: [0, 1, 0, 0]})
status_head.new_text("icon", "D", "menu_icon", "auto")
status := ui.new_window("status", new UiVector(_MacroX(), _MacroY() + _MacroHeadH + _MacroGap)
    , new UiVector(_MacroW, _MacroRowH), {blur: 1, outline: [0, 0, 0, 1]})

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

; slot 1 = the topmost macro; the stack keeps launch order.
; The hat belongs to slot 1, a body closes the stack only when it is last.
_MacroLayout(slot, count, paused) {
    global status, status_head, _MacroHeadH, _MacroGap
    status_head.move_to(_MacroX(), _MacroY()).resize_to(status.size.x, _MacroHeadH)
    status_head.edit_text("icon", paused ? "suspended" : "D")
    if (slot = 1)
        status_head.show()
    else
        status_head.hide()
    status.set_outline(slot = count ? [0, 0, 0, 1] : [1, 0, 1, 0]
        , new UiVector(_MacroX(), _MacroY() + _MacroHeadH + _MacroGap + (slot - 1) * (status.size.y + _MacroGap)))
    status.show()
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
