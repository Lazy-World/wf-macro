#Requires AutoHotkey v2.0

global gScreen := [Ceil(A_ScreenWidth), Ceil(A_ScreenHeight)]
global gScreenCenter := [Ceil(A_ScreenWidth / 2), Ceil(A_ScreenHeight / 2)]

; MouseMove() scales input from a reference resolution so a recorded macro
; behaves the same on any monitor. Adjust if recordings were taken at a
; different baseline.
global gRefWidth  := 1920
global gRefHeight := 1080

Clamp(num, min, max) {
    return num > max ? max : num < min ? min : num
}

ResetCursor() {
    DllCall("SetCursorPos", "Int", A_ScreenWidth / 2, "Int", A_ScreenHeight / 2)
}

MouseMove(move_x, move_y) {
    global gScreen, gRefWidth, gRefHeight
    ScaledX := move_x * gRefWidth  / gScreen[1]
    ScaledY := move_y * gRefHeight / gScreen[2]
    DllCall("mouse_event", "UInt", 1, "Int", ScaledX, "Int", ScaledY, "UInt", 0, "Int", 0)
}

GetKeyboardLanguage() {
    if !(ThreadId := DllCall("user32.dll\GetWindowThreadProcessId", "Ptr", WinActive("A"), "UInt", 0, "UInt"))
        return false

    if !(KBLayout := DllCall("user32.dll\GetKeyboardLayout", "UInt", ThreadId, "UInt"))
        return false

    return KBLayout & 0xFFFF
}

StrRepeat(str, count) {
    result := ""
    Loop count
        result .= str
    return result
}

; Minimum useful sleep step derived from monitor FPS.
; Reads g_key (Cfg or raw Map) if present; otherwise falls back to 60 FPS.
MinSleepTime() {
    fps := 60
    try {
        global g_key
        if IsSet(g_key) {
            if (g_key is Cfg)
                fps := g_key.Get("misc.fps", 60)
            else if (g_key is Map) && g_key.Has("misc") && g_key["misc"].Has("fps")
                fps := g_key["misc"]["fps"]
        }
    }
    return Clamp(Round(1000 / fps), 1, 60)
}
