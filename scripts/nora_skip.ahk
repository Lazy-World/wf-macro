 #include %A_ScriptDir%/..

#include presets\game_settings.ahk

#include lib\headers.ahk
#include lib\ui.ahk
#include lib\timers.ahk
#include lib\utils.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%
#include cfg\cfg_%A_Scriptname%
#include misc\ui_theme.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%MiscReloadMacroKey%, MiscReloadMacro
Hotkey, *%MiscUnloadMacroKey%, MiscUnloadMacro
Hotkey, *%MiscPauseKey%, MiscPause

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include misc\require_warframe.ahk
Hotkey, *%SkipKey%, SkipViaNora

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
guiLabel := "X"
#include misc\gui.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SkipViaNora:
    status.text := "skip"
    
    SendInput {Blind}{Esc}
    lSleep(350)

    BlockInput, MouseMove
    ResetCursor()
    MouseMove(Ceil(gScreen[1] * 0.74), Ceil(gScreen[2] * 0.55))

    Send, {vk01 Down}
    lSleep(200)
    Send, {vk01 Up}
    
    BlockInput, MouseMoveOff
    lSleep(300)

    SendInput {Blind}{Esc}
    lSleep(150)
    SendInput {Blind}{Esc}

    status.text := "X"
Return

*F1::
    status.text := "m"
    HoldKey("m", 400, 100)

    BlockInput, MouseMove
    BlockInput On
    Send {Click 2133 1269}

    Send, {vk01 Down}
    lSleep(100)
    Send, {vk01 Up}
    BlockInput Off
    BlockInput, MouseMoveOff

    status.text := "X"
Return

*F2::
    status.text := "m"
    HoldKey("m", 400, 100)

    BlockInput, MouseMove
    BlockInput On
    Send {Click 2133 1269}

    Send, {vk01 Down}
    lSleep(100)
    Send, {vk01 Up}
    BlockInput Off
    BlockInput, MouseMoveOff

    status.text := "X"
Return

#include misc\misc.ahk
