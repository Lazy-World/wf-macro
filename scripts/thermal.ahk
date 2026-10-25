;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%

global ThermalKey, skillKey := 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Macro.start(skillKey)
Bind(ThermalKey, "StartStop")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop() {
    While Held(ThermalKey) {
        Status("HOLD")
        Hold(skillKey, 500)
        Wait(500)

        Status("TAP")
        SendKey(skillKey)
        Wait(500)
    }

    Status()
}
