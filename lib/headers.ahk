﻿; headers.ahk
#Requires AutoHotkey v2.0

; ============================================================
; Настройки производительности для AHK v2
; ============================================================
#SingleInstance Force      ; Запрещает одновременное выполнение нескольких копий скрипта
Persistent                ; Скрипт остаётся запущенным (если нет горячих клавиш/GUI)

SendMode("Input")         ; Устанавливает режим отправки на максимально быстрый
ProcessSetPriority("A")     ; Устанавливает высокий приоритет процесса (как в AHK v1: Process, Priority,, A)

; Опционально: установка рабочего каталога в папку скрипта
SetWorkingDir(A_ScriptDir)

; Отключение отображения листинга кода (полезно для отладки, но в продакшене можно отключить)
ListLines false

; Задержки для окон, клавиатуры, мыши и элементов управления – оптимизация для максимальной скорости
SetWinDelay(-1)
SetKeyDelay(-1, -1)
SetMouseDelay(-1, -1)
SetControlDelay(-1)

; Директивы для горячих клавиш, потоков и истории клавиш
A_MaxHotkeysPerInterval := 99000000
#MaxThreads 255
KeyHistory 0

; Опционально: отключение иконки скрипта в системном трее (если она не нужна)
; #NoTrayIcon
