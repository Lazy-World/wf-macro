;; Core - small additions to native AHK, shared by every macro.
;;   Wait(25)                        ; precise Sleep: same ms unit, hotkeys and timers keep running
;;   SendKey("e"), SendKey("e", "Down"), SendKey("e", "Up")
;;                                   ; the game gets it even if "e" is bound to a hotkey
;;   Hold("m", 400, 100)             ; hold 400 ms, then wait 100 ms
;;   keys := ReleaseAll()            ; release every key put down through SendKey
;;   MouseCenter()
;;   MouseNudge(dx, dy)              ; relative mouse move, scaled from a 1920x1080 reference
;;   Clamp(n, min, max)
;;
;; Everything else stays native: A_TickCount for intervals, SetTimer for repeating work,
;; GetKeyState(key, "P") for a held key, Hotkey for binds.
;; Functions with locals start with `local` (force-local): a script's `global key, start, ...`
;; must not alias their variables.

; ---------------------------------------------------------------- time

; Precise clock, milliseconds as a float. Internal: macros use A_TickCount.
_Now() {
    local
    static freq := 0, _ := DllCall("QueryPerformanceFrequency", "Int64*", freq)
    DllCall("QueryPerformanceCounter", "Int64*", counter)
    return 1000 * counter / freq
}

; Precise Sleep: same millisecond unit as the native command.
Wait(ms) {
    _WaitUntil(_Now() + ms)
}

; Sleeps on a high resolution waitable timer (Win10 1803+) until 1 ms before the deadline,
; then spins. Window messages wake it up, so hotkeys and timers run during the wait.
_WaitUntil(t) {
    local
    static timer := DllCall("CreateWaitableTimerExW", "Ptr", 0, "Ptr", 0, "UInt", 0x2, "UInt", 0x1F0003, "Ptr")
    while ((left := t - _Now() - 1) > 0) {
        if !timer {
            ; No high resolution timer: Sleep (~15.6 ms granularity) for the bulk
            Sleep % left > 20 ? left - 16 : -1
            continue
        }
        DllCall("SetWaitableTimer", "Ptr", timer, "Int64*", -Round(left * 10000), "Int", 0, "Ptr", 0, "Ptr", 0, "Int", 0)
        if (DllCall("MsgWaitForMultipleObjects", "UInt", 1, "Ptr*", timer, "Int", 0, "UInt", 0xFFFFFFFF, "UInt", 0x4FF) = 1)
            Sleep -1
    }
    while (_Now() < t)
        continue
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
        _SendScan(sc, key_state)
    else
        SendInput % "{Blind}{" key_name (key_state = "" ? "" : " " key_state) "}"
    if (key_state = "Down")
        _HeldKeys()[key_name] := true
    else
        _HeldKeys().Delete(key_name)
    Critical % crit
}

; scan_code: e.g. 0x2 for "1", extended keys carry 0x100 (GetKeySC("Up") = 0x148).
; Raw SendInput, ignores the modifier state like {Blind}. The events carry AHK's
; KEY_IGNORE marker, so hotkeys (this script's and other macros') let them through:
; a macro can send a key that is also bound to its own hotkey.
_SendScan(scan_code, key_state := "") {
    local
    static size := 16 + 3 * A_PtrSize ; sizeof(INPUT)
    static extra := A_PtrSize * 2 + 8  ; dwExtraInfo inside KEYBDINPUT
    static ignore := 0xFFC3D44D        ; KEY_IGNORE_ALL_EXCEPT_MODIFIER: AHK hotkeys ignore the event
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
        NumPut(ignore, p + extra, "UPtr")                                 ; dwExtraInfo
    }
    return DllCall("SendInput", "UInt", count, "Ptr", &inputs, "Int", size, "UInt")
}

Hold(key_name, hold_ms, sleep_ms_after := 0) {
    SendKey(key_name, "Down")
    Wait(hold_ms)
    SendKey(key_name, "Up")
    Wait(sleep_ms_after)
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

MouseCenter() {
    DllCall("SetCursorPos", "Int", A_ScreenWidth // 2, "Int", A_ScreenHeight // 2)
}

; Relative move in mickeys (mouse_event MOVE), scaled from a 1920x1080 reference
MouseNudge(dx, dy) {
    DllCall("mouse_event", "UInt", 0x1, "Int", dx * 1920 / A_ScreenWidth, "Int", dy * 1080 / A_ScreenHeight, "UInt", 0, "UPtr", 0)
}

; ---------------------------------------------------------------- helpers

Clamp(num, min, max) {
    return num > max ? max : num < min ? min : num
}
