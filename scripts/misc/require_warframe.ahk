;; Gate the game binds to Warframe.
;; Every Hotkey registered AFTER this include only fires while the Warframe
;; window is active. Register global binds (reload/unload/pause) BEFORE it.
;; Adjust the exe name below if your client differs (e.g. Warframe.exe).
#IfWinActive ahk_exe Warframe.x64.exe
Hotkey, IfWinActive, ahk_exe Warframe.x64.exe
