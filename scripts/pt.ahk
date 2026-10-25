;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%

global StartStopKey, shootKey, jumpKey, aimKey, meleeKey, sleepTime := 2000 / fps

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Macro.start("PT")
Bind(StartStopKey, "StartStop")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop() {
    Status("PEPE")

    While Held(StartStopKey) {
        SendKey(shootKey, "Down")
        Wait(550)
        SendKey(shootKey, "Up")

        Wait(sleepTime)
        ZawThrow()
    }

    Status()
}

ZawThrow() {
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
}
