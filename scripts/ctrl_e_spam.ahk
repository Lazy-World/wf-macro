;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\..\lib\headers.ahk
#include %A_ScriptDir%\..\lib\core.ahk
#include %A_ScriptDir%\..\lib\joiner.ahk
#include %A_ScriptDir%\..\lib\ui.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%

guiLabel := "MELEE"
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%StartStopKey%, StartStop
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop:
    status.text := "+W"
    SendKey(meleeKey, "Down")

    While GetKeyState(StartStopKey, "P") {
        SendKey(crouchKey, "Down")
        Wait(230)
        SendKey(crouchKey, "Up")
        Wait(230)
    }

    SendKey(meleeKey, "Up")
    status.reset()
return

#include %A_ScriptDir%\..\lib\group.ahk
