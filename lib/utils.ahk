#Requires AutoHotkey v2.0

global gScreen := [Ceil(A_ScreenWidth), Ceil(A_ScreenHeight)]
global gScreenCenter := [Ceil(A_ScreenWidth / 2), Ceil(A_ScreenHeight / 2)]

Clamp(num, min, max) {
    return num > max ? max : num < min ? min : num
}

ResetCursor() {
    DllCall("SetCursorPos", "Int", A_ScreenWidth / 2, "Int", A_ScreenHeight / 2)
}

MouseMove(move_x, move_y) {
    global gScreen
    ScaledX := move_x * 1920 / gScreen[1]
    ScaledY := move_y * 1080 / gScreen[2]
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

; Requires g_key loaded from game_settings.json
MinSleepTime() {
    global g_key
    return Clamp(Round(1000 / g_key["misc"]["fps"]), 1, 60)
}
