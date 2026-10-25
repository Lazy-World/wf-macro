;; Joiner - runs every launched macro as one group.
;; Each macro owns a hidden marker window titled "joiner|<since>|<paused>":
;; peers find each other by it and receive commands through it.
;;   Joiner.join(Func("OnLayout"))  ; OnLayout(slot, count, paused), slot 1 = oldest macro
;;   Joiner.pause(!Joiner.paused)   ; pause / resume every macro
;;   Joiner.reload()                ; reload every macro, launch order is kept
;;   Joiner.exit()                  ; unload every macro
;; A hotkey that calls these must start with `Suspend, Permit`, otherwise
;; it is suspended together with the rest of the macro.
;; Keys held through SendKey are released on pause / reload / exit and pressed again on resume.
#include %A_LineFile%\..\core.ahk

class Joiner {
    static paused := false
    static slot := 0
    static count := 0

    static _msg := DllCall("RegisterWindowMessage", "Str", "joiner", "UInt")
    static _cmd := {"sync": 1, "pause": 2, "resume": 3, "reload": 4, "exit": 5}
    static _hwnd := 0
    static _since := ""
    static _on_layout := ""
    static _held := []
    static _tick := 0

    ; Every method is force-local (`local`), so a script's super-global
    ; (e.g. `global list`) cannot take the place of a local here
    join(on_layout := "") {
        local
        if this._hwnd
            return

        ; Reload passes the launch time on, so the macro keeps its place
        EnvGet, since, JOINER_SINCE
        EnvSet, JOINER_SINCE
        reloaded := since != ""
        if !reloaded
            DllCall("QueryPerformanceCounter", "Int64*", since)

        this._since := since
        this._on_layout := on_layout

        ; The marker exists before peers are read, so a pause sent meanwhile reaches it.
        ; A named Gui (not `Gui, New`) leaves the thread's default Gui alone
        Gui, __joiner: +ToolWindow -Caption +Hwndhwnd
        Gui, __joiner: Show, Hide, % this._title()
        this._hwnd := hwnd

        OnMessage(this._msg, ObjBindMethod(this, "_on_message"))
        OnExit(ObjBindMethod(this, "_on_exit"))

        ; Messages keep peers in sync, the 1 s tick only clears out crashed ones.
        ; A TIMERPROC keeps ticking while the macro is paused (SetTimer does not)
        ; and, unlike OnMessage(WM_TIMER), is not woken by any other timer
        if !this._tick
            this._tick := RegisterCallback(Func("Joiner._on_tick"), "", 4)
        DllCall("SetTimer", "Ptr", hwnd, "UPtr", 1, "UInt", 1000, "Ptr", this._tick)

        this._post_all("sync")
        this._sync()

        ; A launched macro joins a paused group paused. A reloaded one does not:
        ; reload brings the whole group back unpaused, and a peer that has not
        ; restarted yet may still show the old pause
        inherit := false
        if !reloaded
            for i, peer in this._list()
                inherit := inherit || peer.hwnd != hwnd && peer.paused

        ; Suspended at once, so no hotkey slips through. `Pause, On, 1` does nothing
        ; from the auto-execute section, so a timer thread pauses what runs beneath it
        if inherit {
            this._apply_pause(true)
            fn := ObjBindMethod(this, "_pause_underlying")
            SetTimer, % fn, -1
        }
    }

    pause(on := true) {
        local
        this._post_all(on ? "pause" : "resume")
        this._apply_pause(on)
    }

    reload() {
        local
        this._post_all("reload")
        this._reload()
    }

    exit() {
        local
        this._post_all("exit")
        ExitApp
    }

