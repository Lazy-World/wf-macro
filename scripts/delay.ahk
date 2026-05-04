#Requires AutoHotkey v2.0

; Debug include
#include %A_ScriptDir%/..

#include lib\headers.ahk
#include lib\json.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
macro_json       := FileRead(A_ScriptDir "\cfg\" StrReplace(A_ScriptName, ".ahk", "") ".json")
global g_macro    := json_load(&macro_json)

for hotkeyFunction, hotkeyCombination in g_macro["hk"] {
    Hotkey("*" . hotkeyCombination["key"], %hotkeyFunction%)
}
return

testDelay(*) {
    if !g_macro["val"]["enableTest"]["val"]
        return
                                                         
    SendInput "{" g_macro["keys"]["tab"] "}"
    Sleep(g_macro["val"]["sleep1"]["val"])
}

*Insert::Reload
*Del::ExitApp