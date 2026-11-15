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

sleepTime := 2000 / fps

guiLabel := "PT"
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
    status.text := "PEPE"

    While GetKeyState(StartStopKey, "P") {
        SendKey(shootKey, "Down")
        Wait(550)
        SendKey(shootKey, "Up")

        Wait(sleepTime)
        Gosub, ZawThrow
    }

    status.reset()
return

ZawThrow:
    SendKey(jumpKey)
    Wait(sleepTime)
    SendKey(jumpKey)
    Wait(sleepTime)
    SendKey(aimKey, "Down")
    Wait(sleepTime)
    SendKey(meleeKey)
    Wait(sleepTime)
    SendKey(aimKey, "Up")
    Wait(sleepTime)
return

#include %A_ScriptDir%\..\lib\group.ahk
