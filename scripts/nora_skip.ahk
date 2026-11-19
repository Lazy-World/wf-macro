;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 UI                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
status.new_text("key", "X:", "main", "left x10 ym")
status.new_text("value", "", "accent", "left x" (10 + status.measure("key")[1] + 15) " yp")

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
    status.edit_text("value", "skip")

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

    status.edit_text("value", "")
return

MapClick:
    status.edit_text("value", "m")
    Hold("m", 400, 100)

    BlockInput, MouseMove
    BlockInput, On
    Send {Click 2133 1269}

    SendKey("vk01", "Down")
    Wait(100)
    SendKey("vk01", "Up")
    BlockInput, Off
    BlockInput, MouseMoveOff

    status.edit_text("value", "")
return
