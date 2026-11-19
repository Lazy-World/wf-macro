;; Wf - Warframe specific helpers. Generic additions to native AHK stay in
;; core.ahk, widget logic in ui.ahk; only what knows about the game is here.
;;   WfActive()                     ; is the game window active
;;   PixelSeen(spot, [color, var])  ; is the screen pixel at spot [x, y] that colour
;; Pixel coordinates: headers.ahk sets CoordMode to Screen.

WfActive() {
    return WinActive("ahk_exe Warframe.x64.exe")
}

PixelSeen(spot, color) {
    PixelSearch,,, % spot[1], % spot[2], % spot[1], % spot[2], % color[1], % color[2], Fast RGB
    return !ErrorLevel
}
