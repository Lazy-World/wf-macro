;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ammo element icon colors as [color, variation]. A new element is a row in
; `ammo` and `pos` plus its name in the AmmoElement @Select of the cfg
class Cyte {
    static ammo := {"Electricity": [0xB28FCD, 50], "Blast": [0xA57374, 20], "Gas": [0x62cbac, 40]}
    static pos := ""                ; filled below: the cfg spots don't exist yet at class init
    static recheck := 50            ; ms after pressing 2 before the ammo pixel counts again
}

; Class variables are initialized before the auto-execute section, so the cfg
; spots are still blank there. Build the element -> spot map here instead
Cyte.pos := {"Electricity": AmmoSpotElectricity, "Blast": AmmoSpotBlast, "Gas": AmmoSpotGas}

if (SmartMode && !Cyte.ammo.HasKey(AmmoElement)) {
    MsgBox, 16, CYTE, Unknown AmmoElement: %AmmoElement%
    ExitApp
}

second_at := 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 UI                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
status.new_text("key", "CYTE:", "main", "left x6 ym")
status.new_text("value", "", "accent", "left x" (6 + status.measure("key")[1] + 6) " yp")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Smart mode only polls the keys, so they still reach the game
if SmartMode {
    status.edit_text("value", AmmoElement)
    SetTimer, Watch, 10
} else
    Hotkey, *%StartStopKey%, StartStop
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop:
    status.edit_text("value", AbilityInterval)

    cast_at := A_TickCount
    SendKey(secondAKey)

    While GetKeyState(StartStopKey, "P") {
        if (A_TickCount - cast_at > AbilityInterval) {
            cast_at := A_TickCount
            SendKey(secondAKey)
        }
        Wait(50)
    }

    status.edit_text("value", "")
return

; One smart mode tick, only in the game window: ability 2 when the ammo
; lost the element icon, ability 4 while its key is held
Watch:
    if !WfActive()
        return

    ; The ammo icon comes back a few frames after the cast
    if (GetKeyState(StartStopKey, "P") && A_TickCount - second_at >= Cyte.recheck && !PixelSeen(Cyte.pos[AmmoElement], Cyte.ammo[AmmoElement])) {
        SendKey(secondAKey)
        second_at := A_TickCount
    }
    if (AutoFourth && GetKeyState(FourthKey, "P"))
        SendKey(fourthAKey)
return
