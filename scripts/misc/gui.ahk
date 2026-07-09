;; Shared status window.
;; Set the global variable `guiLabel` before including this file.
;; Exposes the window as the super-global `status`.
;; Update the label anywhere with:  status.text := "..."   (read it back with: status.text)
global status := new StatusWindow(Ceil(gScreen[1] * 0.008), Ceil(gScreen[2] * 0.47), guiLabel)
return
