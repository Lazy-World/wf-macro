;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%

global StartStopKey, AbilityInterval, secondAKey

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Macro.start("CYTE-09")
Bind(StartStopKey, "StartStop")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop() {
    Status(AbilityInterval)

    cast_at := Now()
    SendKey(secondAKey)

    While Held(StartStopKey) {
        if (AbilityInterval < Since(cast_at)) {
            cast_at := Now()
            SendKey(secondAKey)
        }
        Wait(50)
    }

    Status()
}
