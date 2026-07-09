;; Shared "Cooldown" status window.
;; Set the global variable `guiLabel` before including this file.
;; Exposes the window as ui[1].
global ui := []

gGuiW := 80
gGuiH := 28

gPosX := Ceil(gScreen[1] * 0.008)
gPosY := Ceil(gScreen[2] * 0.47)

ui.push(new Window("gui_chat", new Vector(gPosX, gPosY), new Vector(gGuiW, gGuiH), ui_theme, {"ol": [1, 1, 1, 1]}))
ui[1].new_text("Cooldown", guiLabel, "title", "auto")
ui[1].edit_color("Cooldown", "dadada")
ui[1].show()
return
