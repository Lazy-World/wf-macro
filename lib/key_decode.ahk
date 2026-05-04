#Requires AutoHotkey v2.0

vk := A_Args.Length ? A_Args[1] : 0
data := GetKeyName(Format("vk{:x}", vk))
FileAppend(data, "*", "UTF-8")
