;; Headers - directives and runtime settings shared by every macro.
;; Include first, inside the auto-execute section: everything below runs at startup.
#SingleInstance Force
#Persistent
#NoEnv
#InstallKeybdHook
#KeyHistory 0
#MaxHotkeysPerInterval 9999999
#HotkeyInterval 9999999
#MaxThreads 255

ListLines, Off
Process, Priority,, A
SendMode Input
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetControlDelay, -1
SetWinDelay, -1
SetStoreCapslockMode, Off
CoordMode, Pixel, Screen
DllCall("SetThreadDpiAwarenessContext", "Ptr", -3, "Ptr") ; per monitor aware: pixel coordinates are physical
