#Requires AutoHotkey v2.0

; Debug include
#include %A_ScriptDir%/..

#include lib\headers.ahk
#include lib\time.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
settings_json    := FileRead(A_ScriptDir "\cfg\general_binds.json")
macro_json       := FileRead(A_ScriptDir "\cfg\empty_ahk.json")

global g_key      := json_load(&settings_json)
global g_macro    := json_load(&macro_json)

for hotkeyFunction, hotkeyCombination in g_macro["hotkeys"] {
    Hotkey("*" . hotkeyCombination, %hotkeyFunction%)
}

return

testDelay(*) {
    local before := GetQPC()                                                            
    
    SendInput "{" g_macro["keys"]["tab"] "}"

    local after := GetQPC()
    MsgBox(1000 * (after - before) / Frequency)
}

*Insert::Reload
*Del::ExitApp