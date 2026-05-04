; headers.ahk
#Requires AutoHotkey v2.0

#SingleInstance Force
Persistent

SendMode "Input"
ProcessSetPriority "A"

SetWorkingDir A_ScriptDir
ListLines false

SetWinDelay -1
SetKeyDelay -1, -1
SetMouseDelay -1
SetControlDelay -1

A_MaxHotkeysPerInterval := 99000000
#MaxThreads 255
KeyHistory 0

InstallKeybdHook

DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
