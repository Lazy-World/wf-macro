;; Macro - the visible setup every macro includes after its cfg:
;;   guiLabel := "MELEE"
;;   #include %A_ScriptDir%\..\lib\macro.ahk
;;
;; Creates the super-global `status` window, binds the group keys
;; (reload / unload / pause) and gates every hotkey below to the game window.
;; Group keys come from the globals MiscReloadMacroKey / MiscUnloadMacroKey / MiscPauseKey.
;;
;;   status.text := "work"           ; body value of the status window
;;   status.reset()                  ; back to idle
;;
;; Expects lib\headers.ahk, lib\core.ahk, lib\joiner.ahk and lib\ui.ahk to be
;; included before it. Script hotkeys go after this include.

global status
status := new UiStatusWindow(Ceil(A_ScreenWidth * 0.0066), Ceil(A_ScreenHeight * 0.47), guiLabel, {show: false})
Joiner.join(Func("MacroLayout"))

;; The group handlers live in lib\group.ahk: it is included at the very end of
;; every macro, because a label ends the script's auto-execute section.
Hotkey, *%MiscReloadMacroKey%, MiscReloadMacro
Hotkey, *%MiscUnloadMacroKey%, MiscUnloadMacro
Hotkey, *%MiscPauseKey%, MiscPause
; Everything below this point is bound only while the game is active
Hotkey, IfWinActive, ahk_exe Warframe.x64.exe
#IfWinActive ahk_exe Warframe.x64.exe

MacroLayout(slot, count, paused) {
    global status
    status.suspended := paused
    status.place(slot, slot = count)
}
