#Requires AutoHotkey v2.0

; Debug include
#include %A_ScriptDir%/..

#include lib\headers.ahk
#include lib\json.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global g_macro := Cfg.FromFile(A_ScriptDir "\cfg\" StrReplace(A_ScriptName, ".ahk", "") ".json")

for fn, combo in g_macro.Hotkeys()
    Hotkey "*" combo, %fn%
return

testDelay(*) {
    if !g_macro.V("enableTest")
        return

    SendInput "{" g_macro.Get("keys.tab") "}"
    Sleep g_macro.V("sleep1")
}

*Insert::Reload
*Del::ExitApp
