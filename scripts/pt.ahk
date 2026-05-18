#Requires AutoHotkey v2.0

; Debug include
#include %A_ScriptDir%/..

#include lib\headers.ahk
#include lib\json.ahk
#include lib\timers.ahk
#include lib\ui.ahk

global ui_theme := {winOL: "ADADAD", alpOL: 255, winBG: "151515", alpBG: 180, title: "Montserrat Medium", titleCol: "86C8BC", titleSZ: 13, main: "Montserrat Medium", mainCol: "White", mainSZ: 13, info: "Montserrat Medium", infoCol: "FFF6BD", infoSZ: 13}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global g_key   := Cfg.FromFile(A_ScriptDir "\..\lib\game_settings.json")
global g_macro := Cfg.FromFile(A_ScriptDir "\cfg\" StrReplace(A_ScriptName, ".ahk", "") ".json")

global sleepTime := 2000 / g_key.Get("misc.fps", 60)

for fn, combo in g_macro.Hotkeys()
    Hotkey "*" combo, %fn%

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global g_ui := []

gGuiW := 80
gGuiH := 28
gPosX := Ceil(A_ScreenWidth * 0.008)
gPosY := Ceil(A_ScreenHeight * 0.47)

g_ui.Push(Window("gui_chat", gPosX, gPosY, gGuiW, gGuiH, ui_theme, {blur: 1, border: 1, ol: [1, 1, 1, 1]}))
g_ui[1].new_text("Cooldown", "PT", "auto", "title")
g_ui[1].show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop(*) {
    shoot     := g_key.Get("game.shoot")
    toggleKey := g_macro.K("StartStop")
    shootHold := g_macro.V("shootHold")

    g_ui[1].edit_text("Cooldown", "PEPE")

    while GetKeyState(toggleKey, "p") {
        SendInput "{Blind}{" shoot " Down}"
        lSleep(shootHold)
        SendInput "{Blind}{" shoot " Up}"

        lSleep(sleepTime)
        ZawThrow()
    }

    g_ui[1].edit_text("Cooldown", "PT")
}

ZawThrow() {
    jump  := g_key.Get("game.jump")
    aim   := g_key.Get("game.aim")
    melee := g_key.Get("game.melee")

    SendInput "{Blind}{" jump "}"
    lSleep(sleepTime)
    SendInput "{Blind}{" jump "}"
    lSleep(sleepTime)
    SendInput "{Blind}{" aim " Down}"
    lSleep(sleepTime)
    SendInput "{Blind}{" melee "}"
    lSleep(sleepTime)
    SendInput "{Blind}{" aim " Up}"
    lSleep(sleepTime)
}

*Insert::Reload
*Del::ExitApp
