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

castInterval := DelayBetweenCasts * 1000

guiLabel := "SCULP"
#include misc\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%StartKey%, Start
Hotkey, *%StopKey%, Stop
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Start:
    Gosub, CastAbility
    Gosub, UpdateTimer
    SetTimer, CastAbility, %castInterval%
    SetTimer, UpdateTimer, 100
return

Stop:
    SetTimer, CastAbility, Off
    SetTimer, UpdateTimer, Off
    status.reset()
return

CastAbility:
    SendInput, {Blind}{%AbilityKey%}
    nextCastAt := A_TickCount + castInterval
return

UpdateTimer:
    status.text := Round(Max(0, nextCastAt - A_TickCount) / 1000, 1) . "s"
return

#include misc\misc.ahk