    ; Peers sorted by launch time: [{hwnd, since, paused}, ...]
    _list() {
        local
        dhw := A_DetectHiddenWindows
        tmm := A_TitleMatchMode
        DetectHiddenWindows, On
        SetTitleMatchMode, 1

        rows := ""
        WinGet, ids, List, joiner| ahk_class AutoHotkeyGUI
        Loop % ids
        {
            WinGetTitle, title, % "ahk_id " ids%A_Index%
            parts := StrSplit(title, "|")
            rows .= parts[2] . "|" . ids%A_Index% . "|" . parts[3] . "`n"
        }

        DetectHiddenWindows, % dhw
        SetTitleMatchMode, % tmm

        Sort, rows, N
        list := []
        Loop, Parse, rows, `n
        {
            if (A_LoopField = "")
                continue
            parts := StrSplit(A_LoopField, "|")
            list.Push({"since": parts[1], "hwnd": parts[2] + 0, "paused": parts[3] = 1})
        }
        return list
    }

    _title() {
        local
        return "joiner|" . this._since . "|" . (this.paused ? 1 : 0)
    }

    _post_all(cmd) {
        local
        for i, peer in this._list()
            if (peer.hwnd != this._hwnd)
                DllCall("PostMessage", "Ptr", peer.hwnd, "UInt", this._msg, "Ptr", this._cmd[cmd], "Ptr", 0)
    }

    _on_message(w_param, l_param, msg, hwnd) {
        local
        ; A command that arrives while the previous one runs is queued, not dropped
        Critical
        if (hwnd != this._hwnd)
            return

        if (w_param = this._cmd.sync)
            this._sync()
        else if (w_param = this._cmd.pause)
            this._apply_pause(true)
        else if (w_param = this._cmd.resume)
            this._apply_pause(false)
        else if (w_param = this._cmd.reload)
            this._reload()
        else if (w_param = this._cmd.exit)
            ExitApp
    }

    ; TIMERPROC(hwnd, msg, id, time): called as a plain function, `this` is the hwnd.
    ; It cuts into any thread, Critical ones too, so it only queues a sync for _on_message
    _on_tick(msg := "", id := "", time := "") {
        local
        global Joiner
        DllCall("PostMessage", "Ptr", this, "UInt", Joiner._msg, "Ptr", Joiner._cmd.sync, "Ptr", 0)
    }

    _sync() {
        local
        list := this._list()
        slot := 0
        for i, peer in list
            if (peer.hwnd = this._hwnd)
                slot := i

        if (!slot || slot = this.slot && list.Length() = this.count)
            return

        this.slot := slot
        this.count := list.Length()
        this._notify()
    }

    ; Critical, so a resume cannot slip in between the check and the pause
    _pause_underlying() {
        local
        Critical
        if this.paused
            Pause, On, 1
    }

    ; Suspend blocks hotkeys, Pause freezes the running thread: same as the old F11
    _apply_pause(on) {
        local
        on := on ? true : false
        if (on = this.paused)
            return

        this.paused := on
        DllCall("SetWindowText", "Ptr", this._hwnd, "Str", this._title())

        if on
            this._held := this._release()
        else {
            for i, key in this._held
                SendKey(key, "Down")
            this._held := []
        }

        Suspend, % on ? "On" : "Off"
        this._notify()
        Pause, % on ? "On" : "Off", 1
    }

    ; Reload brings the group back unpaused (see join), the marker shows it at once
    _reload() {
        local
        this.paused := false
        DllCall("SetWindowText", "Ptr", this._hwnd, "Str", this._title())
        EnvSet, JOINER_SINCE, % this._since
        Reload
    }

    ; Runs on ExitApp, Reload and a normal exit alike
    _on_exit(reason := "", code := "") {
        local
        this._release()
        Gui, __joiner: Destroy
        this._hwnd := 0
        this._post_all("sync")
    }

    _release() {
        local
        BlockInput, Off
        BlockInput, MouseMoveOff
        return ReleaseAll()
    }

    ; Critical, so no message cuts into a layout call made by join or a pause hotkey;
    ; the caller's thread gets its own setting back
    _notify() {
        local
        if !IsObject(this._on_layout)
            return
        crit := A_IsCritical
        Critical
        this._on_layout.Call(this.slot, this.count, this.paused)
        Critical, % crit
    }
}
