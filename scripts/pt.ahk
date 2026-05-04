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
settings_json := FileRead(A_ScriptDir "\..\lib\game_settings.json")
macro_json    := FileRead(A_ScriptDir "\cfg\" StrReplace(A_ScriptName, ".ahk", "") ".json")

global g_key   := json_load(&settings_json)
global g_macro := json_load(&macro_json)

global sleepTime := 2000 / g_key["misc"]["fps"]

for hotkeyFunction, hotkeyCombination in g_macro["hk"] {
    Hotkey("*" . hotkeyCombination["key"], %hotkeyFunction%)
}

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
    g_ui[1].edit_text("Cooldown", "PEPE")

    while GetKeyState(g_macro["hk"]["StartStop"]["key"], "p") {
        SendInput "{Blind}{" g_key["game"]["shoot"] " Down}"
        lSleep(g_macro["val"]["shootHold"]["val"])
        SendInput "{Blind}{" g_key["game"]["shoot"] " Up}"

        lSleep(sleepTime)
        ZawThrow()
    }

    g_ui[1].edit_text("Cooldown", "PT")
}

ZawThrow() {
    SendInput "{Blind}{" g_key["game"]["jump"] "}"
    lSleep(sleepTime)
    SendInput "{Blind}{" g_key["game"]["jump"] "}"
    lSleep(sleepTime)
    SendInput "{Blind}{" g_key["game"]["aim"] " Down}"
    lSleep(sleepTime)
    SendInput "{Blind}{" g_key["game"]["melee"] "}"
    lSleep(sleepTime)
    SendInput "{Blind}{" g_key["game"]["aim"] " Up}"
    lSleep(sleepTime)
}

*Insert::Reload
*Del::ExitApp
