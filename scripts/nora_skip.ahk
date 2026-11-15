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

guiLabel := "X"
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%SkipKey%, SkipViaNora
Hotkey, *F1, MapClick
Hotkey, *F2, MapClick
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipViaNora:
    status.text := "skip"

    SendKey("Esc")
    Wait(350)

    BlockInput, MouseMove
    MouseCenter()
    MouseNudge(Ceil(A_ScreenWidth * 0.74), Ceil(A_ScreenHeight * 0.55))

    SendKey("vk01", "Down")
    Wait(200)
    SendKey("vk01", "Up")

    BlockInput, MouseMoveOff
    Wait(300)

    SendKey("Esc")
    Wait(150)
    SendKey("Esc")

    status.reset()
return

MapClick:
    status.text := "m"
    Hold("m", 400, 100)

    BlockInput, MouseMove
    BlockInput, On
    Send {Click 2133 1269}

    SendKey("vk01", "Down")
    Wait(100)
    SendKey("vk01", "Up")
    BlockInput, Off
    BlockInput, MouseMoveOff

    status.reset()
return

#include %A_ScriptDir%\..\lib\group.ahk
