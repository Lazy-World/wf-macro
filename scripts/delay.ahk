#Requires AutoHotkey v2.0

; Debug include
#include %A_ScriptDir%/..

#include lib\headers.ahk
#include lib\time.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
settings_json    := FileRead(A_ScriptDir "\cfg\general_binds.json")
macro_json       := FileRead(A_ScriptDir "\cfg\" StrReplace(A_ScriptName, ".ahk", "") ".json")

global g_key      := json_load(&settings_json)
global g_macro    := json_load(&macro_json)

for hotkeyFunction, hotkeyCombination in g_macro["hk"] {
    Hotkey("*" . hotkeyCombination["key"], %hotkeyFunction%)
}
return

testDelay(*) {
    if !g_macro["val"]["enableTest"]["val"]
        return

    local before := GetQPC()                                                            
    
    SendInput "{" g_macro["keys"]["tab"] "}"

    local after := GetQPC()
    MsgBox(1000 * (after - before) / Frequency)
    lSleep(g_macro["val"]["sleep1"]["val"])
}

*Insert::Reload
*Del::ExitApp