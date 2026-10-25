;; Core - time, keys, mouse, screen and small helpers shared by every macro.
;; Time is in milliseconds as a float, read from the performance counter:
;;   t := Now()
;;   Wait(25)                       ; precise sleep, hotkeys and timers keep running
;;   WaitUntil(t += 20)             ; fixed cadence: each step counts from the previous deadline
;;   elapsed := Since(t)
;;   ticker := Every(100, "Fn", x)  ; Fn(x) every 100 ms until ticker.stop() or the ticker is released
;; Keys:
;;   SendKey("e"), SendKey("e", "Down"), SendKey("e", "Up")
;;   Hold("m", 400, 100)            ; hold 400 ms, then wait 100 ms
;;   RepeatKey("e", 50, 1000)       ; press every 50 ms for 1 s
;;   keys := ReleaseAll()           ; release every key held through SendKey
;; Functions with locals start with `local` (force-local): a script's `global key, start, ...`
;; must not alias their variables. Classes are then reachable only through `global` or `this`.

; ---------------------------------------------------------------- time

Now() {
    local
    static freq := 0, _ := DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", counter)
    return 1000 * counter / freq
}

Since(t) {
    return Now() - t
}

Wait(ms) {
    WaitUntil(Now() + ms)
}

; Sleeps on a high resolution waitable timer (Win10 1803+) until 1 ms before the deadline,
; then spins. Window messages wake it up, so hotkeys and timers run during the wait.
WaitUntil(t) {
    local
    static timer := DllCall("CreateWaitableTimerExW", "Ptr", 0, "Ptr", 0, "UInt", 0x2, "UInt", 0x1F0003, "Ptr")
    while ((left := t - Now() - 1) > 0) {
        if !timer {
            ; No high resolution timer: Sleep (~15.6 ms granularity) for the bulk
            Sleep % left > 20 ? left - 16 : -1
            continue
        }
        DllCall("SetWaitableTimer", "Ptr", timer, "Int64*", -Round(left * 10000), "Int", 0, "Ptr", 0, "Ptr", 0, "Int", 0)
        if (DllCall("MsgWaitForMultipleObjects", "UInt", 1, "Ptr*", timer, "Int", 0, "UInt", 0xFFFFFFFF, "UInt", 0x4FF) = 1)
            Sleep -1
    }
    while (Now() < t)
        continue
}

;; Every(interval_ms, fn, args*) - repeating ticker, first tick after one interval (like SetTimer).
;;   ticker.left / .running / .interval
;;   ticker.fire()                  ; call fn now and restart the period
;;   ticker.stop(), ticker.start()
;; The OS timer holds only the inner state, so releasing the last reference stops the ticker.
Every(interval_ms, fn, args*) {
    return new _Ticker(interval_ms, fn, args*)
}

; Not named Ticker: class names are super-global in v1, so a local `ticker := Every(...)`
; anywhere would overwrite the class (and keep that ticker alive forever)
class _Ticker {
    __New(interval_ms, fn, args*) {
        if !(interval_ms + 0 >= 1)
            throw Exception("Invalid interval: " interval_ms, -2)
        if (!IsObject(fn) && !IsFunc(fn))
            throw Exception("Unknown function: " fn, -2)
        this._state := new this._State(Round(interval_ms), IsObject(fn) ? fn : Func(fn), args)
        this._timer := ObjBindMethod(this._state, "tick")
        this._running := false
        this.start()
    }

    __Delete() {
        this.stop()
    }

    interval[] {
        get {
            return this._state.interval
        }
    }

    running[] {
        get {
            return this._running
        }
    }

    left[] {
        get {
            return this._running ? Max(0, this._state.due - Now()) : 0
        }
    }

    start() {
        local
        timer := this._timer
        SetTimer, % timer, % this._state.interval
        this._state.due := Now() + this._state.interval
        this._running := true
        return this
    }

    stop() {
        local
        timer := this._timer
        SetTimer, % timer, Delete
        this._running := false
        return this
    }

    fire() {
        if this._running
            this.start()
        this._state.tick()
        return this
    }

    class _State {
        __New(interval, fn, args) {
            this.interval := interval
            this.fn := fn
            this.args := args
            this.due := 0
        }

        tick() {
            this.due := Now() + this.interval
            this.fn.Call(this.args*)
        }
    }
}

; ---------------------------------------------------------------- keys

; key_name: any key name AHK knows. Keys without a scan code (mouse buttons) go through SendInput,
; single characters missing from the current layout (e.g. "[" on Russian) take their US key position.
SendKey(key_name, key_state := "") {
    local
    static hkl_us := 0
    if !(key_state = "" || key_state = "Down" || key_state = "Up")
        throw Exception("Invalid key_state: " key_state, -1)

    if (!(sc := GetKeySC(key_name)) && StrLen(key_name) = 1) {
        if !hkl_us
            hkl_us := DllCall("LoadKeyboardLayout", "Str", "00000409", "UInt", 0x80, "Ptr")
        vk := DllCall("VkKeyScanEx", "UShort", Asc(key_name), "Ptr", hkl_us, "Short") & 0xFF
        sc := vk != 0xFF ? DllCall("MapVirtualKeyEx", "UInt", vk, "UInt", 0, "Ptr", hkl_us, "UInt") : 0
    }

    ; Send and track as one step: a ReleaseAll() that cut in between would leave
    ; the key down but forgotten
    crit := A_IsCritical
    Critical
    if sc
        SendScan(sc, key_state)
    else
        SendInput % "{Blind}{" key_name (key_state = "" ? "" : " " key_state) "}"
    if (key_state = "Down")
        _HeldKeys()[key_name] := true
    else
        _HeldKeys().Delete(key_name)
    Critical % crit
}

