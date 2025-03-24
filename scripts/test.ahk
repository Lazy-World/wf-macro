#Requires AutoHotkey v2.0

; Debug include
#include %A_ScriptDir%/..

#include lib\headers.ahk
#include lib\time.ahk
#include lib\json.ahk 

configText := FileRead(A_ScriptDir "\cfg\test.json")
config := JSON.Load(configText)

MyGui := Gui()
MyGui.Add("Text",, "Please enter your name:")
MyGui.AddEdit("vName")
MyGui.Show()

Send "{keys.tab}"

return
