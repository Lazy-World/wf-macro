;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%

global StartKey, StopKey, AbilityKey, DelayBetweenCasts, cast, countdown

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Macro.start("SCULP")
Bind(StartKey, "Start")
Bind(StopKey, "Stop")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Casts at once, then every DelayBetweenCasts seconds.
; A new Start restarts the cycle: the replaced tickers stop on release
Start() {
    cast := Every(DelayBetweenCasts * 1000, "SendKey", AbilityKey).fire()
    countdown := Every(100, "ShowCountdown").fire()
}

Stop() {
    cast.stop()
    countdown.stop()
    Status()
}

ShowCountdown() {
    Status(Round(cast.left / 1000, 1) . "s")
}
