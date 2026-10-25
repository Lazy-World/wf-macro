; #NoEnv
; #Persistent
; #KeyHistory 0
; #HotkeyInterval 99000000
; #MaxHotkeysPerInterval 99000000
; SetDefaultMouseSpeed, 0
; SetControlDelay, -1
; SetKeyDelay, -1, -1
; SetMouseDelay, -1
; SetBatchLines, -1
; SetWinDelay, -1
; SendMode Input
; ListLines Off
; CoordMode, Mouse, Client

;---------------------------NEW---------------------------
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
CoordMode, Pixel, Screen
SetStoreCapslockMode, Off
SendMode Input
SetBatchLines -1
SetKeyDelay, -1, -1
SetMouseDelay, -1, -1
SetControlDelay -1
SetWinDelay -1