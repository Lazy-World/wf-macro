#Requires AutoHotkey v2.0

#include lib\headers.ahk
#include lib\time.ahk 

MyGui := Gui()
MyGui.Add("Text",, "Please enter your name:")
MyGui.AddEdit("vName")
MyGui.Show()

return
