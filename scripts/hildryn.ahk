#include %A_ScriptDir%/..

global ui_theme := {voidTheme: {winOL: "ADADAD", alpOL: 255, winBG: "151515", alpBG: 180, title: "Montserrat Medium", titleCol: "86C8BC", titleSZ: 13, main: "Montserrat Medium", mainCol: "White", mainSZ: 13, info: "Montserrat Medium", infoCol: "FFF6BD", infoSZ: 13}}
ui_theme := ui_theme.voidTheme

#include presets\game_settings.ahk

#include lib\headers.ahk
#include lib\custom_ui.ahk
#include lib\timers.ahk
#include lib\utils.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%
#include cfg\cfg_%A_Scriptname%

Hotkey, *%MiscReloadMacroKey%, MiscReloadMacro
Hotkey, *%MiscUnloadMacroKey%, MiscUnloadMacro

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%StartStopKey%, StartStop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global ui := []

gGuiW := 80
gGuiH := 28

gPosX := Ceil(gScreen[1] * 0.008)
gPosY := Ceil(gScreen[2] * 0.47)

ui.push(new Window("gui_chat", gPosX, gPosY, gGuiW, gGuiH, ui_theme, 3.132))
ui[1].new_text("Cooldown", "HILDR", "auto", "title", "dadada")
ui[1].show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop:
    ui[1].edit_text("Cooldown", "GAGA")
    Send, {Blind}{%secondAKey%}
    Send, {Blind}{%shoot2Key%}

    SetTimer, AbilitySpam, %Abil_2_Cooldown%
    SetTimer, AltFireSpam, %Alt_fire_Cooldown%

    While GetKeyState(StartStopKey, "p") {
        lSleep(50)
    }

    SetTimer, AbilitySpam, off
    SetTimer, AltFireSpam, off

    ui[1].edit_text("Cooldown", "HILDR")
Return

AbilitySpam:
    Send, {Blind}{%secondAKey%}
return

AltFireSpam:
    
    Send, {Blind}{%shoot2Key%}
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MiscReloadMacro:
    reload
return

MiscUnloadMacro:
    exitapp
return