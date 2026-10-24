#include %A_ScriptDir%/..

#include presets\game_settings.ahk

#include lib\headers.ahk
#include lib\ui.ahk
#include lib\joiner.ahk
#include lib\timers.ahk
#include lib\utils.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Settings               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#include %A_ScriptDir%
#include cfg\cfg_%A_Scriptname%

global sleepTime := 2000/fps

guiLabel := "PT"
#include misc\macro.ahk

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Hotkeys               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hotkey, *%StartStopKey%, StartStop
return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Source                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StartStop:
	status.text := "PEPE"

	While GetKeyState(StartStopKey, "p"){
		SendInput {Blind}{%shootKey% Down}
		lSleep(550)
		SendInput {Blind}{%shootKey% Up}

		lSleep(sleepTime)
		gosub ZawThrow
	}

	status.reset()
return

ZawThrow:
	global sleepTime
    SendInput {Blind}{%jumpKey%}
	lSleep(sleepTime)
	SendInput {Blind}{%jumpKey%}
	lSleep(sleepTime)
	SendInput {Blind}{%aimKey% Down}
	lSleep(sleepTime)
	SendInput {Blind}{%meleeKey%}
	lSleep(sleepTime)
	SendInput {Blind}{%aimKey% Up}
	lSleep(sleepTime)
Return

#include misc\misc.ahk
