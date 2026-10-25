#SingleInstance Force
#Persistent
#NoEnv
#KeyHistory 0
#MaxHotkeysPerInterval 9999999
#HotkeyInterval 9999999
#MaxThreads 255

ListLines, Off
Process, Priority,, A
CoordMode, Pixel, Screen
SetStoreCapslockMode, Off
SetBatchLines -1
SetKeyDelay, -1, -1
SetMouseDelay, -1, -1
SetControlDelay -1
SetWinDelay -1

global Frequency
DllCall("QueryPerformanceFrequency", "Int64*", Frequency)

lSleep(s_time, ByRef start = "") {
    DllCall("QueryPerformanceCounter", "Int64*", CounterBefore)
    CounterBefore := start != "" ? start : CounterBefore
    if (s_time > 40) {
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
        Sleep % s_time - (1000 * (CounterAfter - CounterBefore) / Frequency) - 20
    }
    End := (CounterBefore + (Frequency * (s_time/1000))) - 1
    Loop
        DllCall("QueryPerformanceCounter", "Int64*", CounterAfter)
    Until (End <= CounterAfter)
}

TimeStamp(ByRef StampName = 0) {
    Return DllCall("QueryPerformanceCounter", "Int64*", StampName)
}

MeasureTime(ByRef begin, ByRef t_end := "") {
    Frequency ? Frequency : DllCall("QueryPerformanceFrequency", "Int64*", Frequency)
    t_end ? t_end : DllCall("QueryPerformanceCounter", "Int64*", t_end)
    return Round(( 1000 * (t_end - begin) / Frequency), 3)
}

fInput(KeyCode, KeyState = "") {
    VarSetCapacity(INPUTS, (16 + (A_PtrSize * 3)) * (KeyState = "" ? 2 : 1) , 0)
    address := &INPUTS
    if (KeyState = "Down" || KeyState = "")
        address := NumPut( 0 | 8 | (KeyCode >> 8), NumPut(KeyCode & 0xFF, NumPut(1, address + 0) + 2, "UShort"), "UInt" ) + 8 + (A_PtrSize * 2)
    if (KeyState = "Up" || KeyState = "")
        address := NumPut( 2 | 8 | (KeyCode >> 8), NumPut(KeyCode & 0xFF, NumPut(1, address + 0) + 2, "UShort"), "UInt" ) + 8 + (A_PtrSize * 2)
    DllCall("SendInput", "UInt", (KeyState = "" ? 2 : 1), "Ptr", &INPUTS, "Int", 16 + (A_PtrSize * 3))
}

SetTimer, CheckAll, 0
Return

CheckAll:
    PixelSearch,,, 1890, 955, 1910, 980, 0xD71117, 20, Fast RGB
    ErrorLevel1 := ErrorLevel
    If (!ErrorLevel1) {
        SetTimer, Auto1, 0
        SetTimer, Auto2, 0
        SetTimer, Auto4, 0
    }
    Else If (ErrorLevel1) {
        SetTimer, Auto4, Off
        SetTimer, Auto2, Off
        SetTimer, Auto1, Off
    }
Return

Auto1:
    PixelSearch,,, 1672, 1022, 1693, 1034, 0xD71117, 70, Fast RGB
    ErrorLevel2 := ErrorLevel
    If (ErrorLevel2) {
        fInput(0x2) ; 1
    }
Return

; | 1811, 953, 1811, 953, 0xB490D3, 50, Fast RGB | Elect | ; SOBEK
; | 1805, 955, 1805, 955, 0xA57374, 20, Fast RGB | Blast | ; BOAR
; | 1780, 955, 1780, 955, 0xA57374, 20, Fast RGB | Blast | ; KOHM

Auto2:
    If (GetKeyState("vk01","P")) {
        PixelSearch,,, 1805, 955, 1805, 955, 0xA57374, 20, Fast RGB
        ErrorLevel3 := ErrorLevel
        If (ErrorLevel3) {
            fInput(0x3) ; 2
            Sleep, 1
        }
    }
Return

Auto4:
    If (GetKeyState("vk02","P")) {
        fInput(0x5) ; 4
    }
Return

*sc3C::
    Suspend, Permit
    Reload
    Sleep, 100
Return

*sc3B::
    Suspend
    SendEvent, {blind}{vk01 up}
    Pause
    Sleep, 100
Return