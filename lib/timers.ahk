#Requires AutoHotkey v2.0

global Frequency := 0
DllCall("QueryPerformanceFrequency", "Int64*", &Frequency)

GetQPC() {
    local v := 0
    DllCall("QueryPerformanceCounter", "Int64*", &v)
    return v
}

TimeStamp() {
    return GetQPC()
}

lSleep(s_time, start := 0) {
    global Frequency

    Critical
    CounterBefore := 0
    DllCall("QueryPerformanceCounter", "Int64*", &CounterBefore)

    if (start != 0)
        CounterBefore := start

    if (s_time > 20) {
        CounterAfter := 0
        DllCall("QueryPerformanceCounter", "Int64*", &CounterAfter)
        Critical "Off"
        Sleep s_time - (1000 * (CounterAfter - CounterBefore) / Frequency) - 20
    }

    Critical
    End := (CounterBefore + (Frequency * (s_time / 1000))) - 1

    loop {
        CounterAfter := 0
        DllCall("QueryPerformanceCounter", "Int64*", &CounterAfter)
        if (End <= CounterAfter)
            break
    }
    Critical "Off"
}

MeasureTime(begin, t_end := 0) {
    global Frequency
    if (t_end == 0)
        t_end := GetQPC()
    return Round(1000 * (t_end - begin) / Frequency, 3)
}

HoldKey(keyName, duration, wait := 0) {
    SendInput "{" keyName " down}"
    lSleep(duration)
    SendInput "{" keyName " up}"
    lSleep(wait)
}

TimedKeyLoop(keyName, timeBetweenInputs, endTime, start := 0) {
    global Frequency

    if (start == 0)
        start := GetQPC()

    tkl_end := (start + (Frequency * (endTime / 1000))) - 1

    loop {
        SendInput "{" keyName "}"

        tkl_sleep := GetQPC()
        tkl_sleep_end := (tkl_sleep + (Frequency * (timeBetweenInputs / 1000))) - 1

        loop {
            tkl_sleep_time := GetQPC()
            if (tkl_end < tkl_sleep_time)
                return
            if (tkl_sleep_end < tkl_sleep_time)
                break
            lSleep(0.3, tkl_sleep_time)
        }

        tkl_time := GetQPC()
        if (tkl_end < tkl_time)
            break
    }
}
