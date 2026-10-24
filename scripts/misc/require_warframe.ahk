;; Gate the game binds to Warframe.
;; Every hotkey of the script only fires while the Warframe window is active,
;; the reload/unload/pause binds too: the #IfWinActive below is the script's
;; last #If directive, and AHK v1 starts the Hotkey command under it.
;; Adjust the exe name below if your client differs (e.g. Warframe.exe).
#IfWinActive ahk_exe Warframe.x64.exe
Hotkey, IfWinActive, ahk_exe Warframe.x64.exe
