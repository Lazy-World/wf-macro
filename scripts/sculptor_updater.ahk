;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%
#include %A_ScriptDir%\..\lib\macro.ahk

castInterval := DelayBetweenCasts * 1000
nextCastAt := 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 UI                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
status.new_text("msg", "SCULP", "title", "auto")

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
    status.edit_text("msg", "SCULP")
return

CastAbility:
    SendKey(AbilityKey)
    nextCastAt := A_TickCount + castInterval
return

ShowCountdown:
    status.edit_text("msg", Round(Max(0, nextCastAt - A_TickCount) / 1000, 1) . "s")
return
