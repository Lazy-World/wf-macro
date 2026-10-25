;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%

global SkipKey

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Macro.start("X")
Bind(SkipKey, "SkipViaNora")
Bind("F1", "MapClick")
Bind("F2", "MapClick")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipViaNora() {
    Status("skip")

    SendKey("Esc")
    Wait(350)

    BlockInput, MouseMove
    MouseCenter()
    MouseNudge(Ceil(GameScreen.w * 0.74), Ceil(GameScreen.h * 0.55))

    SendKey("vk01", "Down")
    Wait(200)
    SendKey("vk01", "Up")

    BlockInput, MouseMoveOff
    Wait(300)

    SendKey("Esc")
    Wait(150)
    SendKey("Esc")

    Status()
}

MapClick() {
    Status("m")
    Hold("m", 400, 100)

    BlockInput, MouseMove
    BlockInput, On
    Send {Click 2133 1269}

    SendKey("vk01", "Down")
    Wait(100)
    SendKey("vk01", "Up")
    BlockInput, Off
    BlockInput, MouseMoveOff

    Status()
}
