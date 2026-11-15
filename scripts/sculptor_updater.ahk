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

castInterval := DelayBetweenCasts * 1000
nextCastAt := 0

guiLabel := "SCULP"
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%StartKey%, Start
Hotkey, *%StopKey%, Stop
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Casts at once, then every DelayBetweenCasts seconds.
; A new Start restarts the cycle
Start:
    Gosub, CastAbility
    SetTimer, CastAbility, %castInterval%
    SetTimer, ShowCountdown, 100
    Gosub, ShowCountdown
return

Stop:
    SetTimer, CastAbility, Off
    SetTimer, ShowCountdown, Off
    status.reset()
return

CastAbility:
    SendKey(AbilityKey)
    nextCastAt := A_TickCount + castInterval
return

ShowCountdown:
    status.text := Round(Max(0, nextCastAt - A_TickCount) / 1000, 1) . "s"
return

#include %A_ScriptDir%\..\lib\group.ahk
