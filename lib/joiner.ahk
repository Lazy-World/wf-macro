;; Joiner - runs every launched macro as one group.
;; Each macro owns a hidden marker window titled "joiner|<since>|<paused>":
;; peers find each other by it and receive commands through it.
;;   Joiner.join(Func("OnLayout"))  ; OnLayout(slot, count, paused), slot 1 = oldest macro
;;   Joiner.pause(!Joiner.paused)   ; pause / resume every macro
;;   Joiner.reload()                ; reload every macro, launch order is kept
;;   Joiner.exit()                  ; unload every macro
;; A hotkey that calls these must start with `Suspend, Permit`, otherwise
;; it is suspended together with the rest of the macro.
class Joiner {
    static paused := false
    static slot := 0
    static count := 0

    static _msg := DllCall("RegisterWindowMessage", "Str", "joiner", "UInt")
    static _cmd := {"sync": 1, "pause": 2, "resume": 3, "reload": 4, "exit": 5}
    static _hwnd := 0
    static _since := ""
    static _onLayout := ""

    join(onLayout := "") {
        ; Reload passes the launch time on, so the macro keeps its place
        EnvGet, since, JOINER_SINCE
        EnvSet, JOINER_SINCE

        if (since = "")
            DllCall("QueryPerformanceCounter", "Int64*", since)

        this._since := since
        this._onLayout := onLayout

        ; A macro launched (or reloaded) while the group is paused joins it paused
        inherit := false
        for i, peer in this._list()
            inherit := inherit || peer.paused

        Gui, joiner: +ToolWindow -Caption +Hwndhwnd
        Gui, joiner: Show, Hide, % this._title()
        this._hwnd := hwnd

        OnMessage(this._msg, ObjBindMethod(this, "_on_message"))
        OnMessage(0x113, ObjBindMethod(this, "_on_timer")) ; WM_TIMER
        OnExit(ObjBindMethod(this, "_on_exit"))

        ; Messages keep peers in sync, the timer only clears out crashed ones.
        ; A window timer, unlike SetTimer, keeps ticking while the macro is paused
        DllCall("SetTimer", "Ptr", hwnd, "UPtr", 1, "UInt", 1000, "Ptr", 0)

        this._post_all("sync")
        this._sync()

        if inherit {
            fn := ObjBindMethod(this, "_apply_pause", true)
            SetTimer, % fn, -1
        }
    }

    pause(on := true) {
        this._post_all(on ? "pause" : "resume")
        this._apply_pause(on)
    }

    reload() {
        this._post_all("reload")
        this._reload()
    }

    exit() {
        this._post_all("exit")
        ExitApp
    }

    ; Peers sorted by launch time: [{hwnd, since, paused}, ...]
    _list() {
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
            rows .= parts[2] "|" ids%A_Index% "|" parts[3] "`n"
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
        return "joiner|" this._since "|" (this.paused ? 1 : 0)
    }

    _post_all(cmd) {
        for i, peer in this._list()
            if (peer.hwnd != this._hwnd)
                DllCall("PostMessage", "Ptr", peer.hwnd, "UInt", this._msg, "Ptr", this._cmd[cmd], "Ptr", 0)
    }

    _on_message(wParam, lParam, msg, hwnd) {
        ; A command that arrives while the previous one runs is queued, not dropped
        Critical
        if (hwnd != this._hwnd)
            return

        if (wParam = this._cmd.sync)
            this._sync()
        else if (wParam = this._cmd.pause)
            this._apply_pause(true)
        else if (wParam = this._cmd.resume)
            this._apply_pause(false)
        else if (wParam = this._cmd.reload)
            this._reload()
        else if (wParam = this._cmd.exit)
            ExitApp
    }

    _on_timer(wParam, lParam, msg, hwnd) {
        Critical
        if (hwnd = this._hwnd && wParam = 1)
            this._sync()
    }

    _sync() {
        list := this._list()
        for i, peer in list
            if (peer.hwnd = this._hwnd)
                slot := i

        if (!slot || slot = this.slot && list.Length() = this.count)
            return

        this.slot := slot
        this.count := list.Length()
        this._notify()
    }

    ; Suspend blocks hotkeys, Pause freezes the running thread: same as the old F11
    _apply_pause(on) {
        on := on ? true : false
        if (on = this.paused)
            return

        this.paused := on
        DllCall("SetWindowText", "Ptr", this._hwnd, "Str", this._title())

        Suspend, % on ? "On" : "Off"
        Pause, % on ? "On" : "Off", 1
        this._notify()
    }

    ; Reload brings the group back unpaused: the flag is cleared first,
    ; so restarting peers do not inherit the pause from this marker
    _reload() {
        this.paused := false
        DllCall("SetWindowText", "Ptr", this._hwnd, "Str", this._title())
        EnvSet, JOINER_SINCE, % this._since
        Reload
    }

    _on_exit(reason := "", code := "") {
        Gui, joiner: Destroy
        this._post_all("sync")
    }

    _notify() {
        if IsObject(this._onLayout)
            this._onLayout.Call(this.slot, this.count, this.paused)
    }
}
