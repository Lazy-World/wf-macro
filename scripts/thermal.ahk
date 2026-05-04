#Requires AutoHotkey v2.0

; Debug include
#include %A_ScriptDir%/..

#include lib\headers.ahk
#include lib\json.ahk
#include lib\timers.ahk
#include lib\utils.ahk
#include lib\ui.ahk

global ui_theme := {winOL: "ADADAD", alpOL: 255, winBG: "151515", alpBG: 180, title: "Montserrat Medium", titleCol: "86C8BC", titleSZ: 13, main: "Montserrat Medium", mainCol: "White", mainSZ: 13, info: "Montserrat Medium", infoCol: "FFF6BD", infoSZ: 13}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
settings_json := FileRead(A_ScriptDir "\..\lib\game_settings.json")
macro_json    := FileRead(A_ScriptDir "\cfg\" StrReplace(A_ScriptName, ".ahk", "") ".json")

global g_key   := json_load(&settings_json)
global g_macro := json_load(&macro_json)

for hotkeyFunction, hotkeyCombination in g_macro["hk"] {
    Hotkey("*" . hotkeyCombination["key"], %hotkeyFunction%)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global ui := []

gGuiW := 80
gGuiH := 28
gPosX := Ceil(A_ScreenWidth * 0.008)
gPosY := Ceil(A_ScreenHeight * 0.47)

ui.Push(Window("gui_chat", gPosX, gPosY, gGuiW, gGuiH, ui_theme, 3.132))
ui[1].new_text("Cooldown", g_macro["val"]["skillKey"]["val"], "auto", "title", "dadada")
ui[1].show()
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop(*) {
    ui[1].edit_text("Cooldown", "GO")

    while GetKeyState(g_macro["hk"]["StartStop"]["key"], "p") {
        SendInput "{Blind}{" g_macro["val"]["skillKey"]["val"] "}"
        lSleep(g_macro["val"]["tapDelay"]["val"])

        HoldKey(g_macro["val"]["skillKey"]["val"], g_macro["val"]["holdMs"]["val"])
        lSleep(g_macro["val"]["loopDelay"]["val"])
    }

    ui[1].edit_text("Cooldown", g_macro["val"]["skillKey"]["val"])
}

*Insert::Reload
*Del::ExitApp
