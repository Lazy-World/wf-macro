;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%
#include %A_ScriptDir%\..\lib\macro.ahk

sleepTime := 2000 / fps

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 UI                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
status.new_text("msg", "PT", "title", "auto")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%StartStopKey%, StartStop
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop:
    status.edit_text("msg", "PEPE")

    While GetKeyState(StartStopKey, "P") {
        SendKey(shootKey, "Down")
        Wait(550)
        SendKey(shootKey, "Up")

        Wait(sleepTime)
        Gosub, ZawThrow
    }

    status.edit_text("msg", "PT")
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
