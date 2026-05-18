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
g_ui[1].new_text("Cooldown", "start", "auto", "title")
g_ui[1].show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop(*) {
    skillKey  := g_macro.V("skillKey")
    preDelay  := g_macro.V("preDelay")
    midDelay  := g_macro.V("midDelay")
    postDelay := g_macro.V("postDelay")
    toggleKey := g_macro.K("StartStop")

    g_ui[1].edit_text("Cooldown", "GO: 1")
    SendInput "{Blind}{" skillKey "}"
    lSleep(preDelay)

    while GetKeyState(toggleKey, "p") {
        lSleep(midDelay)
        g_ui[1].edit_text("Cooldown", "GO: 2")

        SendInput "{Blind}{" skillKey "}"
        lSleep(postDelay)
        break
    }

    g_ui[1].edit_text("Cooldown", "start")
}

*Insert::Reload
*Del::ExitApp
