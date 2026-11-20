;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Imports               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%\..\presets\game_settings.ahk
#include %A_ScriptDir%\cfg\cfg_%A_Scriptname%
#include %A_ScriptDir%\..\lib\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ammo element pixel color [color, variation], status picture and overlay spot.
; A new element is a row in `ammo`, `icons` and `pos` plus its name in the
; AmmoElement @Select of the cfg
class Cyte {
    static ammo := {"Electricity": [0xB28FCD, 50], "Blast": [0xA57374, 20], "Gas": [0x62cbac, 40]}
    static icons := {"Electricity": "DT_ELECTRICITY.png", "Blast": "DT_BLAST.png", "Gas": "DT_GAS.png"}
    static pos := ""                ; filled below: the cfg spots don't exist yet at class init
    static recheck := 50            ; ms after pressing 2 before the ammo pixel counts again
}

; Class variables are initialized before the auto-execute section, so the cfg
; spots are still blank there. Build the element -> spot map here instead
Cyte.pos := {"Electricity": AmmoSpotElectricity, "Blast": AmmoSpotBlast, "Gas": AmmoSpotGas}

if (SmartMode && (!Cyte.ammo.HasKey(AmmoElement) || !Cyte.icons.HasKey(AmmoElement))) {
    MsgBox, 16, CYTE, Unknown AmmoElement: %AmmoElement%
    ExitApp
}

second_at := 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 UI                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
status.new_text("key", "CYTE:", "main", "left x6 ym")
key_size := status.measure("key")
value_x := 6 + key_size[1] + 6

; Smart mode shows the ammo element as an icon in the value slot
if SmartMode
    status.new_picture("element", Cyte.icons[AmmoElement], "x" value_x " y0 w" key_size[2] " h" key_size[2])
    if AutoScan
        status.new_text("scan", "Auto", "accent", "left x" (value_x + key_size[2] + 6) " ym")
else
    status.new_text("value", "", "accent", "left x" value_x " yp")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Smart mode only polls the keys, so they still reach the game
if SmartMode {
    SetTimer, Watch, 10
    if AutoScan
        SetTimer, Scan, 1000
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

Scan:
    if !WfActive()
        return
    for name, spot in Cyte.pos
        if PixelSeen(spot, Cyte.ammo[name]) {
            AmmoElement := name
            break
        }
return