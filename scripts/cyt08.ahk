;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%

global StartStopKey, AbilityInterval, SmartMode, AmmoElement, AmmoSpot, AutoFourth, FourthKey
    , secondAKey, fourthAKey, watch, second_at

; Ammo element icon colors as [color, variation]. A new element is
; a row in `ammo` plus its name in the AmmoElement @Select of the cfg
class Cyte {
    static ammo := {"Electricity": [0xB490D3, 50], "Blast": [0xA57374, 20]}
    static recheck := 30            ; ms after pressing 2 before the ammo pixel counts again
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
if (SmartMode && !Cyte.ammo.HasKey(AmmoElement)) {
    MsgBox, 16, CYTE, Unknown AmmoElement: %AmmoElement%
    ExitApp
}

Macro.start("CYTE")

; Smart mode only polls the keys, so they still reach the game
if SmartMode {
    second_at := 0
    watch := Every(10, "Watch")
    Status("auto")
} else
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

; One smart mode tick, only in the game window: ability 2 when the ammo
; lost the element icon, ability 4 while its key is held
Watch() {
    if (Macro.game != "" && !WinActive(Macro.game))
        return

    ; The ammo icon comes back a few frames after the cast
    if (Held(StartStopKey) && Since(second_at) >= Cyte.recheck && !Seen(AmmoSpot, Cyte.ammo[AmmoElement])) {
        SendKey(secondAKey)
        second_at := Now()
    }
    if (AutoFourth && Held(FourthKey))
        SendKey(fourthAKey)
}

; Is the screen pixel at spot [x, y] within the [color, variation]
Seen(spot, color) {
    PixelSearch,,, % spot[1], % spot[2], % spot[1], % spot[2], % color[1], % color[2], Fast RGB
    return !ErrorLevel
}
