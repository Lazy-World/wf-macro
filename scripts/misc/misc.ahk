;; Shared Misc subroutines: reload / unload / pause.
;; Include at the very END of a script (after all its own labels).
;; reload / exitapp / Suspend are auto-exempt from Suspend, so these
;; hotkeys keep working while the macro is paused.

MiscReloadMacro:
    reload
return

MiscUnloadMacro:
    exitapp
return

MiscPause:
    Suspend, Toggle
    if (A_IsSuspended) {
        pausedBody := ui[1].text().get_control("Cooldown")["body"]
        ui[1].edit_text("Cooldown", "PAUSE")
    } else {
        ui[1].edit_text("Cooldown", pausedBody)
    }
return
