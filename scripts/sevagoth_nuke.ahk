;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%

global NukeKey, DelayBetweenCasts, firstAKey, secondAKey

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Macro.start("SEVA")
Bind(NukeKey, "StartStop")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop() {
    Status("..")
    SendKey(secondAKey)
    Wait(DelayBetweenCasts)

    Status("...")
    SendKey(firstAKey)
    Wait(DelayBetweenCasts)

    Status()
}
