; time.ahk
#Requires AutoHotkey v2.0

global Frequency := 0
if (!Frequency)
    DllCall("QueryPerformanceFrequency", "Int64*", &Frequency)

; Вспомогательная функция для получения текущего значения QPC
GetQPC() {
    local qpc := 0
    DllCall("QueryPerformanceCounter", "Int64*", &qpc)
    return qpc
}

; Получение временной метки
TimeStamp(&StampName := 0) {
    return DllCall("QueryPerformanceCounter", "Int64*", &StampName)
}

; Улучшенный и более точный аналог Sleep
; s_time – Время сна в миллисекундах, возможно указание десятичной дроби
; start – опционально, метка времени QPC, от которой ведётся отсчёт
lSleep(s_time, &start := unset) {
    global Frequency
    local counterBefore, counterAfter, endTime

    Critical(true)
    counterBefore := IsSet(start) ? start : GetQPC()
    
    if (!Frequency)
        DllCall("QueryPerformanceFrequency", "Int64*", &Frequency)
    
    if (s_time > 20) {
        counterAfter := GetQPC()
        Critical(false)
        Sleep(s_time - (1000 * (counterAfter - counterBefore) / Frequency) - 20)
        Critical(true)
    }
    
    endTime := counterBefore + (Frequency * (s_time / 1000)) - 1
    while (GetQPC() < endTime) {
        ; Ожидание достижения необходимого времени
    }
    Critical(false)
}

; Измерение прошедшего времени между двумя метками
MeasureTime(&begin, &t_end := unset) {
    global Frequency
    if (!Frequency)
        DllCall("QueryPerformanceFrequency", "Int64*", &Frequency)
    if (!IsSet(t_end))
        t_end := GetQPC()
    return Round((1000 * (t_end - begin) / Frequency), 3)
}

; begin/end – две метки QPC, возвращается округлённая разница в миллисекундах

; Удерживание клавиши заданное время и ожидание после (если нужно)
; keyName – имя клавиши или vk-код, распознаваемый AHK
; duration – время удерживания клавиши
; wait – время ожидания после отпускания клавиши
HoldKey(keyName, duration, wait := 0) {
    Send("{%" keyName "% down}")
    lSleep(duration)
    Send("{%" keyName "% up}")
    lSleep(wait)
}

; Циклическое нажатие клавиши с заданным интервалом и общей продолжительностью
; keyName – имя клавиши или vk-код
; timeBetweenInputs – интервал между нажатиями клавиши
; endTime – общая продолжительность работы цикла
; start – опциональная QPC метка времени
TimedKeyLoop(keyName, timeBetweenInputs, endTime, &start := unset) {
    global Frequency
    if (!IsSet(start))
        start := GetQPC()
    if (!Frequency)
        DllCall("QueryPerformanceFrequency", "Int64*", &Frequency)
    
    local loopEnd := start + (Frequency * (endTime / 1000)) - 1
    while (GetQPC() < loopEnd) {
        Send("{" keyName "}")
        local keyPressTime := GetQPC()
        local nextKeyTime := keyPressTime + (Frequency * (timeBetweenInputs / 1000)) - 1
        
        while (true) {
            local currentTime := GetQPC()
            if (currentTime > loopEnd)
                return
            if (currentTime >= nextKeyTime)
                break
            lSleep(0.3, &currentTime)
        }
    }
}

; Пример измерения времени выполнения фрагмента кода:

F1::{
    local before := GetQPC()
    ; Пример: задержка в 2 мс
    Send "{LShift}"
    local after := GetQPC()
    MsgBox(1000 * (after - before) / Frequency)
}
/**/
