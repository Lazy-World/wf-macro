#include %A_ScriptDir%/..

#include presets\game_settings.ahk

#include lib\headers.ahk
#include lib\ui.ahk
#include lib\joiner.ahk
#include lib\timers.ahk
#include lib\utils.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%
#include cfg\cfg_%A_Scriptname%

guiLabel := "X"
#include misc\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%SkipKey%, SkipViaNora
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipViaNora:
    status.text := "skip"
    
    SendKey("Esc")
    lSleep(350)

    BlockInput, MouseMove
    ResetCursor()
    MouseMove(Ceil(gScreen[1] * 0.74), Ceil(gScreen[2] * 0.55))

    SendKey("vk01", "Down")
    lSleep(200)
    SendKey("vk01", "Up")
    
    BlockInput, MouseMoveOff
    lSleep(300)

    SendKey("Esc")
    lSleep(150)
    SendKey("Esc")

    status.reset()
Return

*F1::
    status.text := "m"
    HoldKey("m", 400, 100)

    BlockInput, MouseMove
    BlockInput On
    Send {Click 2133 1269}

    SendKey("vk01", "Down")
    lSleep(100)
    SendKey("vk01", "Up")
    BlockInput Off
    BlockInput, MouseMoveOff

    status.reset()
Return

*F2::
    status.text := "m"
    HoldKey("m", 400, 100)

    BlockInput, MouseMove
    BlockInput On
    Send {Click 2133 1269}

    SendKey("vk01", "Down")
    lSleep(100)
    SendKey("vk01", "Up")
    BlockInput Off
    BlockInput, MouseMoveOff

    status.reset()
Return

#include misc\misc.ahk
