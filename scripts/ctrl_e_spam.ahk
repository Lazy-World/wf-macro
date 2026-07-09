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
ui[1].new_text("Cooldown", "MELEE", "auto", "title", "dadada")
ui[1].show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop:
    ui[1].edit_text("Cooldown", "+W")

	SendInput {Blind}{%meleeKey% Down}
	
	While GetKeyState(StartStopKey, "p"){
        SendInput {Blind}{%crouchKey% Down}
        lSleep(230)
		SendInput {Blind}{%crouchKey% Up}
		lSleep(230)
    }

	SendInput {Blind}{%meleeKey% Up}
    
    ui[1].edit_text("Cooldown", "MELEE")
Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MiscReloadMacro:
    reload
return

MiscUnloadMacro:
    exitapp
return