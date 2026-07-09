#include %A_ScriptDir%/..

#include presets\game_settings.ahk

#include lib\headers.ahk
#include lib\ui.ahk
#include lib\timers.ahk
#include lib\utils.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%
#include cfg\cfg_%A_Scriptname%
#include misc\ui_theme.ahk

skillKey := 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                Misc                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%MiscReloadMacroKey%, MiscReloadMacro
Hotkey, *%MiscUnloadMacroKey%, MiscUnloadMacro
Hotkey, *%MiscPauseKey%, MiscPause

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include misc\require_warframe.ahk
Hotkey, *%ThermalKey%, StartStop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                 GUI                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
guiLabel := skillKey
#include misc\gui.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop:
    ui[1].edit_text("Cooldown", "GO")

    While GetKeyState(ThermalKey, "p"){
        SendInput {Blind}{%skillKey%}
        lSleep(500)

        HoldKey(skillKey, 500)
        lSleep(500)
    }

    ui[1].edit_text("Cooldown", skillKey)
Return

#include misc\misc.ahk