; scan_code: e.g. 0x2 for "1", extended keys carry 0x100 (GetKeySC("Up") = 0x148).
; Raw SendInput, ignores the modifier state like {Blind}. The events are not marked
; as AHK's own, so hotkeys (this script's and other macros') see them.
SendScan(scan_code, key_state := "") {
    local
    static size := 16 + 3 * A_PtrSize ; sizeof(INPUT)
    if !(key_state = "" || key_state = "Down" || key_state = "Up")
        throw Exception("Invalid key_state: " key_state, -1)

    count := key_state = "" ? 2 : 1
    flags := 0x8 | ((scan_code >> 8) & 1) ; KEYEVENTF_SCANCODE | KEYEVENTF_EXTENDEDKEY
    VarSetCapacity(inputs, size * count, 0)
    Loop % count {
        up := key_state = "Up" || A_Index = 2
        p := &inputs + (A_Index - 1) * size
        NumPut(1, p + 0, "UInt")                                         ; type = INPUT_KEYBOARD
        NumPut(scan_code & 0xFF, p + A_PtrSize + 2, "UShort")             ; wScan
        NumPut(flags | (up ? 0x2 : 0), p + A_PtrSize + 4, "UInt")         ; dwFlags, 0x2 = KEYEVENTF_KEYUP
    }
    return DllCall("SendInput", "UInt", count, "Ptr", &inputs, "Int", size, "UInt")
}

Hold(key_name, hold_ms, sleep_ms_after := 0) {
    SendKey(key_name, "Down")
    Wait(hold_ms)
    SendKey(key_name, "Up")
    Wait(sleep_ms_after)
}

; Presses the key every interval_ms (counted from each press) until duration_ms has passed
; since start (default: now). Presses at least once and returns at the end of the duration.
RepeatKey(key_name, interval_ms, duration_ms, start := "") {
    local
    end := (start = "" ? Now() : start) + duration_ms
    Loop {
        SendKey(key_name)
        WaitUntil(Min(Now() + interval_ms, end))
    } until (Now() >= end)
}

Held(key_name) {
    return GetKeyState(key_name, "P")
}

; Returns the released key names, e.g. to press them again with SendKey(k, "Down")
ReleaseAll() {
    local
    crit := A_IsCritical
    Critical
    released := []
    for key_name in _HeldKeys()
        released.Push(key_name)
    for i, key_name in released
        SendKey(key_name, "Up")
    Critical % crit
    return released
}

_HeldKeys() {
    static keys := {}
    return keys
}

; ---------------------------------------------------------------- mouse, screen

class GameScreen {
    static _dpi := DllCall("SetThreadDpiAwarenessContext", "Ptr", -3, "Ptr") ; before reading the size
    static w := A_ScreenWidth
    static h := A_ScreenHeight
    static cx := A_ScreenWidth // 2
    static cy := A_ScreenHeight // 2
}

MouseCenter() {
    DllCall("SetCursorPos", "Int", GameScreen.cx, "Int", GameScreen.cy)
}

; Relative move in mickeys (mouse_event MOVE), scaled from a 1920x1080 reference
MouseNudge(dx, dy) {
    DllCall("mouse_event", "UInt", 0x1, "Int", dx * 1920 / GameScreen.w, "Int", dy * 1080 / GameScreen.h, "UInt", 0, "UPtr", 0)
}

; ---------------------------------------------------------------- helpers

Clamp(num, min, max) {
    return num > max ? max : num < min ? min : num
}

; One frame in ms at the global fps (60 when unset), limited to 1..60
FrameTime() {
    global fps
    return Clamp(Round(1000 / (fps + 0 > 0 ? fps : 60)), 1, 60)
}

; Blank value -> fallback, otherwise the value limited to the optional max, then min
ValueOr(value, fallback, min := "", max := "") {
    if (value = "")
        return fallback
    if (max != "")
        value := Min(value, max)
    if (min != "")
        value := Max(value, min)
    return value
}

; Deep, case-sensitive comparison of two arrays (or any objects / plain values)
ArraysEqual(a, b) {
    local
    if (!IsObject(a) || !IsObject(b))
        return !IsObject(a) && !IsObject(b) && a == b
    if (a.Count() != b.Count())
        return false
    for key, val in a
        if (!b.HasKey(key) || !ArraysEqual(val, b[key]))
            return false
    return true
}

StrRepeat(str, count) {
    local
    result := ""
    Loop % count
        result .= str
    return result
}

; Language id of the active window's keyboard layout (e.g. 0x409), false on failure
GetKeyboardLanguage() {
    local
    if !(thread_id := DllCall("GetWindowThreadProcessId", "Ptr", WinActive("A"), "Ptr", 0, "UInt"))
        return false
    if !(hkl := DllCall("GetKeyboardLayout", "UInt", thread_id, "Ptr"))
        return false
    return hkl & 0xFFFF
}
