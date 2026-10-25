;; Macro - entry point of a game macro: settings and libs, the status window,
;; the group binds (reload / unload / pause) and the game gate.
;;   #include %A_ScriptDir%\..\presets\game_settings.ahk
;;   #include %A_ScriptDir%\..\lib\macro.ahk
;;   #include %A_ScriptDir%\cfg\cfg_%A_Scriptname%
;;   global StartKey
;;   Macro.start("LABEL")       ; once, after the cfg include and before any Bind
;;   Bind(StartKey, "Run")      ; *StartKey -> Run(), only while the game is active
;;   Run() {
;;       Status("work")         ; body value of the status window
;;       ...
;;       Status()               ; back to idle
;;   }
;; Group keys come from the globals MiscReloadMacroKey / MiscUnloadMacroKey / MiscPauseKey.
#include %A_LineFile%\..\headers.ahk
#include %A_LineFile%\..\core.ahk
#include %A_LineFile%\..\joiner.ahk
#include %A_LineFile%\..\ui.ahk

class Macro {
    static _status := ""
    static _game := ""

    ; opt: {game, x, y, icon, idle, theme}; game "" = hotkeys work in every window
    start(label, opt := "") {
        global MiscReloadMacroKey, MiscUnloadMacroKey, MiscPauseKey
        if this._status
            throw Exception("Macro.start() was already called", -1)

        this._game := IsObject(opt) && opt.HasKey("game") ? opt.game : "ahk_exe Warframe.x64.exe"
        this._status := new UiStatusWindow(ValueOr(opt.x, Ceil(GameScreen.w * 0.0066)), ValueOr(opt.y, Ceil(GameScreen.h * 0.47))
            , label, {show: false, icon: opt.icon, idle: opt.idle, theme: opt.theme})

        Bind(MiscReloadMacroKey, "_MacroReload")
        Bind(MiscUnloadMacroKey, "_MacroUnload")
        Bind(MiscPauseKey, "_MacroPause")

        Joiner.join(ObjBindMethod(this, "_layout"))
    }

    ; on "" toggles
    pause(on := "") {
        Joiner.pause(on = "" ? !Joiner.paused : on)
    }

    reload() {
        Joiner.reload()
    }

    exit() {
        Joiner.exit()
    }

    status {
        get {
            return this._status
        }
    }

    game {
        get {
            return this._game
        }
    }

    paused {
        get {
            return Joiner.paused
        }
    }

    slot {
        get {
            return Joiner.slot
        }
    }

    count {
        get {
            return Joiner.count
        }
    }

    _layout(slot, count, paused) {
        this._status.suspended := paused
        this._status.place(slot, slot = count)
    }
}

; Hotkey "*key" -> fn(args*), gated by Macro.game. A key that already starts
; with a prefix (~*$!^+#<>) is used as is; a blank key is skipped.
Bind(key, fn, args*) {
    local ; force-local: a script's `global f` must not alias the local
    global Macro
    if (key = "")
        return
    if !InStr("~*$!^+#<>", SubStr(key, 1, 1))
        key := "*" key
    if args.Length() {
        if !(f := IsObject(fn) ? fn : Func(fn))
            throw Exception("Nonexistent function: " fn, -1)
        fn := f.Bind(args*)
    }
    Hotkey, IfWinActive, % Macro.game
    Hotkey, % key, % fn, On
}

; Status("x") sets the body value, Status() puts it back to idle
Status(params*) {
    if params.Length()
        Macro.status.text := params[1]
    else
        Macro.status.reset()
}

; Group binds are bound by name and start with `Suspend, Permit`,
; so they keep working while the group is paused
_MacroReload() {
    Suspend, Permit
    Macro.reload()
}

_MacroUnload() {
    Suspend, Permit
    Macro.exit()
}

_MacroPause() {
    Suspend, Permit
    Macro.pause()
}

; Gates any `::` hotkey a script still defines below its includes
#IfWinActive ahk_exe Warframe.x64.exe
