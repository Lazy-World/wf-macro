global Frequency
Process, Priority,, A
DllCall("QueryPerformanceFrequency", "Int64*", Frequency)   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;               Lumi                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TimeStamp(ByRef StampName = 0) {
    Return DllCall("QueryPerformanceCounter", "Int64*", StampName)                        
}

lSleep(s_time, ByRef start = "") {
    static hTimer := DllCall("CreateWaitableTimerExW", "Ptr", 0, "Ptr", 0, "UInt", 0x2, "UInt", 0x1F0003, "Ptr")
    DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
    CounterBefore := start != "" ? start : CounterBefore
    End := (CounterBefore + (Frequency * (s_time/1000))) - 1
    Loop {
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
        left := 1000 * (End - CounterAfter) / Frequency - 1
        if (left <= 0)
            break
        DllCall("SetWaitableTimer", "Ptr", hTimer, "Int64*", -Round(left * 10000), "Int", 0, "Ptr", 0, "Ptr", 0, "Int", 0)
        if (DllCall("MsgWaitForMultipleObjects", "UInt", 1, "Ptr*", hTimer, "Int", 0, "UInt", 0xFFFFFFFF, "UInt", 0x4FF) = 1)
            Sleep -1
    }
    Loop
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
    Until (End <= CounterAfter)
}

; waits on a high resolution waitable timer (Win10 1803+) until 1 ms before the deadline, spins the rest
; window messages wake it up, so hotkeys and timers keep running during the sleep

; s_time = time in milliseconds to sleep, can be input as a decimal, as accurate as frequency (10 MHz)
; start = optional parameter, should pass in a QPC timestamp as a variable, will sleep to s_time
;         after the the timestamp
;         e.g. lSleep(20, ext) followed by lSleep(40, ext) will only sleep a total 40 ms, not 60 ms
; the return statement returns the time actually slept, will slow down the sleep marginally


MeasureTime(ByRef begin, ByRef t_end := "") {
    Frequency ? Frequency : DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
    t_end ? t_end : DllCall("QueryPerformanceCounter", "Int64*", t_end)
    return Round(( 1000 * (t_end - begin) / Frequency), 3)
}

; begin/end = pass in two QPC timestamps as variables, returns a rounded difference, mostly a helper func

fInput(KeyCode, KeyState = "") {
    VarSetCapacity(INPUTS, (16 + (A_PtrSize * 3)) * (KeyState = "" ? 2 : 1) , 0)
    address := &INPUTS
    if (KeyState = "Down" || KeyState = "")
        address := NumPut( 0 | 8 | (KeyCode >> 8), NumPut(KeyCode & 0xFF, NumPut(1, address + 0) + 2, "UShort"), "UInt" ) + 8 + (A_PtrSize * 2)
    if (KeyState = "Up" || KeyState = "")
        address := NumPut( 2 | 8 | (KeyCode >> 8), NumPut(KeyCode & 0xFF, NumPut(1, address + 0) + 2, "UShort"), "UInt" ) + 8 + (A_PtrSize * 2)
    DllCall("SendInput", "UInt", (KeyState = "" ? 2 : 1), "Ptr", &INPUTS, "Int", 16 + (A_PtrSize * 3))
}

; KeyCode = scan code, e.g. 0x2 for "1", extended keys carry 0x100 (GetKeySC("Up") = 0x148)
; KeyState = "Down", "Up" or omitted for a full press
; sends hardware scan codes straight to SendInput, ignores modifiers state like {Blind}

SendKey(keyName, KeyState = "") {
    static hklUS := DllCall("LoadKeyboardLayout", "Str", "00000409", "UInt", 0x80, "Ptr")
    if (!(sc := GetKeySC(keyName)) && StrLen(keyName) = 1) {
        vk := DllCall("VkKeyScanEx", "UShort", Asc(keyName), "Ptr", hklUS, "Short") & 0xFF
        sc := vk != 0xFF ? DllCall("MapVirtualKeyEx", "UInt", vk, "UInt", 0, "Ptr", hklUS, "UInt") : 0
    }
    if (sc)
        return fInput(sc, KeyState)
    SendInput % "{Blind}{" keyName (KeyState = "" ? "" : " " KeyState) "}"
}

; keyName = key name AHK recognizes, keys without a scan code (mouse buttons) fall back to SendInput
;           single characters missing from the current layout (e.g. "[" on Russian) take the US key position

HoldKey(keyName, duration, wait := 0) {
    SendKey(keyName, "Down")
    lSleep(duration)
    SendKey(keyName, "Up")
    lSleep(wait)
    return
}

; keyName = should be a key name or vk code that AHK recognizes
; duration = how long in milliseconds the key should be held
; wait = optional parameter, will sleep after the key release (useful for archwing movement)

TimedKeyLoop(keyName, timeBetweenInputs, endTime, ByRef start := "") {
    start ? start : DllCall("QueryPerformanceCounter", "Int64*", start)
    Frequency ? Frequency : DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
    tkl_end := (start + ( Frequency * (endTime/1000))) - 1
    loop {
        SendKey(keyName)
        DllCall("QueryPerformanceCounter", "Int64*", tkl_sleep)
        tkl_sleep_end := (tkl_sleep + ( Frequency * (timeBetweenInputs/1000))) - 1
        loop {
            DllCall("QueryPerformanceCounter", "Int64*", tkl_sleep_time)
            if (tkl_end < tkl_sleep_time) 
                break 2 
            (tkl_sleep_end < tkl_sleep_time) ? break : lSleep(0.3, tkl_sleep_time)
        }
        until (tkl_sleep_end < tkl_sleep_time)
        DllCall("QueryPerformanceCounter", "Int64*", tkl_time)
    }
    until (tkl_end < tkl_time)
    return
}

; presses a key at desired interval for desired duration 
;
; keyName = should be a key name or vk code that AHK recognizes
; timeBetweenInputs = time between the key presses
; endTime = how long in milliseconds the macro will loop for
; start = see the start variable in lsleep

/*
F1::
DllCall("QueryPerformanceCounter", "Int64*", Before)

SendInput {f}

DllCall("QueryPerformanceCounter", "Int64*", After)
MsgBox % 1000 * (After - Before) / Frequency
return
*/

; used to check duration of a macro, leave it commented out just copy paste it somewhere else