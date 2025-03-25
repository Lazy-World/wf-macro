#Requires AutoHotkey v2.0

; Debug include
#include %A_ScriptDir%/..

#include lib\headers.ahk
#include lib\time.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
settingsJson    := FileRead(A_ScriptDir "\..\cfg\sttings.json")
macroJson       := FileRead(A_ScriptDir "\..\cfg\test.json")

global g_key      := json_load(&settingsJson)
global g_macro    := json_load(&macroJson)

for hotkeyFunction, hotkeyCombination in g_macro["hotkeys"] {
    Hotkey("*" . hotkeyCombination, %hotkeyFunction%)
}

return

AntiDesync(*) {
    MsgBox("AntiDesync activated!")
}

EnergyDrain(*) {
    MsgBox("EnergyDrain activated!" )
}

*F1::{                      
    local before := GetQPC()                                                            
    
    SendInput "{" g_macro["keys"]["tab"] "}"

    local after := GetQPC()
    MsgBox(1000 * (after - before) / Frequency)
}

*Insert::Reload
*Del::ExitApp